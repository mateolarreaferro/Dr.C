import z from "zod"
import { Tool } from "./tool"
import DESCRIPTION from "./error_parse.txt"

export interface CsoundDiagnostic {
  severity: "error" | "warning" | "info"
  line: number | null
  col: number | null
  message: string
  opcode: string | null
}

/**
 * Parse Csound stderr into structured diagnostics.
 * Exported for use by other tools (csound_compile, validation pipeline).
 */
export function parseCsoundErrors(stderr: string): CsoundDiagnostic[] {
  const diagnostics: CsoundDiagnostic[] = []
  const lines = stderr.split("\n")

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    if (!line) continue

    let diagnostic: CsoundDiagnostic | null = null

    // Pattern: "error:  <message> line <N>:"
    const errorLine = line.match(/^error:\s+(.+?)(?:\s+line\s+(\d+))?:?\s*$/i)
    if (errorLine) {
      diagnostic = {
        severity: "error",
        line: errorLine[2] ? parseInt(errorLine[2]) : null,
        col: null,
        message: errorLine[1].trim(),
        opcode: null,
      }
    }

    // Pattern: "line <N>: error: <message>"
    if (!diagnostic) {
      const lineError = line.match(/^line\s+(\d+):\s*(error|warning):\s*(.+)$/i)
      if (lineError) {
        diagnostic = {
          severity: lineError[2].toLowerCase() as "error" | "warning",
          line: parseInt(lineError[1]),
          col: null,
          message: lineError[3].trim(),
          opcode: null,
        }
      }
    }

    // Pattern: "error: <opcode> (<message>)" or just "error: <message>"
    if (!diagnostic) {
      const genericError = line.match(/^(error|warning):\s*(.+)$/i)
      if (genericError) {
        const msg = genericError[2].trim()
        const opcodeMatch = msg.match(/^(\w+)\s+(.+)$/)
        diagnostic = {
          severity: genericError[1].toLowerCase() as "error" | "warning",
          line: null,
          col: null,
          message: msg,
          opcode: opcodeMatch ? opcodeMatch[1] : null,
        }
      }
    }

    // Pattern: "*** can't compile <opcode>" or "Cannot find opcode: <opcode>"
    if (!diagnostic) {
      const cantCompile = line.match(/(?:\*{3}\s*)?(?:can'?t compile|Cannot find opcode)[:\s]+(\w+)/i)
      if (cantCompile) {
        diagnostic = {
          severity: "error",
          line: null,
          col: null,
          message: line,
          opcode: cantCompile[1],
        }
      }
    }

    // Pattern: "Str...: line <N>: <message>"
    if (!diagnostic) {
      const strLineError = line.match(/^Str[^:]*:\s*line\s+(\d+):\s*(.+)$/i)
      if (strLineError) {
        diagnostic = {
          severity: "error",
          line: parseInt(strLineError[1]),
          col: null,
          message: strLineError[2].trim(),
          opcode: null,
        }
      }
    }

    // Pattern: "Csound tance: ... line <N>"
    if (!diagnostic) {
      const csoundLine = line.match(/line\s+(\d+)/i)
      if (csoundLine && (line.toLowerCase().includes("error") || line.toLowerCase().includes("illegal"))) {
        diagnostic = {
          severity: "error",
          line: parseInt(csoundLine[1]),
          col: null,
          message: line,
          opcode: null,
        }
      }
    }

    if (diagnostic) {
      diagnostics.push(diagnostic)
    }
  }

  return diagnostics
}

export const ErrorParseTool = Tool.define(
  "error_parse",
  {
    description: DESCRIPTION,
    parameters: z.object({
      stderr: z.string().describe("Raw stderr output from a Csound compilation"),
    }),
    async execute(params) {
      const diagnostics = parseCsoundErrors(params.stderr)

      const output = JSON.stringify({ diagnostics }, null, 2)

      return {
        title: `Parsed ${diagnostics.length} diagnostics`,
        metadata: {
          diagnosticCount: diagnostics.length,
          hasErrors: diagnostics.some((d) => d.severity === "error"),
          hasWarnings: diagnostics.some((d) => d.severity === "warning"),
        },
        output,
      }
    },
  },
)
