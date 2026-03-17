import { Log } from "../util/log"
import { UserProfile } from "./user-profile"

export namespace ExpertiseTracker {
  const log = Log.create({ service: "retrieval.expertise-tracker" })

  // Patterns that suggest different expertise levels
  const EXPLANATION_PATTERNS = [
    /what\s+(is|does|are)\b/i,
    /how\s+does?\b/i,
    /explain\b/i,
    /what's\s+the\s+difference/i,
    /can\s+you\s+explain/i,
    /i\s+don't\s+understand/i,
    /what\s+do\s+you\s+mean/i,
  ]

  const ADVANCED_PATTERNS = [
    /\bUDO\b/,
    /\bopcode\s+\w+,\s*\w/i, // custom opcode definition syntax
    /\bftgen\b/i,
    /\bschedule\b/i,
    /\bscoreline_i\b/i,
    /\bsetksmps\b/i,
    /\bsr\s*=\s*\d+/i,
    /\b0dbfs\b/i,
    /\bnchnls\b/i,
    /\bpvs\w+\b/i, // spectral opcodes
  ]

  const OPCODE_PATTERN =
    /\b(oscili?|vco2|moogladder|reverbsc|freeverb|foscili?|pluck|wg\w+|noise|pinkish|butterlp|butterhp|statevar|lpf18|delay|vdelay3|distort1|clip|madsr|linsegr?|expsegr?|lfo|metro|dust2?|poscil3?)\b/gi

  /**
   * Analyze a user message for expertise signals and record them.
   */
  export async function analyzeMessage(text: string): Promise<void> {
    try {
      // Check for explanation requests (suggests beginner/intermediate)
      const asksExplanation = EXPLANATION_PATTERNS.some((p) => p.test(text))
      if (asksExplanation) {
        await UserProfile.record("asked_explanation")
      }

      // Check for advanced opcode usage
      const usesAdvanced = ADVANCED_PATTERNS.some((p) => p.test(text))
      if (usesAdvanced) {
        // Advanced users tend to reference these patterns
        const profile = await UserProfile.load()
        if (profile.totalSessions > 5 && profile.expertiseLevel !== "advanced") {
          // Don't auto-promote too quickly, but track it
        }
      }

      // Extract opcode mentions for technique tracking
      const opcodes = text.match(OPCODE_PATTERN) || []
      const seen = new Set<string>()
      for (const opcode of opcodes) {
        const lower = opcode.toLowerCase()
        if (seen.has(lower)) continue
        seen.add(lower)
        await UserProfile.record("used_opcode", { opcode: lower })
      }
    } catch (e) {
      log.error("expertise analysis failed", { error: e })
    }
  }

  /**
   * Analyze tool results for expertise signals.
   */
  export async function analyzeToolResult(toolName: string, success: boolean): Promise<void> {
    try {
      if (toolName === "csound_render") {
        await UserProfile.record(success ? "render_success" : "render_failure")
      }
      if (toolName === "csound_compile" || toolName === "csound_smoke") {
        await UserProfile.record(success ? "compile_success" : "compile_failure")
      }
    } catch (e) {
      log.error("tool result analysis failed", { error: e })
    }
  }
}
