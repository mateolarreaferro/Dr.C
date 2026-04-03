import z from "zod"
import path from "path"
import fs from "fs/promises"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"
import { CsdParser } from "../csound/parser"
import DESCRIPTION from "./suggest_params.txt"

const log = Log.create({ service: "tool.suggest-params" })

interface ParamSuggestion {
  param: string
  currentValue: number
  suggestedValue: number
  reason: string
}

// Semantic role inference from parameter names
type SemanticRole =
  | "cutoff"
  | "resonance"
  | "amplitude"
  | "frequency"
  | "rate"
  | "depth"
  | "feedback"
  | "mix"
  | "attack"
  | "decay"
  | "sustain"
  | "release"
  | "pan"
  | "detune"
  | "ratio"
  | "width"
  | "gain"
  | "unknown"

function inferRole(name: string): SemanticRole {
  const lower = name.toLowerCase()
  if (lower.includes("cutoff") || lower.includes("filt") || lower.includes("freq") && lower.includes("filt"))
    return "cutoff"
  if (lower.includes("reson") || lower.includes("res") && !lower.includes("release")) return "resonance"
  if (lower.includes("amp") || lower.includes("level") || lower.includes("vol")) return "amplitude"
  if (lower.includes("freq") || lower.includes("pitch") || lower.includes("hz")) return "frequency"
  if (lower.includes("rate") || lower.includes("speed")) return "rate"
  if (lower.includes("depth") || lower.includes("amount")) return "depth"
  if (lower.includes("feedback") || lower.includes("fb") || lower.includes("fdbk")) return "feedback"
  if (lower.includes("mix") || lower.includes("wet") || lower.includes("dry")) return "mix"
  if (lower.includes("attack") || lower.includes("att")) return "attack"
  if (lower.includes("decay") || lower.includes("dec")) return "decay"
  if (lower.includes("sustain") || lower.includes("sus")) return "sustain"
  if (lower.includes("release") || lower.includes("rel")) return "release"
  if (lower.includes("pan")) return "pan"
  if (lower.includes("detune") || lower.includes("spread")) return "detune"
  if (lower.includes("ratio") || lower.includes("mult")) return "ratio"
  if (lower.includes("width")) return "width"
  if (lower.includes("gain")) return "gain"
  return "unknown"
}

// Default ranges for parameter roles
const ROLE_RANGES: Record<SemanticRole, [number, number]> = {
  cutoff: [20, 12000],
  resonance: [0, 1],
  amplitude: [0, 1],
  frequency: [20, 8000],
  rate: [0.01, 20],
  depth: [0, 1],
  feedback: [0, 0.99],
  mix: [0, 1],
  attack: [0.001, 2],
  decay: [0.01, 5],
  sustain: [0, 1],
  release: [0.01, 10],
  pan: [0, 1],
  detune: [0, 100],
  ratio: [0.25, 8],
  width: [0, 1],
  gain: [0, 2],
  unknown: [0, 1],
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value))
}

function suggestForFocus(
  focus: string | undefined,
  params: Array<{ name: string; value: number; role: SemanticRole; range: [number, number] }>,
): ParamSuggestion[] {
  const suggestions: ParamSuggestion[] = []
  const lower = (focus ?? "").toLowerCase()

  for (const p of params) {
    let suggested: number | null = null
    let reason = ""

    if (lower.includes("dark") || lower.includes("warm") || lower.includes("mellow")) {
      if (p.role === "cutoff") {
        suggested = clamp(p.value * 0.5, p.range[0], p.range[1])
        reason = "Lower cutoff for darker, warmer tone"
      } else if (p.role === "resonance") {
        suggested = clamp(p.value * 0.7, p.range[0], p.range[1])
        reason = "Reduce resonance for smoother character"
      } else if (p.role === "gain" || p.role === "amplitude") {
        suggested = clamp(p.value * 0.85, p.range[0], p.range[1])
        reason = "Slightly lower level for warmth"
      }
    }

    if (lower.includes("bright") || lower.includes("crisp") || lower.includes("sharp")) {
      if (p.role === "cutoff") {
        suggested = clamp(p.value * 2, p.range[0], p.range[1])
        reason = "Raise cutoff for brighter tone"
      } else if (p.role === "resonance") {
        suggested = clamp(p.value * 1.3 + 0.1, p.range[0], p.range[1])
        reason = "Increase resonance for emphasis at cutoff"
      }
    }

    if (lower.includes("movement") || lower.includes("alive") || lower.includes("organic")) {
      if (p.role === "rate") {
        suggested = clamp(p.value * 1.5 + 0.5, p.range[0], p.range[1])
        reason = "Increase modulation rate for more movement"
      } else if (p.role === "depth") {
        suggested = clamp(p.value * 1.8 + 0.1, p.range[0], p.range[1])
        reason = "Deepen modulation for more noticeable movement"
      } else if (p.role === "detune") {
        suggested = clamp(p.value + 5, p.range[0], p.range[1])
        reason = "Add slight detuning for chorusing effect"
      }
    }

    if (lower.includes("experimental") || lower.includes("wild") || lower.includes("extreme")) {
      if (p.role === "feedback") {
        suggested = clamp(p.value * 1.5 + 0.3, p.range[0], p.range[1])
        reason = "Push feedback toward self-oscillation territory"
      } else if (p.role === "resonance") {
        suggested = clamp(0.85, p.range[0], p.range[1])
        reason = "High resonance for aggressive, screaming filter"
      } else if (p.role === "ratio") {
        suggested = clamp(Math.round(p.value * 3.7), p.range[0], p.range[1])
        reason = "Non-standard ratio for inharmonic, metallic tones"
      } else if (p.role === "depth") {
        suggested = clamp(p.range[1] * 0.9, p.range[0], p.range[1])
        reason = "Near-maximum modulation depth for extreme effect"
      } else if (p.role === "rate") {
        suggested = clamp(p.range[1] * 0.7, p.range[0], p.range[1])
        reason = "Fast modulation rate pushing into audio-rate territory"
      }
    }

    if (lower.includes("soft") || lower.includes("gentle") || lower.includes("quiet")) {
      if (p.role === "amplitude" || p.role === "gain") {
        suggested = clamp(p.value * 0.5, p.range[0], p.range[1])
        reason = "Reduce amplitude for softer sound"
      } else if (p.role === "attack") {
        suggested = clamp(p.value * 2 + 0.1, p.range[0], p.range[1])
        reason = "Slower attack for gentler onset"
      } else if (p.role === "release") {
        suggested = clamp(p.value * 1.5 + 0.2, p.range[0], p.range[1])
        reason = "Longer release for smoother decay"
      }
    }

    // General exploration when no specific focus matches
    if (!focus && suggested === null) {
      // Suggest moderate variation for interesting params
      if (p.role === "cutoff" || p.role === "resonance" || p.role === "rate" || p.role === "depth") {
        const direction = Math.random() > 0.5 ? 1.3 : 0.7
        suggested = clamp(p.value * direction, p.range[0], p.range[1])
        reason = `Explore ${direction > 1 ? "higher" : "lower"} ${p.role} for tonal variation`
      }
    }

    if (suggested !== null && Math.abs(suggested - p.value) > 0.001) {
      suggestions.push({
        param: p.name,
        currentValue: p.value,
        suggestedValue: Math.round(suggested * 1000) / 1000,
        reason,
      })
    }
  }

  return suggestions
}

export const SuggestParamsTool = Tool.define(
  "suggest_params",
  {
    description: DESCRIPTION,
    parameters: z.object({
      focus: z
        .string()
        .optional()
        .describe("Direction hint (e.g., 'darker', 'more movement', 'experimental', 'brighter', 'softer')"),
    }),
    async execute(params, ctx) {
      const { focus } = params

      // Find the current CSD in session workspace
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        throw new Error("No active workspace. Write a CSD first before using suggest_params.")
      }

      const tempDir = wsStatus.tempDir
      let csdPath: string | undefined

      try {
        const entries = await fs.readdir(tempDir)
        for (const entry of entries) {
          if (path.extname(entry).toLowerCase() === ".csd" && !entry.startsWith("variation-")) {
            csdPath = path.join(tempDir, entry)
            break
          }
        }
      } catch {
        throw new Error(`Could not read workspace directory: ${tempDir}`)
      }

      if (!csdPath) throw new Error("No CSD file found in workspace.")

      // Parse CSD and extract k-rate parameters
      const csdContent = await Bun.file(csdPath).text()
      const structure = CsdParser.parse(csdContent)

      const kParams = structure.parameters
        .filter((p) => p.rate === "k" && p.value && !isNaN(parseFloat(p.value)))
        .map((p) => {
          const role = inferRole(p.name)
          const range = p.range ?? ROLE_RANGES[role]
          return {
            name: p.name,
            value: parseFloat(p.value!),
            role,
            range,
            instrument: p.instrument,
          }
        })

      if (kParams.length === 0) {
        return {
          title: "No k-rate parameters found",
          output: "The current CSD has no detectable k-rate parameters to suggest variations for. Add some k-rate variables (kCutoff, kResonance, kRate, etc.) to enable parameter suggestions.",
          metadata: { csdPath, suggestions: [] },
        }
      }

      // Generate suggestions
      const suggestions = suggestForFocus(focus, kParams)

      // Build output
      const parts: string[] = []
      parts.push(`## Parameter Suggestions${focus ? ` — "${focus}"` : ""}`)
      parts.push("")

      // Show current params
      parts.push(`### Current Parameters (${kParams.length} detected)`)
      for (const p of kParams) {
        const instrLabel = p.instrument ? ` [instr ${p.instrument}]` : ""
        parts.push(`- \`${p.name}\` = ${p.value} (${p.role})${instrLabel}`)
      }
      parts.push("")

      if (suggestions.length === 0) {
        parts.push("No specific suggestions for the given focus. Try: 'darker', 'brighter', 'more movement', 'experimental', 'soft'")
      } else {
        parts.push(`### Suggestions (${suggestions.length})`)
        for (const s of suggestions) {
          const direction = s.suggestedValue > s.currentValue ? "+" : ""
          const delta = ((s.suggestedValue - s.currentValue) / s.currentValue * 100).toFixed(0)
          parts.push(`- **${s.param}**: ${s.currentValue} -> ${s.suggestedValue} (${direction}${delta}%)`)
          parts.push(`  _${s.reason}_`)
        }
      }

      log.info("suggest_params", { focus, paramCount: kParams.length, suggestionCount: suggestions.length })

      return {
        title: `${suggestions.length} parameter suggestions${focus ? ` for "${focus}"` : ""}`,
        output: parts.join("\n"),
        metadata: {
          csdPath,
          suggestions,
        },
      }
    },
  },
)
