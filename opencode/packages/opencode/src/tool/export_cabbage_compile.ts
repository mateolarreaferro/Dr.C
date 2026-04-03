import z from "zod"
import fs from "fs/promises"
import path from "path"
import { spawn } from "child_process"
import { Tool } from "./tool"
import DESCRIPTION from "./export_cabbage_compile.txt"
import { SessionWorkspace } from "../session/workspace"
import { ExportPipeline } from "../export/pipeline"
import { generateCabbageCsd } from "./csound_export_cabbage"
import { Log } from "../util/log"

const log = Log.create({ service: "export-cabbage-compile" })

export const ExportCabbageCompileTool = Tool.define(
  "export_cabbage_compile",
  {
    description: DESCRIPTION,
    parameters: z.object({
      target: z.enum(["vst", "au", "standalone"]).describe("Compilation target"),
      outputDir: z
        .string()
        .optional()
        .describe("Output directory for the compiled binary (defaults to workspace)"),
    }),
    async execute(params, ctx) {
      // Read CSD from workspace
      const { content: csdContent, path: csdPath } = await ExportPipeline.readCsd(ctx.sessionID)

      // Validate CSD first
      const validation = await ExportPipeline.validate(csdPath)
      if (!validation.valid) {
        throw new Error(
          `CSD has syntax errors — fix before compiling:\n${(validation.errors ?? []).join("\n")}`,
        )
      }

      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      const outputDir = params.outputDir
        ? path.resolve(params.outputDir)
        : wsStatus.tempDir ?? path.dirname(csdPath)
      await fs.mkdir(outputDir, { recursive: true })

      ctx.metadata({
        metadata: {
          status: "compiling",
          target: params.target,
          csdPath,
        },
      })

      // Check if Cabbage CLI is installed
      const cabbagePath = await findCabbage()

      if (cabbagePath) {
        // Cabbage is installed — generate Cabbage CSD and compile
        const cabbageCsd = generateCabbageCsd(
          csdContent,
          params.target === "standalone" ? "standalone" : "vst",
        )

        const cabbageCsdPath = path.join(outputDir, path.basename(csdPath, ".csd") + "_cabbage.csd")
        await Bun.write(cabbageCsdPath, cabbageCsd)

        // Run Cabbage CLI
        const ext = params.target === "vst" ? ".vst3" : params.target === "au" ? ".component" : ""
        const baseName = path.basename(csdPath, ".csd")
        const outputPath = path.join(outputDir, baseName + ext)

        const result = await runCabbageCompile(cabbagePath, params.target, cabbageCsdPath, outputPath)

        if (result.success) {
          ctx.metadata({
            metadata: {
              status: "success",
              outputPath,
              method: "cabbage-cli",
            },
          })

          return {
            title: `Compiled ${params.target.toUpperCase()} via Cabbage`,
            metadata: {
              outputPath,
              cabbageCsdPath,
              target: params.target,
              method: "cabbage-cli",
              status: "success",
            },
            output: [
              `## Cabbage Compile: SUCCESS`,
              ``,
              `Target: ${params.target.toUpperCase()}`,
              `Output: ${outputPath}`,
              `Cabbage CSD: ${cabbageCsdPath}`,
              ``,
              `The ${params.target} has been compiled and is ready to use.`,
            ].join("\n"),
          }
        } else {
          // Compile failed — return the CSD as fallback
          log.warn("cabbage compile failed", { error: result.error })

          return {
            title: `Cabbage compile failed — CSD ready for manual compile`,
            metadata: {
              cabbageCsdPath,
              target: params.target,
              method: "cabbage-cli-failed",
              error: result.error,
              status: "error",
            },
            output: [
              `## Cabbage Compile: FAILED`,
              ``,
              `Error: ${result.error}`,
              ``,
              `A Cabbage-formatted CSD has been generated: ${cabbageCsdPath}`,
              `Open it in Cabbage to compile manually.`,
            ].join("\n"),
          }
        }
      } else {
        // Cabbage not installed — generate CSD with Cabbage section as fallback
        const mode = params.target === "standalone" ? "standalone" : "vst"
        const cabbageCsd = generateCabbageCsd(csdContent, mode)

        const cabbageCsdPath = path.join(outputDir, path.basename(csdPath, ".csd") + "_cabbage.csd")
        await Bun.write(cabbageCsdPath, cabbageCsd)

        ctx.metadata({
          metadata: {
            status: "success",
            cabbageCsdPath,
            method: "fallback",
          },
        })

        return {
          title: `Generated Cabbage CSD (CLI not found)`,
          metadata: {
            cabbageCsdPath,
            target: params.target,
            method: "fallback",
            status: "success",
          },
          output: [
            `## Cabbage Compile: CLI NOT FOUND`,
            ``,
            `Cabbage CLI was not detected on this system.`,
            `A Cabbage-formatted CSD has been generated instead: ${cabbageCsdPath}`,
            ``,
            `### Installation`,
            `- **macOS**: Download from https://cabbageaudio.com/download/`,
            `- **Linux**: Install via package manager or download from website`,
            ``,
            `### Manual Compilation`,
            `1. Open ${cabbageCsdPath} in Cabbage`,
            `2. Go to File > Export as ${params.target === "vst" ? "VST/AU Plugin" : params.target === "au" ? "AU Plugin" : "Standalone Application"}`,
            `3. Choose output location`,
          ].join("\n"),
        }
      }
    },
  },
)

/**
 * Find the Cabbage CLI binary on the system.
 */
async function findCabbage(): Promise<string | null> {
  if (process.platform === "darwin") {
    const macPath = "/Applications/Cabbage.app/Contents/MacOS/Cabbage"
    try {
      await fs.access(macPath)
      return macPath
    } catch {}
  }

  // Try PATH lookup
  return new Promise((resolve) => {
    const proc = spawn("which", ["cabbage"], { stdio: "pipe" })
    let stdout = ""
    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })
    proc.on("close", (code) => {
      if (code === 0 && stdout.trim()) {
        resolve(stdout.trim())
      } else {
        resolve(null)
      }
    })
    proc.on("error", () => resolve(null))
  })
}

/**
 * Run Cabbage CLI to compile a CSD to the target format.
 */
async function runCabbageCompile(
  cabbagePath: string,
  target: "vst" | "au" | "standalone",
  csdPath: string,
  outputPath: string,
): Promise<{ success: boolean; error?: string }> {
  return new Promise((resolve) => {
    let stderr = ""

    const args = [`--export-${target}`, csdPath, "-o", outputPath]
    const proc = spawn(cabbagePath, args, {
      timeout: 60000,
      stdio: ["ignore", "ignore", "pipe"],
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    proc.on("close", (code) => {
      if (code === 0) {
        resolve({ success: true })
      } else {
        resolve({ success: false, error: stderr.trim() || `exit code ${code}` })
      }
    })

    proc.on("error", (err) => {
      resolve({ success: false, error: err.message })
    })
  })
}
