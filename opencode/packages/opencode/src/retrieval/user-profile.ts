import fs from "fs/promises"
import path from "path"
import os from "os"
import { Log } from "../util/log"

export namespace UserProfile {
  const log = Log.create({ service: "retrieval.user-profile" })

  export type ExpertiseLevel = "beginner" | "intermediate" | "advanced"
  export type NarrationDepth = "low" | "medium" | "high"

  export interface Profile {
    expertiseLevel: ExpertiseLevel
    preferredTechniques: Record<string, number> // technique name → usage count
    sessionPatterns: string[][] // recent workflow step sequences (last 10 sessions)
    narrationDepth: NarrationDepth
    totalSessions: number
    totalRenders: number
    lastUpdated: number
    version: number
    favoriteTextures?: string[] // persisted texture/mood descriptors across sessions
    sonicReferences?: Record<string, string> // reference label → description, persists across sessions
    challengeProgress?: Record<string, { started: boolean; completed: boolean; hintsUsed: number }>
    autoVariationEnabled?: boolean
  }

  const DEFAULT_PROFILE: Profile = {
    expertiseLevel: "beginner",
    preferredTechniques: {},
    sessionPatterns: [],
    narrationDepth: "medium",
    totalSessions: 0,
    totalRenders: 0,
    lastUpdated: Date.now(),
    version: 1,
  }

  let cached: Profile | null = null

  function profilePath(): string {
    return path.join(os.homedir(), ".drc", "profile.json")
  }

  export async function load(): Promise<Profile> {
    if (cached) return cached
    try {
      const raw = await fs.readFile(profilePath(), "utf-8")
      cached = { ...DEFAULT_PROFILE, ...JSON.parse(raw) }
      return cached!
    } catch {
      cached = { ...DEFAULT_PROFILE }
      return cached
    }
  }

  async function save(): Promise<void> {
    if (!cached) return
    cached.lastUpdated = Date.now()
    try {
      const dir = path.dirname(profilePath())
      await fs.mkdir(dir, { recursive: true })
      await fs.writeFile(profilePath(), JSON.stringify(cached, null, 2), "utf-8")
    } catch (e) {
      log.error("failed to save profile", { error: e })
    }
  }

  export type Signal =
    | "compile_success"
    | "compile_failure"
    | "render_success"
    | "render_failure"
    | "used_opcode"
    | "asked_explanation"
    | "skipped_narration"
    | "read_narration"
    | "session_start"
    | "technique_reuse"
    | "user_skip_narration"
    | "user_read_narration"

  /**
   * Record a signal to update the user profile.
   */
  export async function record(signal: Signal, metadata?: Record<string, any>): Promise<void> {
    const profile = await load()

    switch (signal) {
      case "session_start":
        profile.totalSessions++
        break

      case "render_success":
        profile.totalRenders++
        break

      case "compile_success":
        // Successful compiles suggest growing expertise
        if (profile.totalRenders > 20 && profile.expertiseLevel === "beginner") {
          profile.expertiseLevel = "intermediate"
        }
        if (profile.totalRenders > 100 && profile.expertiseLevel === "intermediate") {
          profile.expertiseLevel = "advanced"
        }
        break

      case "used_opcode":
        if (metadata?.opcode) {
          const technique = categorizeTechnique(metadata.opcode)
          if (technique) {
            profile.preferredTechniques[technique] = (profile.preferredTechniques[technique] || 0) + 1
          }
        }
        break

      case "asked_explanation":
        // Asking for explanations suggests lower expertise
        if (profile.totalSessions < 5) {
          profile.expertiseLevel = "beginner"
        }
        break

      case "user_skip_narration":
      case "skipped_narration":
        // User skipping narrations → reduce depth
        if (profile.narrationDepth === "high") profile.narrationDepth = "medium"
        else if (profile.narrationDepth === "medium") profile.narrationDepth = "low"
        break

      case "user_read_narration":
      case "read_narration":
        // User reading narrations → maintain or increase depth
        if (profile.narrationDepth === "low") profile.narrationDepth = "medium"
        break

      case "technique_reuse":
        if (metadata?.technique) {
          profile.preferredTechniques[metadata.technique] =
            (profile.preferredTechniques[metadata.technique] || 0) + 1
        }
        break
    }

    await save()
  }

  /**
   * Record a workflow step sequence for pattern analysis.
   */
  export async function recordSessionPattern(steps: string[]): Promise<void> {
    const profile = await load()
    profile.sessionPatterns.push(steps)
    // Keep only last 10 sessions
    if (profile.sessionPatterns.length > 10) {
      profile.sessionPatterns = profile.sessionPatterns.slice(-10)
    }
    await save()
  }

  /**
   * Generate a context string for system prompt injection.
   */
  export async function promptContext(): Promise<string | null> {
    const profile = await load()

    // Don't inject context for brand new users
    if (profile.totalSessions < 2) return null

    const parts: string[] = []
    parts.push(`User expertise: ${profile.expertiseLevel}`)

    // Top 3 preferred techniques
    const topTechniques = Object.entries(profile.preferredTechniques)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([t]) => t)

    if (topTechniques.length > 0) {
      parts.push(`Preferred techniques: ${topTechniques.join(", ")}`)
    }

    // Most common workflow pattern
    if (profile.sessionPatterns.length >= 3) {
      const firstSteps = profile.sessionPatterns.map(s => s.slice(0, 3).join("→"))
      const counts = new Map<string, number>()
      for (const s of firstSteps) {
        counts.set(s, (counts.get(s) || 0) + 1)
      }
      const mostCommon = [...counts.entries()].sort((a, b) => b[1] - a[1])[0]
      if (mostCommon && mostCommon[1] >= 2) {
        parts.push(`Typical workflow: ${mostCommon[0]}`)
      }
    }

    parts.push(`Sessions: ${profile.totalSessions}, Renders: ${profile.totalRenders}`)

    return `<user-profile>\n${parts.join("\n")}\n</user-profile>`
  }

  /**
   * Get the user's preferred narration depth.
   */
  export async function getNarrationDepth(): Promise<NarrationDepth> {
    const profile = await load()
    return profile.narrationDepth
  }

  function categorizeTechnique(opcode: string): string | null {
    const lower = opcode.toLowerCase()
    const techniques: Record<string, string[]> = {
      "subtractive synthesis": ["moogladder", "lpf18", "butterlp", "butterhp", "statevar", "vco2", "noise"],
      "FM synthesis": ["foscili", "foscil", "fm_voice"],
      "additive synthesis": ["oscili", "poscil", "buzz", "gbuzz"],
      "granular synthesis": ["partikkel", "grain", "grain3", "fof", "fof2"],
      "physical modeling": ["pluck", "wgbow", "wgflute", "wgclar", "wgbrass"],
      "spectral processing": ["pvsanal", "pvsynth", "pvsfilter", "pvsmooth"],
      "wavetable synthesis": ["tablei", "table", "oscili"],
      "reverb": ["reverbsc", "freeverb", "nreverb"],
      "delay effects": ["delay", "vdelay3", "flanger", "chorus"],
      "distortion": ["distort1", "clip", "powershape", "fold", "decimator"],
    }
    for (const [technique, opcodes] of Object.entries(techniques)) {
      if (opcodes.includes(lower)) return technique
    }
    return null
  }
}
