import type { RetrievalEngine } from "./engine"

export namespace RetrievalFormat {
  /**
   * Format retrieved chunks as a system prompt section for injection.
   * Includes confidence metadata when provided.
   */
  export function formatContext(
    results: RetrievalEngine.SearchResult[],
    confidence?: "high" | "medium" | "low",
  ): string {
    if (results.length === 0) return ""

    const sections: string[] = []

    for (const result of results) {
      const heading = result.subsection
        ? `## ${result.section} — ${result.subsection}`
        : `## ${result.section}`

      sections.push(`${heading}\n${result.content}`)
    }

    const confidenceLabel = confidence ?? "medium"
    const meta = `[Retrieved ${results.length} chunks, confidence: ${confidenceLabel}]`

    // Debug metadata as HTML comment
    const debugScores = results
      .map((r) => `${r.chunkID}: ${r.score.toFixed(3)}`)
      .join(", ")

    return [
      "<csound-reference>",
      meta,
      `<!-- ${debugScores} -->`,
      "",
      ...sections,
      "</csound-reference>",
    ].join("\n")
  }

  /**
   * Format a multi-tier search result for prompt injection.
   * Combines opcode cards, CSD examples, prose chunks, and graph context
   * into a single injection block with labeled sections.
   */
  export function formatMultiTier(multiTier: RetrievalEngine.MultiTierResult): string {
    const parts: string[] = []

    // Tier 0: Opcode reference cards
    if (multiTier.opcodeCards.length > 0) {
      parts.push(...multiTier.opcodeCards)
    }

    // Tier 1: CSD examples (CAG)
    if (multiTier.csdExamples.length > 0) {
      parts.push(...multiTier.csdExamples)
    }

    // Tier 2: Prose chunks (RAG)
    if (multiTier.proseResults.results.length > 0 && multiTier.proseResults.totalScore > 0.1) {
      parts.push(formatContext(multiTier.proseResults.results, multiTier.proseResults.confidence))
    }

    // Tier 3: Knowledge graph context
    if (multiTier.graphContext.length > 0) {
      const graphSection = [
        "<knowledge-context>",
        ...multiTier.graphContext,
        "</knowledge-context>",
      ].join("\n")
      parts.push(graphSection)
    }

    return parts.join("\n\n")
  }

  /**
   * Extract the last user query text from session messages for retrieval.
   */
  export function extractLastUserQuery(
    messages: Array<{ info: { role: string }; parts: Array<{ type: string; text?: string; synthetic?: boolean }> }>,
  ): string | null {
    for (let i = messages.length - 1; i >= 0; i--) {
      const msg = messages[i]
      if (msg.info.role !== "user") continue
      for (const part of msg.parts) {
        if (part.type === "text" && !part.synthetic && part.text?.trim()) {
          return part.text.trim()
        }
      }
    }
    return null
  }
}
