import { Log } from "../util/log"
import { parseCsoundErrors, type CsoundDiagnostic } from "../tool/error_parse"
import { spawn } from "child_process"

const log = Log.create({ service: "validation-pipeline" })

export namespace ValidationPipeline {
  export interface Options {
    filePath: string
    maxRepairIterations?: number
    smokeEnabled?: boolean
    smokeDuration?: number
  }

  export interface Result {
    compileSuccess: boolean
    smokeSuccess: boolean | null
    iterations: number
    diagnostics: CsoundDiagnostic[]
    repairPatches: string[]
    failure?: {
      most_likely_cause: string
      error_locations_best_effort: Array<{ line: number; message: string }>
      next_manual_steps: string[]
    }
  }

  export async function run(options: Options): Promise<Result> {
    const {
      filePath,
      maxRepairIterations = 3,
      smokeEnabled = true,
      smokeDuration = 1.0,
    } = options

    const result: Result = {
      compileSuccess: false,
      smokeSuccess: null,
      iterations: 0,
      diagnostics: [],
      repairPatches: [],
    }

    // Step 1: Compile
    for (let i = 0; i < maxRepairIterations; i++) {
      result.iterations = i + 1
      log.info("compile iteration", { iteration: i + 1, filePath })

      const compileResult = await compile(filePath)
      result.diagnostics = compileResult.diagnostics

      if (compileResult.exitCode === 0) {
        result.compileSuccess = true
        log.info("compilation succeeded", { iteration: i + 1 })
        break
      }

      log.warn("compilation failed", {
        iteration: i + 1,
        diagnosticCount: compileResult.diagnostics.length,
      })

      // If we've exhausted iterations, report failure
      if (i === maxRepairIterations - 1) {
        result.failure = {
          most_likely_cause: summarizeErrors(compileResult.diagnostics),
          error_locations_best_effort: compileResult.diagnostics
            .filter((d) => d.line !== null)
            .map((d) => ({ line: d.line!, message: d.message })),
          next_manual_steps: [
            "Review the diagnostic messages above",
            "Check for missing opcodes or syntax errors",
            "Verify all channels are properly defined",
            "Ensure section tags are properly closed",
          ],
        }
        return result
      }

      // Note: In the full implementation, this would feed stderr to the LLM
      // for repair. For now, we just track the iteration.
    }

    // Step 2: Smoke test (if compile succeeded and smoke is enabled)
    if (result.compileSuccess && smokeEnabled) {
      log.info("running smoke test", { filePath, duration: smokeDuration })
      const smokeResult = await smoke(filePath, smokeDuration)
      result.smokeSuccess = smokeResult.passed

      if (!smokeResult.passed) {
        log.warn("smoke test failed", { exitCode: smokeResult.exitCode })
        result.failure = {
          most_likely_cause: "Runtime crash or error during smoke test",
          error_locations_best_effort: parseCsoundErrors(smokeResult.stderr)
            .filter((d) => d.line !== null)
            .map((d) => ({ line: d.line!, message: d.message })),
          next_manual_steps: [
            "Check for division by zero or invalid table access",
            "Verify all function tables are defined before use",
            "Check for infinite loops in k-rate processing",
          ],
        }
      }
    }

    return result
  }

  async function compile(filePath: string): Promise<{
    exitCode: number
    stderr: string
    diagnostics: CsoundDiagnostic[]
  }> {
    return new Promise((resolve, reject) => {
      let stderr = ""

      const proc = spawn("csound", ["-n", "-d", "-m0", "-W", "-o", "null", filePath], {
        stdio: ["ignore", "pipe", "pipe"],
      })

      proc.stderr?.on("data", (chunk: Buffer) => {
        stderr += chunk.toString()
      })

      proc.once("exit", (code) => {
        resolve({
          exitCode: code ?? 1,
          stderr,
          diagnostics: parseCsoundErrors(stderr),
        })
      })

      proc.once("error", (err) => {
        reject(err)
      })
    })
  }

  async function smoke(
    filePath: string,
    durationSeconds: number,
  ): Promise<{
    exitCode: number
    stderr: string
    passed: boolean
  }> {
    return new Promise((resolve, reject) => {
      let stderr = ""
      let exited = false

      const proc = spawn("csound", ["-d", "-m0", "-W", "-o", "/dev/null", filePath], {
        stdio: ["ignore", "pipe", "pipe"],
        detached: process.platform !== "win32",
      })

      proc.stderr?.on("data", (chunk: Buffer) => {
        stderr += chunk.toString()
      })

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
      }, durationSeconds * 1000 + 500)

      proc.once("exit", (code) => {
        exited = true
        clearTimeout(timer)
        const exitCode = code ?? 1
        // If it was killed by timeout, that's a pass (it ran without crashing)
        resolve({
          exitCode,
          stderr,
          passed: exitCode === 0 || exitCode === 143 || exitCode === 137 /* SIGTERM/SIGKILL */,
        })
      })

      proc.once("error", (err) => {
        exited = true
        clearTimeout(timer)
        reject(err)
      })
    })
  }

  function summarizeErrors(diagnostics: CsoundDiagnostic[]): string {
    const errors = diagnostics.filter((d) => d.severity === "error")
    if (errors.length === 0) return "Unknown compilation error"
    if (errors.length === 1) return errors[0].message
    return `${errors.length} errors: ${errors.slice(0, 3).map((e) => e.message).join("; ")}`
  }
}
