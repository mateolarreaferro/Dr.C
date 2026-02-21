import z from "zod"
import { spawn } from "child_process"
import { Tool } from "./tool"
import DESCRIPTION from "./csound_compile.txt"
import { Log } from "../util/log"
import { parseCsoundErrors, type CsoundDiagnostic } from "./error_parse"
import { ContractValidator } from "../validation/contract"
import { SessionWorkspace } from "../session/workspace"

const log = Log.create({ service: "csound-compile" })

export const CsoundCompileTool = Tool.define(
  "csound_compile",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file to compile"),
    }),
    async execute(params, ctx) {
      // Resolve through workspace if active
      const filePath = SessionWorkspace.resolve(ctx.sessionID, params.filePath)

      const file = Bun.file(filePath)
      if (!(await file.exists())) {
        throw new Error(`File not found: ${filePath}`)
      }

      if (!filePath.endsWith(".csd")) {
        throw new Error(`Expected a .csd file, got: ${filePath}`)
      }

      ctx.metadata({
        metadata: {
          status: "compiling",
          filePath,
        },
      })

      const { exitCode, stdout, stderr, diagnostics } = await runCsoundCompile(filePath, ctx.abort)

      ctx.metadata({
        metadata: {
          status: exitCode === 0 ? "success" : "error",
          filePath,
          exitCode,
          diagnosticCount: diagnostics.length,
        },
      })

      let output = formatOutput(exitCode, stdout, stderr, diagnostics)

      // After successful compile, run contract validation
      if (exitCode === 0) {
        const content = await Bun.file(filePath).text()
        const violations = ContractValidator.validate(content)
        if (violations.length > 0) {
          const errors = violations.filter((v) => v.severity === "error")
          const warnings = violations.filter((v) => v.severity === "warning")
          output += `\n\n## Contract Validation (${violations.length} issue${violations.length !== 1 ? "s" : ""})`
          for (const v of violations) {
            const loc = v.line ? ` (line ${v.line})` : ""
            const ch = v.channel ? ` [${v.channel}]` : ""
            output += `\n- ${v.severity.toUpperCase()}${loc}${ch}: ${v.message}`
          }
          if (errors.length > 0) {
            output += `\n\nPlease fix the ${errors.length} contract error(s) above before considering this file complete.`
          }
        } else {
          output += `\n\n## Contract Validation: PASSED`
        }
      }

      return {
        title: exitCode === 0 ? "Compilation successful" : `Compilation failed (${diagnostics.length} issues)`,
        metadata: {
          exitCode,
          diagnosticCount: diagnostics.length,
          filePath,
          status: exitCode === 0 ? "success" : "error",
        },
        output,
      }
    },
  },
)

async function runCsoundCompile(
  filePath: string,
  abort: AbortSignal,
): Promise<{
  exitCode: number
  stdout: string
  stderr: string
  diagnostics: CsoundDiagnostic[]
}> {
  return new Promise((resolve, reject) => {
    let stdout = ""
    let stderr = ""

    // -n: no sound output, -d: no display, -m0: minimal messages, -W: WAV format, -o null: no output file
    const proc = spawn("csound", ["-n", "-d", "-m0", "-W", "-o", "null", filePath], {
      stdio: ["ignore", "pipe", "pipe"],
    })

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const abortHandler = () => {
      proc.kill("SIGTERM")
    }

    if (abort.aborted) {
      proc.kill("SIGTERM")
    }

    abort.addEventListener("abort", abortHandler, { once: true })

    proc.once("exit", (code) => {
      abort.removeEventListener("abort", abortHandler)
      const exitCode = code ?? 1
      const diagnostics = parseCsoundErrors(stderr)
      resolve({ exitCode, stdout, stderr, diagnostics })
    })

    proc.once("error", (err) => {
      abort.removeEventListener("abort", abortHandler)
      if (err.message.includes("ENOENT")) {
        reject(new Error("csound command not found. Please install Csound: https://csound.com/download.html"))
      }
      reject(err)
    })
  })
}

function formatOutput(
  exitCode: number,
  stdout: string,
  stderr: string,
  diagnostics: CsoundDiagnostic[],
): string {
  const parts: string[] = []

  parts.push(`## Compilation Result: ${exitCode === 0 ? "SUCCESS" : "FAILED"}`)
  parts.push(`Exit code: ${exitCode}`)

  if (diagnostics.length > 0) {
    parts.push(`\n## Diagnostics (${diagnostics.length})`)
    for (const d of diagnostics) {
      const loc = d.line ? ` (line ${d.line}${d.col ? `:${d.col}` : ""})` : ""
      const op = d.opcode ? ` [${d.opcode}]` : ""
      parts.push(`- ${d.severity.toUpperCase()}${loc}${op}: ${d.message}`)
    }
  }

  if (stderr.trim()) {
    parts.push(`\n## Stderr\n\`\`\`\n${stderr.trim()}\n\`\`\``)
  }

  if (stdout.trim()) {
    parts.push(`\n## Stdout\n\`\`\`\n${stdout.trim()}\n\`\`\``)
  }

  // Add suggested actions on failure
  if (exitCode !== 0 && diagnostics.length > 0) {
    parts.push(`\n## Suggested Actions`)
    const errorTypes = new Set(diagnostics.map((d) => categorizeError(d)))
    if (errorTypes.has("unknown_opcode")) {
      parts.push("- Check opcode spelling and ensure required plugins are loaded (e.g., add `-d` flag or check opcode name)")
    }
    if (errorTypes.has("syntax")) {
      parts.push("- Review the indicated line(s) for syntax errors: missing semicolons, unmatched brackets, or incorrect opcode arguments")
    }
    if (errorTypes.has("type_mismatch")) {
      parts.push("- Verify variable types: i-rate vs k-rate vs a-rate. Ensure chnget variable prefix matches the expected rate")
    }
    if (errorTypes.has("missing_instrument")) {
      parts.push("- Ensure all referenced instruments are defined in CsInstruments and score events reference valid instrument numbers/names")
    }
    if (errorTypes.has("other")) {
      parts.push("- Read the error messages carefully and fix the issues at the indicated line numbers")
    }
  }

  return parts.join("\n")
}

function categorizeError(d: CsoundDiagnostic): string {
  const msg = d.message.toLowerCase()
  if (msg.includes("unknown opcode") || msg.includes("not found")) return "unknown_opcode"
  if (msg.includes("syntax") || msg.includes("unexpected") || msg.includes("parse")) return "syntax"
  if (msg.includes("type") || msg.includes("mismatch") || msg.includes("rate")) return "type_mismatch"
  if (msg.includes("instrument") || msg.includes("instr")) return "missing_instrument"
  return "other"
}
