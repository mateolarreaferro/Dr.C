import { Log } from "../util/log"
import { MemoryStore } from "./store"

export namespace MemoryManager {
  const log = Log.create({ service: "memory.manager" })

  // Opcode → technique name mapping
  const OPCODE_TECHNIQUES: Record<string, string[]> = {
    "oscillator basics": ["oscili", "oscil", "poscil", "poscil3"],
    "FM synthesis": ["foscili", "foscil"],
    "additive synthesis": ["buzz", "gbuzz"],
    "granular synthesis": ["grain", "grain3", "partikkel", "fog", "fof", "fof2", "sndwarp", "granule"],
    "subtractive filtering": ["moogladder", "moogvcf", "lpf18", "butterlp", "butterhp", "butterbp", "statevar", "zdf_2pole", "bqrez"],
    "spectral processing": ["pvsanal", "pvsynth", "pvsfilter", "pvsmooth", "pvsmorph", "pvscross", "pvshift"],
    "physical modeling": ["pluck", "wgbow", "wgflute", "wgclar", "wgbrass", "streson"],
    "wavetable synthesis": ["tablei", "table", "tablew", "ftgen"],
    "sample playback": ["diskin2", "loscil", "flooper2", "sndloop"],
    "reverb": ["reverbsc", "freeverb", "nreverb", "alpass", "comb"],
    "delay effects": ["delay", "vdelay3", "delayr", "delayw", "flanger", "chorus"],
    "distortion": ["distort1", "clip", "powershape", "fold", "decimator"],
    "amplitude envelopes": ["madsr", "adsr", "linsegr", "expsegr", "transeg"],
    "modulation": ["lfo", "jspline", "rspline", "jitter", "randh", "randi"],
    "noise generation": ["noise", "pinkish", "dust", "dust2", "gausstrig"],
    "spatial processing": ["pan2", "vbap", "hrtfstat", "hrtfmove"],
  }

  // Aesthetic keywords to detect from user messages
  const AESTHETIC_KEYWORDS = [
    "dark", "warm", "harsh", "bright", "ambient", "noisy", "glitchy",
    "smooth", "gritty", "metallic", "organic", "ethereal", "heavy",
    "delicate", "thick", "thin", "lo-fi", "crispy", "lush", "spacious",
    "tight", "dry", "wet", "analog", "digital", "cold", "aggressive",
    "gentle", "dreamy", "abrasive", "subtle", "rich", "sparse",
  ]

  // Avoidance keywords
  const AVOIDANCE_KEYWORDS = [
    "don't like", "hate", "avoid", "no more", "too much", "not a fan",
    "dislike", "stop using", "never", "get rid of",
  ]

  /**
   * Detect techniques from CSD content by matching opcodes.
   */
  function detectTechniques(csdContent: string): string[] {
    const lower = csdContent.toLowerCase()
    const found = new Set<string>()

    for (const [technique, opcodes] of Object.entries(OPCODE_TECHNIQUES)) {
      for (const opcode of opcodes) {
        // Match opcode as a word boundary (not inside other words)
        const regex = new RegExp(`\\b${opcode}\\b`, "i")
        if (regex.test(lower)) {
          found.add(technique)
          break
        }
      }
    }

    return [...found]
  }

  /**
   * Extract opcode usage counts from CSD content.
   */
  function extractOpcodeUsage(csdContent: string): Record<string, number> {
    const counts: Record<string, number> = {}
    const allOpcodes = Object.values(OPCODE_TECHNIQUES).flat()

    for (const opcode of allOpcodes) {
      const regex = new RegExp(`\\b${opcode}\\b`, "gi")
      const matches = csdContent.match(regex)
      if (matches && matches.length > 0) {
        counts[opcode] = matches.length
      }
    }

    return counts
  }

  /**
   * Extract a short DSP snippet from CSD content (the core signal chain).
   */
  function extractDspSnippet(csdContent: string): string | undefined {
    const lines = csdContent.split("\n")
    const dspLines: string[] = []

    for (const line of lines) {
      const trimmed = line.trim()
      // Skip comments, empty lines, header lines
      if (!trimmed || trimmed.startsWith(";") || trimmed.startsWith("//")) continue
      if (/^(sr|ksmps|nchnls|0dbfs|seed)\s*=/.test(trimmed)) continue
      if (/^(instr|endin|opcode|endop|<|>)/.test(trimmed)) continue

      // Look for lines with audio/control rate operations
      if (/\b[ak][A-Z]/.test(trimmed) || /\bout[sch]?\b/.test(trimmed)) {
        dspLines.push(trimmed)
      }
    }

    if (dspLines.length === 0) return undefined
    // Return the first 5 DSP lines as a snippet
    return dspLines.slice(0, 5).join("\n")
  }

  /**
   * Extract signal chains from CSD (opcode sequences within instruments).
   */
  function extractSignalChains(csdContent: string): string[] {
    const lines = csdContent.split("\n")
    const chains: string[] = []
    let currentChain: string[] = []
    let inInstrument = false

    const allOpcodes = new Set(Object.values(OPCODE_TECHNIQUES).flat())

    for (const line of lines) {
      const trimmed = line.trim()
      if (/^instr\b/i.test(trimmed)) {
        inInstrument = true
        currentChain = []
        continue
      }
      if (/^endin\b/i.test(trimmed)) {
        if (currentChain.length >= 2) {
          chains.push(currentChain.join(" -> "))
        }
        inInstrument = false
        continue
      }

      if (!inInstrument) continue

      // Find opcodes in this line
      for (const opcode of allOpcodes) {
        const regex = new RegExp(`\\b${opcode}\\b`, "i")
        if (regex.test(trimmed)) {
          currentChain.push(opcode)
          break
        }
      }
    }

    return chains
  }

  /**
   * Generate a session summary using Haiku.
   * Called automatically when a session ends or is compacted.
   */
  export async function generateSessionSummary(sessionID: string): Promise<void> {
    try {
      const { Session } = await import("../session/index")
      const messages = await Session.messages({ sessionID, limit: 50 })

      if (messages.length === 0) return

      // Collect user text and tool results
      const userTexts: string[] = []
      let renderCount = 0
      let exported = false
      let csdContent = ""
      const startTime = messages[0]?.time?.created ?? Date.now()
      const endTime = messages[messages.length - 1]?.time?.created ?? Date.now()

      for (const msg of messages) {
        for (const part of msg.parts) {
          if (part.type === "text" && msg.role === "user") {
            userTexts.push(part.content)
          }
          if (part.type === "tool") {
            if (part.tool === "csound_render") renderCount++
            if (part.tool === "csound_export_html") exported = true
            // Capture last CSD content from tool metadata
            if (part.tool === "apply_csd_patch" || part.tool === "write") {
              const content = part.metadata?.csdContent || part.metadata?.content
              if (content && typeof content === "string") csdContent = content
            }
          }
        }
      }

      // Detect techniques from CSD
      const techniques = csdContent ? detectTechniques(csdContent) : []

      // Generate summary with Haiku
      const conversationSnippet = userTexts.slice(0, 10).join("\n").slice(0, 1500)
      const techniqueList = techniques.length > 0 ? `\nTechniques detected: ${techniques.join(", ")}` : ""

      let summaryText: string
      try {
        const { generateText } = await import("ai")
        const { Provider } = await import("../provider/provider")

        const model = await Provider.getModel("anthropic", "claude-haiku-4-5-20251001")
        const language = await Provider.getLanguage(model)

        const result = await generateText({
          model: language,
          system: "You summarize Csound sound design sessions. Be concise and specific about synthesis techniques, opcodes, and creative direction.",
          messages: [
            {
              role: "user",
              content: `Summarize this Csound sound design session in 3-5 sentences. Focus on: what was built, which techniques were used, the creative direction, and the outcome. Be specific about opcodes and synthesis methods.\n\nUser messages:\n${conversationSnippet}${techniqueList}\n\nRenders: ${renderCount}, Exported: ${exported}`,
            },
          ],
          maxTokens: 200,
          temperature: 0.3,
        })

        summaryText = result.text.trim()
      } catch (e) {
        // Fallback: generate a basic summary without LLM
        summaryText = `Session with ${renderCount} render(s). ${techniques.length > 0 ? `Techniques: ${techniques.join(", ")}.` : ""}${exported ? " Exported." : ""}`
        log.info("falling back to basic summary", { error: e })
      }

      const summary: MemoryStore.SessionSummary = {
        sessionID,
        timestamp: Date.now(),
        summary: summaryText,
        techniques,
        renderCount,
        exported,
        designTreeNodes: 0, // Design tree node count not easily accessible here
        duration: endTime - startTime,
      }

      await MemoryStore.saveSessionSummary(summary)
      log.info("session summary saved", { sessionID, techniques })
    } catch (e) {
      log.error("failed to generate session summary", { error: e, sessionID })
    }
  }

  /**
   * Extract and record techniques from a CSD.
   */
  export async function recordTechniquesFromCsd(
    sessionID: string,
    csdContent: string,
    outcome: "success" | "partial" | "failed",
  ): Promise<void> {
    try {
      const techniques = detectTechniques(csdContent)
      const snippet = extractDspSnippet(csdContent)

      for (const technique of techniques) {
        await MemoryStore.addTechniqueEntry(technique, {
          date: Date.now(),
          sessionID,
          description: `Used ${technique} in session`,
          outcome,
          csdSnippet: snippet,
        })
      }

      log.info("recorded techniques from CSD", { sessionID, techniques, outcome })
    } catch (e) {
      log.error("failed to record techniques", { error: e, sessionID })
    }
  }

  /**
   * Update sonic identity based on session activity.
   */
  export async function updateIdentityFromSession(sessionID: string): Promise<void> {
    try {
      const { Session } = await import("../session/index")
      const messages = await Session.messages({ sessionID, limit: 50 })

      const aesthetics: string[] = []
      const avoidances: string[] = []
      const artists: string[] = []
      let lastCsd = ""

      for (const msg of messages) {
        for (const part of msg.parts) {
          if (part.type !== "text" || msg.role !== "user") continue
          const text = part.content.toLowerCase()

          // Detect aesthetic preferences
          for (const keyword of AESTHETIC_KEYWORDS) {
            if (text.includes(keyword)) {
              aesthetics.push(keyword)
            }
          }

          // Detect avoidances
          for (const avoidPhrase of AVOIDANCE_KEYWORDS) {
            const idx = text.indexOf(avoidPhrase)
            if (idx >= 0) {
              // Extract a few words after the avoidance phrase
              const after = text.slice(idx + avoidPhrase.length, idx + avoidPhrase.length + 40).trim()
              const words = after.split(/\s+/).slice(0, 4).join(" ")
              if (words) avoidances.push(words)
            }
          }

          // Detect artist references (simple heuristic: look for "like X" or "inspired by X")
          const artistPatterns = [
            /(?:like|inspired by|similar to|reminds me of|think of|reference)\s+([A-Z][a-zA-Z\s]+?)(?:\.|,|$)/gi,
          ]
          for (const pattern of artistPatterns) {
            let match
            while ((match = pattern.exec(part.content)) !== null) {
              const artist = match[1].trim()
              if (artist.length > 2 && artist.length < 40) {
                artists.push(artist)
              }
            }
          }

          // Capture CSD content from tool results
          if (part.type === "tool" && (part.tool === "apply_csd_patch" || part.tool === "write")) {
            const content = part.metadata?.csdContent || part.metadata?.content
            if (content && typeof content === "string") lastCsd = content
          }
        }
      }

      // Extract signal chains and opcode usage from last CSD
      const chains = lastCsd ? extractSignalChains(lastCsd) : []
      const opcodeUsage = lastCsd ? extractOpcodeUsage(lastCsd) : {}

      // Only update if we found something
      if (aesthetics.length > 0 || chains.length > 0 || artists.length > 0 || avoidances.length > 0 || Object.keys(opcodeUsage).length > 0) {
        await MemoryStore.updateSonicIdentity({
          ...(aesthetics.length > 0 && { aestheticPreferences: aesthetics }),
          ...(chains.length > 0 && { signatureChains: chains }),
          ...(artists.length > 0 && { referenceArtists: artists }),
          ...(avoidances.length > 0 && { avoidances }),
          ...(Object.keys(opcodeUsage).length > 0 && { frequentOpcodes: opcodeUsage }),
        })

        log.info("updated sonic identity from session", { sessionID, aesthetics, chains: chains.length })
      }
    } catch (e) {
      log.error("failed to update identity from session", { error: e, sessionID })
    }
  }

  /**
   * Build prompt context string for injection into system prompt.
   * Returns a <memory> XML block with recent summaries, identity, relevant techniques.
   * Kept under ~500 tokens.
   */
  export async function promptContext(currentTechniques?: string[]): Promise<string | null> {
    try {
      const [summaries, identity] = await Promise.all([
        MemoryStore.getRecentSummaries(5),
        MemoryStore.getSonicIdentity(),
      ])

      // Don't inject if no memory exists yet
      const hasIdentity = identity.aestheticPreferences.length > 0 || identity.signatureChains.length > 0
      if (summaries.length === 0 && !hasIdentity) return null

      const parts: string[] = []

      // Recent sessions
      if (summaries.length > 0) {
        parts.push("<recent-sessions>")
        for (const s of summaries.slice(0, 3)) {
          const date = new Date(s.timestamp).toISOString().split("T")[0]
          // Truncate summary to keep token count low
          const shortSummary = s.summary.length > 120 ? s.summary.slice(0, 120) + "..." : s.summary
          parts.push(`- [${date}]: ${shortSummary}`)
        }
        parts.push("</recent-sessions>")
      }

      // Sonic identity
      if (hasIdentity) {
        parts.push("<sonic-identity>")
        if (identity.aestheticPreferences.length > 0) {
          parts.push(`Aesthetic: ${identity.aestheticPreferences.slice(0, 6).join(", ")}`)
        }
        if (identity.signatureChains.length > 0) {
          parts.push(`Signature chains: ${identity.signatureChains.slice(0, 3).join("; ")}`)
        }
        if (identity.referenceArtists.length > 0) {
          parts.push(`References: ${identity.referenceArtists.slice(0, 4).join(", ")}`)
        }
        if (identity.avoidances.length > 0) {
          parts.push(`Avoids: ${identity.avoidances.slice(0, 3).join(", ")}`)
        }
        parts.push("</sonic-identity>")
      }

      // Technique context (if current techniques provided)
      if (currentTechniques && currentTechniques.length > 0) {
        const techniqueEntries: string[] = []
        for (const tech of currentTechniques.slice(0, 3)) {
          const journal = await MemoryStore.getTechniqueJournal(tech)
          if (journal && journal.entries.length > 0) {
            const lastEntry = journal.entries[journal.entries.length - 1]
            const lastDate = new Date(lastEntry.date).toISOString().split("T")[0]
            const successCount = journal.entries.filter((e) => e.outcome === "success").length
            let line = `${journal.technique}: ${journal.entries.length} sessions, last ${lastDate}, ${successCount} successful`
            if (journal.preferredPatterns.length > 0) {
              line += `. Pattern: ${journal.preferredPatterns[0]}`
            }
            techniqueEntries.push(line)
          }
        }
        if (techniqueEntries.length > 0) {
          parts.push("<technique-context>")
          parts.push(...techniqueEntries)
          parts.push("</technique-context>")
        }
      }

      if (parts.length === 0) return null

      return `<memory>\n${parts.join("\n")}\n</memory>`
    } catch (e) {
      log.error("failed to build memory prompt context", { error: e })
      return null
    }
  }
}
