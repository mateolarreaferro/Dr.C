import z from "zod"
import { spawn } from "child_process"
import path from "path"
import { Tool } from "./tool"
import DESCRIPTION from "./csound_render.txt"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"
import { CsoundProcessRegistry } from "../csound/process-registry"

const log = Log.create({ service: "csound-render" })

const MAX_DURATION = 30.0
const DEFAULT_DURATION = 10.0

export const CsoundRenderTool = Tool.define(
  "csound_render",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file to render"),
      outputPath: z
        .string()
        .optional()
        .describe("Output .wav path (defaults to <input-basename>.wav in same directory)"),
      durationSeconds: z
        .number()
        .min(0.5)
        .max(MAX_DURATION)
        .optional()
        .describe(`Max render duration in seconds (default ${DEFAULT_DURATION}, max ${MAX_DURATION})`),
      playback: z
        .boolean()
        .optional()
        .describe("Play the rendered audio after completion (default false)"),
    }),
    async execute(params, ctx) {
      const duration = params.durationSeconds ?? DEFAULT_DURATION
      const playback = params.playback ?? false

      // Resolve paths through workspace if active (redirects to temp dir)
      const filePath = SessionWorkspace.resolve(ctx.sessionID, params.filePath)
      const outputPath = SessionWorkspace.resolve(
        ctx.sessionID,
        params.outputPath ?? path.join(path.dirname(params.filePath), path.basename(params.filePath, ".csd") + ".wav"),
      )

      const file = Bun.file(filePath)
      if (!(await file.exists())) {
        throw new Error(`File not found: ${filePath}`)
      }

      if (!filePath.endsWith(".csd")) {
        throw new Error(`Expected a .csd file, got: ${filePath}`)
      }

      ctx.metadata({
        metadata: {
          status: "rendering",
          filePath,
          outputPath,
          duration,
        },
      })

      const { exitCode, stdout, stderr, timedOut } = await runRender(filePath, outputPath, duration, ctx.abort)

      const parts: string[] = []
      const success = exitCode === 0 || timedOut

      if (success) {
        const outFile = Bun.file(outputPath)
        const exists = await outFile.exists()
        let fileSize = 0
        if (exists) {
          fileSize = outFile.size
        }

        parts.push(`## Render: SUCCESS`)
        parts.push(`Output: ${outputPath}`)
        if (exists) {
          parts.push(`File size: ${formatSize(fileSize)}`)
          // Parse WAV header for audio info
          const wavInfo = await parseWavInfo(outputPath)
          if (wavInfo) {
            parts.push(`Audio: ${wavInfo.duration.toFixed(1)}s, ${wavInfo.bitDepth}-bit, ${wavInfo.sampleRate}Hz, ${wavInfo.channels === 1 ? "mono" : "stereo"}`)
          }
        }
        parts.push(`Duration limit: ${duration}s`)
        if (timedOut) {
          parts.push("(Process terminated after duration limit — audio was captured up to that point)")
        }

        // Play back if requested
        if (playback && exists && fileSize > 44) {
          const playResult = await playAudio(outputPath)
          if (playResult.success) {
            parts.push(`\nPlayback: started (${playResult.player})`)
          } else {
            parts.push(`\nPlayback: failed — ${playResult.error}`)
          }
        }
      } else {
        parts.push(`## Render: FAILED`)
        parts.push(`Exit code: ${exitCode}`)
      }

      if (stderr.trim()) {
        // Filter out noisy Csound output, keep warnings and errors
        const filtered = filterStderr(stderr)
        if (filtered) {
          parts.push(`\n## Messages\n\`\`\`\n${filtered}\n\`\`\``)
        }
      }

      ctx.metadata({
        metadata: {
          status: success ? "success" : "error",
          filePath,
          outputPath,
          exitCode,
          timedOut,
        },
      })

      // Mark workspace dirty after successful render
      if (success) {
        await SessionWorkspace.markDirty(ctx.sessionID)
      }

      return {
        title: success ? `Rendered ${path.basename(outputPath)}` : "Render failed",
        metadata: {
          exitCode,
          timedOut,
          success,
          filePath,
          outputPath,
        },
        output: parts.join("\n"),
      }
    },
  },
)

async function runRender(
  filePath: string,
  outputPath: string,
  durationSeconds: number,
  abort: AbortSignal,
): Promise<{
  exitCode: number
  stdout: string
  stderr: string
  timedOut: boolean
}> {
  return new Promise((resolve, reject) => {
    let stdout = ""
    let stderr = ""
    let timedOut = false
    let exited = false

    // -W: WAV output, -o: output file, -d: no displays, -m0: minimal messages
    const proc = spawn("csound", ["-W", "-d", "-m0", "-o", outputPath, filePath], {
      stdio: ["ignore", "pipe", "pipe"],
      detached: process.platform !== "win32",
    })

    CsoundProcessRegistry.register(proc, "render")

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const timeoutMs = durationSeconds * 1000 + 1000 // extra 1s grace period

    const timer = setTimeout(() => {
      timedOut = true
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
      resolve({ exitCode: code ?? 1, stdout, stderr, timedOut })
    })

    proc.once("error", (err) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      if (err.message.includes("ENOENT")) {
        reject(new Error("csound command not found. Please install Csound: https://csound.com/download.html"))
      }
      reject(err)
    })
  })
}

async function playAudio(filePath: string): Promise<{ success: boolean; player?: string; error?: string }> {
  const players =
    process.platform === "darwin"
      ? ["afplay"]
      : process.platform === "linux"
        ? ["paplay", "aplay"]
        : []

  for (const player of players) {
    try {
      // Spawn in background — don't wait for playback to finish
      const proc = spawn(player, [filePath], {
        stdio: "ignore",
        detached: true,
      })
      proc.unref()
      CsoundProcessRegistry.register(proc, "playback")
      return { success: true, player }
    } catch {
      continue
    }
  }

  return { success: false, error: "No audio player found (tried: " + players.join(", ") + ")" }
}

function filterStderr(stderr: string): string {
  return stderr
    .split("\n")
    .filter((line) => {
      const l = line.trim()
      if (!l) return false
      // Skip noisy informational lines
      if (l.startsWith("--Csound version")) return false
      if (l.startsWith("UnifiedCSD")) return false
      if (l.startsWith("SECTION")) return false
      if (l.includes("overall amps:")) return false
      if (l.includes("overall samples out of range:")) return false
      if (l.includes("0 errors in performance")) return false
      return true
    })
    .join("\n")
    .trim()
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
}

async function parseWavInfo(
  wavPath: string,
): Promise<{ sampleRate: number; channels: number; bitDepth: number; duration: number } | null> {
  try {
    const file = Bun.file(wavPath)
    const buffer = await file.arrayBuffer()
    if (buffer.byteLength < 44) return null

    const view = new DataView(buffer)
    const riff = String.fromCharCode(view.getUint8(0), view.getUint8(1), view.getUint8(2), view.getUint8(3))
    if (riff !== "RIFF") return null

    const channels = view.getUint16(22, true)
    const sampleRate = view.getUint32(24, true)
    const bitDepth = view.getUint16(34, true)

    // Find data chunk size
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
    const duration = totalSamples / (sampleRate * channels)

    return { sampleRate, channels, bitDepth, duration }
  } catch {
    return null
  }
}
