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
