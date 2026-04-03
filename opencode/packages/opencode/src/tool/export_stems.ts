import z from "zod"
import fs from "fs/promises"
import path from "path"
import { spawn } from "child_process"
import { Tool } from "./tool"
import DESCRIPTION from "./export_stems.txt"
import { SessionWorkspace } from "../session/workspace"
import { CsdParser } from "../csound/parser"
import { CsoundProcessRegistry } from "../csound/process-registry"
import { Log } from "../util/log"

const log = Log.create({ service: "export-stems" })

const MAX_DURATION = 30.0
const DEFAULT_DURATION = 10.0

export const ExportStemsTool = Tool.define(
  "export_stems",
  {
    description: DESCRIPTION,
    parameters: z.object({
      outputDir: z
        .string()
        .optional()
        .describe("Directory for stem WAVs (defaults to workspace stems/ subdirectory)"),
    }),
    async execute(params, ctx) {
      // Read CSD from workspace
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        throw new Error("No active workspace for this session. Write or patch a CSD first.")
      }

      const tempDir = wsStatus.tempDir
      const entries = await fs.readdir(tempDir)
      const csdFile = entries.find((e) => e.endsWith(".csd"))

      if (!csdFile) {
        throw new Error("No .csd file found in workspace.")
      }

      const csdPath = path.join(tempDir, csdFile)
      const csdContent = await Bun.file(csdPath).text()

      // Parse CSD to enumerate instruments
      const structure = CsdParser.parse(csdContent)
      const instruments = structure.instruments

      if (instruments.length === 0) {
        throw new Error("No instruments found in CSD.")
      }

      // Set up output directory
      const outputDir = params.outputDir
        ? path.resolve(params.outputDir)
        : path.join(tempDir, "stems")
      await fs.mkdir(outputDir, { recursive: true })

      ctx.metadata({
        metadata: {
          status: "rendering",
          instrumentCount: instruments.length,
          outputDir,
        },
      })

      const stems: { instrument: string; wavPath: string; duration: number }[] = []
      const errors: string[] = []

      // If only one instrument, just render the full CSD as a single stem
      if (instruments.length === 1) {
        const instr = instruments[0]
        const stemName = sanitizeFilename(instr.id)
        const wavPath = path.join(outputDir, `${stemName}.wav`)

        const result = await renderCsd(csdPath, wavPath, ctx.abort)
        if (result.success) {
          const wavInfo = await parseWavDuration(wavPath)
          stems.push({
            instrument: instr.id,
            wavPath,
            duration: wavInfo,
          })
        } else {
          errors.push(`instr ${instr.id}: ${result.error}`)
        }
      } else {
        // Multi-instrument: create per-instrument CSDs and render each
        const csdLines = csdContent.split("\n")

        // Extract global setup: everything in CsInstruments before the first instr
        const instrSection = structure.sections.find((s) => s.name === "CsInstruments")
        const scoreSection = structure.sections.find((s) => s.name === "CsScore")

        if (!instrSection) {
          throw new Error("No <CsInstruments> section found in CSD.")
        }

        const instrContent = instrSection.content.split("\n")
        const instrSectionOffset = instrSection.startLine

        // Extract global header lines (before first instr)
        const globalLines: string[] = []
        for (const line of instrContent) {
          const trimmed = line.trim()
          if (trimmed.match(/^instr\s+/)) break
          globalLines.push(line)
        }
        const globalHeader = globalLines.join("\n")

        // Extract score content
        const scoreContent = scoreSection?.content ?? "f 0 3600\n"

        // Parse score events per instrument
        const scoreEvents = new Map<string, string[]>()
        if (scoreSection) {
          for (const line of scoreSection.content.split("\n")) {
            const trimmed = line.trim()
            if (trimmed.startsWith(";") || !trimmed) continue

            // Table definitions go in all stems
            if (trimmed.startsWith("f ") || trimmed.startsWith("f\t")) {
              for (const instr of instruments) {
                if (!scoreEvents.has(instr.id)) scoreEvents.set(instr.id, [])
                scoreEvents.get(instr.id)!.push(line)
              }
              continue
            }

            // Match score event: i <instrID> ...
            const match = trimmed.match(/^i\s+(\S+)/)
            if (match) {
              const eventInstr = match[1].replace(/^"/, "").replace(/"$/, "")
              if (!scoreEvents.has(eventInstr)) scoreEvents.set(eventInstr, [])
              scoreEvents.get(eventInstr)!.push(line)
            }
          }
        }

        // Render each instrument sequentially
        for (const instr of instruments) {
          if (ctx.abort.aborted) break

          const stemName = sanitizeFilename(instr.id)
          const wavPath = path.join(outputDir, `${stemName}.wav`)

          // Extract this instrument's body from the original CSD
          const instrStartLine = instr.startLine - instrSectionOffset
          const instrEndLine = instr.endLine - instrSectionOffset
          const instrBody = instrContent.slice(instrStartLine, instrEndLine + 1).join("\n")

          // Build per-instrument score
          const instrScoreLines = scoreEvents.get(instr.id) ?? []
          if (instrScoreLines.length === 0) {
            // No score events for this instrument — add a dummy sustain
            instrScoreLines.push(`i ${instr.id} 0 ${DEFAULT_DURATION}`)
          }
          const instrScore = instrScoreLines.join("\n") + "\ne\n"

          // Assemble the per-instrument CSD
          const stemCsd = [
            "<CsoundSynthesizer>",
            "<CsOptions>",
            "-d -m0",
            "</CsOptions>",
            "<CsInstruments>",
            globalHeader,
            instrBody,
            "</CsInstruments>",
            "<CsScore>",
            instrScore,
            "</CsScore>",
            "</CsoundSynthesizer>",
          ].join("\n")

          // Write temp CSD
          const tempCsdPath = path.join(outputDir, `_stem_${stemName}.csd`)
          await Bun.write(tempCsdPath, stemCsd)

          log.info("rendering stem", { instrument: instr.id, tempCsd: tempCsdPath })

          const result = await renderCsd(tempCsdPath, wavPath, ctx.abort)

          // Clean up temp CSD
          try {
            await fs.rm(tempCsdPath, { force: true })
          } catch {}

          if (result.success) {
            const wavDuration = await parseWavDuration(wavPath)
            stems.push({
              instrument: instr.id,
              wavPath,
              duration: wavDuration,
            })
          } else {
            errors.push(`instr ${instr.id}: ${result.error}`)
          }
        }
      }

      // Build output
      const parts: string[] = []

      if (stems.length > 0) {
        parts.push(`## Stems Export: SUCCESS`)
        parts.push(``)
        parts.push(`Output: ${outputDir}`)
        parts.push(`Stems: ${stems.length}/${instruments.length}`)
        parts.push(``)
        for (const stem of stems) {
          parts.push(`- **instr ${stem.instrument}**: ${path.basename(stem.wavPath)} (${stem.duration.toFixed(1)}s)`)
        }
      } else {
        parts.push(`## Stems Export: FAILED`)
        parts.push(`No stems were rendered successfully.`)
      }

      if (errors.length > 0) {
        parts.push(``)
        parts.push(`### Errors`)
        for (const err of errors) {
          parts.push(`- ${err}`)
        }
      }

      ctx.metadata({
        metadata: {
          status: stems.length > 0 ? "success" : "error",
          outputDir,
          stemCount: stems.length,
        },
      })

      // Mark workspace dirty after successful export
      if (stems.length > 0) {
        await SessionWorkspace.markDirty(ctx.sessionID)
      }

      return {
        title: stems.length > 0 ? `Exported ${stems.length} stems` : "Stems export failed",
        metadata: {
          outputDir,
          stems,
          errors,
          status: stems.length > 0 ? "success" : "error",
        },
        output: parts.join("\n"),
      }
    },
  },
)

/**
 * Render a CSD to WAV using the same spawn pattern as csound_render.ts.
 */
async function renderCsd(
  csdPath: string,
  outputPath: string,
  abort: AbortSignal,
): Promise<{ success: boolean; error?: string }> {
  return new Promise((resolve) => {
    let stderr = ""
    let exited = false

    const proc = spawn("csound", ["-W", "-d", "-m0", "-o", outputPath, csdPath], {
      stdio: ["ignore", "ignore", "pipe"],
      detached: process.platform !== "win32",
    })

    CsoundProcessRegistry.register(proc, "render")

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const timeoutMs = MAX_DURATION * 1000 + 1000
    const timer = setTimeout(() => {
      if (!exited) {
        try {
          if (proc.pid && process.platform !== "win32") {
            process.kill(-proc.pid, "SIGTERM")
          } else {
            proc.kill("SIGTERM")
          }
        } catch {}
      }
    }, timeoutMs)

    const abortHandler = () => {
      clearTimeout(timer)
      if (!exited) {
        try {
          proc.kill("SIGTERM")
        } catch {}
      }
    }

    if (abort.aborted) abortHandler()
    abort.addEventListener("abort", abortHandler, { once: true })

    proc.once("exit", (code) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      if (code === 0) {
        resolve({ success: true })
      } else {
        const filtered = stderr
          .split("\n")
          .filter((l) => l.trim() && !l.includes("--Csound version"))
          .slice(0, 5)
          .join("; ")
        resolve({ success: false, error: filtered || `exit code ${code}` })
      }
    })

    proc.once("error", (err) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      if (err.message.includes("ENOENT")) {
        resolve({ success: false, error: "csound command not found" })
      } else {
        resolve({ success: false, error: err.message })
      }
    })
  })
}

/**
 * Parse WAV duration from file header.
 */
async function parseWavDuration(wavPath: string): Promise<number> {
  try {
    const file = Bun.file(wavPath)
    const buffer = await file.arrayBuffer()
    if (buffer.byteLength < 44) return 0

    const view = new DataView(buffer)
    const riff = String.fromCharCode(view.getUint8(0), view.getUint8(1), view.getUint8(2), view.getUint8(3))
    if (riff !== "RIFF") return 0

    const channels = view.getUint16(22, true)
    const sampleRate = view.getUint32(24, true)
    const bitDepth = view.getUint16(34, true)

    let offset = 36
    let dataSize = 0
    while (offset < buffer.byteLength - 8) {
      const id = String.fromCharCode(
        view.getUint8(offset), view.getUint8(offset + 1),
        view.getUint8(offset + 2), view.getUint8(offset + 3),
      )
      const size = view.getUint32(offset + 4, true)
      if (id === "data") {
        dataSize = size
        break
      }
      offset += 8 + size
    }

    const bytesPerSample = bitDepth / 8
    const totalSamples = dataSize / bytesPerSample
    return totalSamples / (sampleRate * channels)
  } catch {
    return 0
  }
}

function sanitizeFilename(name: string): string {
  return name.replace(/[^a-zA-Z0-9_-]/g, "_")
}
