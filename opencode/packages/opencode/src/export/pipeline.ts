import { spawn } from "child_process"
import fs from "fs/promises"
import path from "path"
import { SessionWorkspace } from "../session/workspace"
import { Log } from "../util/log"

const log = Log.create({ service: "export.pipeline" })

export namespace ExportPipeline {
  /**
   * Validate that a CSD file compiles without errors.
   * Uses the same syntax-check pattern as builtin.ts post-edit hook.
   */
  export async function validate(csdPath: string): Promise<{ valid: boolean; errors?: string[] }> {
    return new Promise((resolve) => {
      let stderr = ""

      const proc = spawn("csound", ["--syntax-check-only", csdPath], {
        timeout: 10000,
        stdio: ["ignore", "ignore", "pipe"],
      })

      proc.stderr?.on("data", (chunk: Buffer) => {
        stderr += chunk.toString()
      })

      proc.on("close", (code) => {
        if (code === 0) {
          resolve({ valid: true })
        } else {
          const errors = stderr
            .split("\n")
            .filter((line) => {
              const l = line.trim()
              if (!l) return false
              if (l.startsWith("--Csound version")) return false
              if (l.startsWith("UnifiedCSD")) return false
              return true
            })
          resolve({ valid: false, errors })
        }
      })

      proc.on("error", (err) => {
        if (err.message.includes("ENOENT")) {
          resolve({ valid: false, errors: ["csound command not found. Please install Csound."] })
        } else {
          resolve({ valid: false, errors: [err.message] })
        }
      })
    })
  }

  /**
   * Read the current CSD content from the workspace temp directory.
   * Scans for the first .csd file in the session workspace.
   */
  export async function readCsd(sessionID: string): Promise<{ content: string; path: string }> {
    const wsStatus = SessionWorkspace.status(sessionID)
    if (!wsStatus.active || !wsStatus.tempDir) {
      throw new Error("No active workspace for this session. Write or patch a CSD first.")
    }

    const tempDir = wsStatus.tempDir
    const entries = await fs.readdir(tempDir)
    const csdFile = entries.find((e) => e.endsWith(".csd"))

    if (!csdFile) {
      throw new Error(`No .csd file found in workspace: ${tempDir}`)
    }

    const csdPath = path.join(tempDir, csdFile)
    const content = await Bun.file(csdPath).text()
    return { content, path: csdPath }
  }

  /**
   * Ensure an output directory exists, creating it if necessary.
   * Returns the resolved absolute path.
   */
  export async function ensureOutputDir(outputPath: string): Promise<string> {
    const resolved = path.resolve(outputPath)
    await fs.mkdir(resolved, { recursive: true })
    return resolved
  }
}
