import fs from "fs/promises"
import path from "path"
import { KnowledgeSources } from "./knowledge-sources"
import { Log } from "../util/log"

export namespace RetrievalFeedback {
  const log = Log.create({ service: "retrieval.feedback" })

  export type Signal =
    | "compile_success"
    | "compile_failure"
    | "user_revert"
    | "session_continues"
    | "alternative_selected"
    | "render_success"
    | "audio_silent"
    | "audio_clipping"
    | "user_thumbs_up"
    | "user_thumbs_down"

  const SIGNAL_VALUES: Record<Signal, number> = {
    compile_success: 1.0,
    compile_failure: -0.5,
    user_revert: -1.0,
    session_continues: 0.1,
    alternative_selected: 0.5,
    render_success: 0.8,
    audio_silent: -0.3,
    audio_clipping: -0.2,
    user_thumbs_up: 1.5,
    user_thumbs_down: -1.5,
  }

  const ALPHA = 0.1 // EMA smoothing factor
  const DECAY_RATE = 0.01 // Score drift toward neutral per day
  const BOOST_MIN = 0.5
  const BOOST_MAX = 2.0

  interface FeedbackEntry {
    score: number
    lastUpdated: number // timestamp
    count: number
  }

  interface FeedbackStore {
    entries: Record<string, FeedbackEntry>
    version: number
  }

  let store: FeedbackStore | null = null

  function feedbackPath(): string {
    return path.join(KnowledgeSources.dataDir(), "feedback.json")
  }

  async function loadStore(): Promise<FeedbackStore> {
    if (store) return store
    try {
      const raw = await fs.readFile(feedbackPath(), "utf-8")
      store = JSON.parse(raw)
      return store!
    } catch {
      store = { entries: {}, version: 1 }
      return store
    }
  }

  async function saveStore(): Promise<void> {
    if (!store) return
    try {
      await fs.mkdir(path.dirname(feedbackPath()), { recursive: true })
      await fs.writeFile(feedbackPath(), JSON.stringify(store), "utf-8")
    } catch (e) {
      log.error("failed to save feedback", { error: e })
    }
  }

  function applyTimeDecay(entry: FeedbackEntry): number {
    const daysSince = (Date.now() - entry.lastUpdated) / (1000 * 60 * 60 * 24)
    // Drift score toward 0 (neutral)
    const decayed = entry.score * Math.pow(1 - DECAY_RATE, daysSince)
    return decayed
  }

  /**
   * Record feedback for chunks used in a retrieval-aided turn.
   */
  export async function record(
    _sessionID: string,
    _query: string,
    chunkIDs: string[],
    signal: Signal,
  ): Promise<void> {
    const s = await loadStore()
    const signalValue = SIGNAL_VALUES[signal]

    for (const chunkID of chunkIDs) {
      const existing = s.entries[chunkID]
      if (existing) {
        // EMA update
        const decayed = applyTimeDecay(existing)
        existing.score = ALPHA * signalValue + (1 - ALPHA) * decayed
        existing.lastUpdated = Date.now()
        existing.count++
      } else {
        s.entries[chunkID] = {
          score: ALPHA * signalValue,
          lastUpdated: Date.now(),
          count: 1,
        }
      }
    }

    await saveStore()
  }

  /**
   * Get boost multipliers for all chunks with feedback.
   * Returns Map<chunkID, multiplier> where multiplier is in [0.5, 2.0].
   */
  export async function getBoosts(): Promise<Map<string, number>> {
    const s = await loadStore()
    const boosts = new Map<string, number>()

    for (const [chunkID, entry] of Object.entries(s.entries)) {
      const score = applyTimeDecay(entry)
      // Clamp to [BOOST_MIN, BOOST_MAX]
      const boost = Math.max(BOOST_MIN, Math.min(BOOST_MAX, 0.5 + score))
      if (boost !== 1.0) {
        boosts.set(chunkID, boost)
      }
    }

    return boosts
  }

  /**
   * Derive the appropriate signal from tool outcomes in a processor turn.
   * Checks for render results first (stronger signal), then compile, then fallback.
   */
  export function deriveSignal(
    toolResults: Array<{ tool: string; success: boolean; metadata?: any }>,
  ): Signal {
    // Check for render results first (stronger signal than just compile)
    const renderResult = toolResults.find((r) => r.tool === "csound_render")
    if (renderResult) {
      if (renderResult.success) {
        // If metadata has audio analysis signal, use it
        const audioSignal = renderResult.metadata?.audioSignal
        if (audioSignal === "audio_silent") return "audio_silent"
        if (audioSignal === "audio_clipping") return "audio_clipping"
        return "render_success"
      }
      return "compile_failure"
    }

    // Check for compile results
    const compileResult = toolResults.find(
      (r) => r.tool === "csound_compile" || r.tool === "csound_smoke",
    )
    if (compileResult) {
      return compileResult.success ? "compile_success" : "compile_failure"
    }

    // Default: session continues (weakly positive)
    return "session_continues"
  }
}
