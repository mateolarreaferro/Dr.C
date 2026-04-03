import z from "zod"
import { Tool } from "./tool"
import { Log } from "../util/log"
import DESCRIPTION from "./gesture_to_envelope.txt"

const log = Log.create({ service: "tool.gesture-to-envelope" })

export const GestureToEnvelopeTool = Tool.define(
  "gesture_to_envelope",
  {
    description: DESCRIPTION,
    parameters: z.object({
      points: z
        .array(
          z.object({
            time: z.number().min(0).describe("Time in seconds"),
            value: z.number().describe("Value at this time point"),
          }),
        )
        .min(2)
        .describe("Array of time/value points defining the envelope shape"),
      targetParam: z
        .string()
        .describe("Csound variable name to assign (e.g., 'kAmp', 'kCutoff')"),
      opcodePreference: z
        .enum(["linseg", "expseg", "linsegr", "gen07"])
        .optional()
        .describe("Preferred Csound opcode for envelope generation"),
    }),
    async execute(params, ctx) {
      const { targetParam, opcodePreference } = params
      let { points } = params

      // Normalize: sort by time, ensure monotonically increasing
      points = [...points].sort((a, b) => a.time - b.time)

      // Remove duplicate timestamps (keep first)
      const deduped: Array<{ time: number; value: number }> = []
      for (const p of points) {
        if (deduped.length === 0 || p.time > deduped[deduped.length - 1].time) {
          deduped.push(p)
        }
      }
      points = deduped

      if (points.length < 2) {
        throw new Error("Need at least 2 unique time points to generate an envelope")
      }

      const opcode = opcodePreference ?? "linseg"
      let code: string
      let explanation: string

      switch (opcode) {
        case "linseg":
          code = generateLinseg(targetParam, points)
          explanation = "Linear segment envelope. Values transition linearly between breakpoints."
          break

        case "expseg":
          code = generateExpseg(targetParam, points)
          explanation = "Exponential segment envelope. Values transition exponentially (more natural for amplitude/frequency). Note: zero values are clamped to 0.001."
          break

        case "linsegr":
          code = generateLinsegr(targetParam, points)
          explanation = "Linear segments with a release segment appended. The envelope continues during note-off with the final segment as release."
          break

        case "gen07":
          code = generateGen07(targetParam, points)
          explanation = "GEN07 f-table with linear segments. Table is read with tablei for smooth interpolation. Useful for cyclic or reusable shapes."
          break
      }

      // Build output
      const parts: string[] = []
      parts.push(`## Generated Envelope: ${targetParam}`)
      parts.push("")
      parts.push(`Opcode: \`${opcode}\``)
      parts.push(explanation)
      parts.push("")
      parts.push(`### Breakpoints (${points.length})`)
      for (const p of points) {
        parts.push(`  ${p.time.toFixed(3)}s -> ${p.value}`)
      }
      parts.push("")
      parts.push(`### Csound Code`)
      parts.push("```csound")
      parts.push(code)
      parts.push("```")
      parts.push("")
      parts.push("Paste this into your instrument block. Adjust the final values or timing as needed.")

      log.info("gesture_to_envelope", {
        opcode,
        targetParam,
        pointCount: points.length,
        totalDuration: points[points.length - 1].time - points[0].time,
      })

      return {
        title: `${opcode} envelope for ${targetParam}`,
        output: parts.join("\n"),
        metadata: {
          code,
          opcode,
          targetParam,
          pointCount: points.length,
        },
      }
    },
  },
)

function generateLinseg(
  target: string,
  points: Array<{ time: number; value: number }>,
): string {
  // linseg v0, dur0, v1, dur1, v2, ...
  const segments: string[] = []
  segments.push(String(points[0].value))

  for (let i = 1; i < points.length; i++) {
    const dur = points[i].time - points[i - 1].time
    segments.push(String(dur))
    segments.push(String(points[i].value))
  }

  return `${target} linseg ${segments.join(", ")}`
}

function generateExpseg(
  target: string,
  points: Array<{ time: number; value: number }>,
): string {
  // expseg requires all values > 0, clamp zeros to 0.001
  const safePoints = points.map((p) => ({
    time: p.time,
    value: p.value <= 0 ? 0.001 : p.value,
  }))

  const segments: string[] = []
  segments.push(String(safePoints[0].value))

  for (let i = 1; i < safePoints.length; i++) {
    const dur = safePoints[i].time - safePoints[i - 1].time
    segments.push(String(dur))
    segments.push(String(safePoints[i].value))
  }

  const code = `${target} expseg ${segments.join(", ")}`

  // Add comment if values were clamped
  const hadZeros = points.some((p) => p.value <= 0)
  if (hadZeros) {
    return `; Note: zero values clamped to 0.001 (expseg requires positive values)\n${code}`
  }
  return code
}

function generateLinsegr(
  target: string,
  points: Array<{ time: number; value: number }>,
): string {
  // linsegr: all segments except the last are attack, the last segment is the release
  if (points.length < 3) {
    // With only 2 points, treat the second as the release target
    const dur = points[1].time - points[0].time
    return `${target} linsegr ${points[0].value}, ${dur}, ${points[1].value}`
  }

  // Attack segments (all but last)
  const attackSegments: string[] = []
  attackSegments.push(String(points[0].value))

  for (let i = 1; i < points.length - 1; i++) {
    const dur = points[i].time - points[i - 1].time
    attackSegments.push(String(dur))
    attackSegments.push(String(points[i].value))
  }

  // Release segment (last point)
  const releaseDur = points[points.length - 1].time - points[points.length - 2].time
  const releaseValue = points[points.length - 1].value

  return `${target} linsegr ${attackSegments.join(", ")}, ${releaseDur}, ${releaseValue}`
}

function generateGen07(
  target: string,
  points: Array<{ time: number; value: number }>,
): string {
  // GEN07: linear segments stored in an f-table
  // f iTable 0 iSize 7 v0 n0 v1 n1 v2 ...
  // where n is the number of table points for that segment

  const tableSize = 8192 // Power of 2
  const totalDuration = points[points.length - 1].time - points[0].time

  const genArgs: string[] = []
  genArgs.push(String(points[0].value))

  for (let i = 1; i < points.length; i++) {
    const dur = points[i].time - points[i - 1].time
    const segmentPoints = Math.round((dur / totalDuration) * tableSize)
    genArgs.push(String(segmentPoints))
    genArgs.push(String(points[i].value))
  }

  const tableName = `gi${target.replace(/^k/, "").replace(/^a/, "")}Table`
  const lines: string[] = []
  lines.push(`; GEN07 table for ${target}`)
  lines.push(`${tableName} ftgen 0, 0, ${tableSize}, 7, ${genArgs.join(", ")}`)
  lines.push("")
  lines.push(`; Read table over note duration`)
  lines.push(`iDur = p3`)
  lines.push(`${target} tablei (timeinsts() / iDur) * ${tableSize}, ${tableName}`)

  return lines.join("\n")
}
