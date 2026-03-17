import { Log } from "@/util/log"
import { spawn } from "child_process"

export namespace NarrationManager {
  const log = Log.create({ service: "narration" })

  const enabledMap = new Map<string, boolean>()
  const firedMap = new Map<string, number>() // sessionID → timestamp of last fire
  let ttsEnabled = false

  const COOLDOWN_MS = 30_000 // 30s cooldown between narrations per session

  export function hasFiredRecently(sessionID: string): boolean {
    const last = firedMap.get(sessionID) ?? 0
    return Date.now() - last < COOLDOWN_MS
  }

  export function markFired(sessionID: string): void {
    firedMap.set(sessionID, Date.now())
  }

  export function isEnabled(sessionID: string): boolean {
    return enabledMap.get(sessionID) ?? true
  }

  export function setEnabled(sessionID: string, enabled: boolean): void {
    enabledMap.set(sessionID, enabled)
  }

  export function isTTSEnabled(): boolean {
    return ttsEnabled
  }

  export function setTTSEnabled(enabled: boolean): void {
    ttsEnabled = enabled
  }

  /**
   * Speak narration text via macOS `say` (fire-and-forget, non-blocking).
   */
  function speak(text: string): void {
    if (!ttsEnabled) return
    try {
      // Strip the "Keywords:" line before speaking
      const spoken = text.replace(/\nKeywords:.*$/i, "").trim()
      const proc = spawn("say", ["-r", "185", spoken], {
        stdio: "ignore",
        detached: true,
      })
      proc.unref()
    } catch (e) {
      log.error("tts failed", { error: e })
    }
  }

  /**
   * Triggers a Haiku one-shot to generate educational narration.
   * Returns the narration text, or null if disabled/failed.
   * Non-blocking — designed to run in parallel with tool execution.
   */
  export async function trigger(
    sessionID: string,
    userQuery: string,
    csdContext?: string,
  ): Promise<string | null> {
    if (!isEnabled(sessionID)) return null

    try {
      const { generateText } = await import("ai")
      const { Provider } = await import("@/provider/provider")

      const model = await Provider.getModel("anthropic", "claude-haiku-4-5-20251001")
      const language = await Provider.getLanguage(model)

      const NARRATOR_PROMPT = (await import("./prompt/narrator.txt")).default

      const contextSnippet = csdContext
        ? `\nThe user's current CSD uses: ${csdContext.slice(0, 500)}`
        : ""

      const result = await generateText({
        model: language,
        system: NARRATOR_PROMPT,
        messages: [
          {
            role: "user",
            content: `User's query: "${userQuery}"${contextSnippet}\n\nProvide a brief educational narration.`,
          },
        ],
        maxTokens: 200,
        temperature: 0.7,
      })

      const text = result.text.trim()
      if (text) {
        speak(text)
      }
      return text || null
    } catch (e) {
      log.error("narration failed", { error: e })
      return null
    }
  }
}
