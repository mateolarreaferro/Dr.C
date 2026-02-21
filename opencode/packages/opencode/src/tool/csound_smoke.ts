import z from "zod"
import { spawn } from "child_process"
import { Tool } from "./tool"
import DESCRIPTION from "./csound_smoke.txt"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"

const log = Log.create({ service: "csound-smoke" })

const MAX_DURATION = 5.0
const DEFAULT_DURATION = 1.0

export const CsoundSmokeTool = Tool.define(
  "csound_smoke",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file to smoke test"),
      durationSeconds: z
        .number()
        .min(0.1)
        .max(MAX_DURATION)
        .optional()
        .describe(`Duration in seconds to run the smoke test (default ${DEFAULT_DURATION}, max ${MAX_DURATION})`),
    }),
    async execute(params, ctx) {
      // Resolve through workspace if active
      const filePath = SessionWorkspace.resolve(ctx.sessionID, params.filePath)
      const duration = params.durationSeconds ?? DEFAULT_DURATION

      const file = Bun.file(filePath)
      if (!(await file.exists())) {
        throw new Error(`File not found: ${filePath}`)
      }

      if (!filePath.endsWith(".csd")) {
        throw new Error(`Expected a .csd file, got: ${filePath}`)
      }

      ctx.metadata({
        metadata: {
          status: "running",
          filePath,
          duration,
        },
      })

      const { exitCode, stdout, stderr, timedOut } = await runSmoke(filePath, duration, ctx.abort)

      const passed = exitCode === 0 || timedOut

      ctx.metadata({
        metadata: {
          status: passed ? "passed" : "failed",
          filePath,
          exitCode,
          timedOut,
        },
      })

      const parts: string[] = []
      parts.push(`## Smoke Test: ${passed ? "PASSED" : "FAILED"}`)
      parts.push(`Duration: ${duration}s`)
      parts.push(`Exit code: ${exitCode}`)
      if (timedOut) parts.push("(Process was terminated after duration elapsed — this is expected)")

      if (stderr.trim()) {
        parts.push(`\n## Stderr\n\`\`\`\n${stderr.trim()}\n\`\`\``)
      }

      if (stdout.trim()) {
        parts.push(`\n## Stdout\n\`\`\`\n${stdout.trim()}\n\`\`\``)
      }

      return {
        title: passed ? "Smoke test passed" : "Smoke test failed",
        metadata: {
          exitCode,
          timedOut,
          passed,
          filePath,
        },
        output: parts.join("\n"),
      }
    },
  },
)

async function runSmoke(
  filePath: string,
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

    // Run with audio output to null, limited duration
    const proc = spawn("csound", ["-d", "-m0", "-W", "-o", "/dev/null", filePath], {
      stdio: ["ignore", "pipe", "pipe"],
      detached: process.platform !== "win32",
    })

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const timeoutMs = durationSeconds * 1000 + 500 // extra 500ms grace period

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
