/**
 * Tier 0: Opcode Reference Cards — O(1) structured lookup.
 *
 * ~800 opcodes stored as typed cards with syntax, params, ranges, categories.
 * Loaded from bundle-core.json at startup (<50ms).
 */

import type { OpcodeCard, CoreBundle, Domain } from "./schema"
import { Log } from "../util/log"

export namespace OpcodeCards {
  const log = Log.create({ service: "retrieval.opcode-cards" })

  // Primary lookup: opcode name -> card
  let cardMap: Map<string, OpcodeCard> = new Map()
  // Category index: category -> opcode names
  let categoryIndex: Map<string, string[]> = new Map()
  // Tag index: tag -> opcode names
  let tagIndex: Map<string, string[]> = new Map()
  let ready = false

  /**
   * Load opcode cards from a core bundle.
   */
  export function loadFromBundle(bundle: CoreBundle): void {
    cardMap = new Map()
    categoryIndex = new Map()
    tagIndex = new Map()

    for (const card of bundle.opcodeCards) {
      const name = card.name.toLowerCase()
      cardMap.set(name, card)

      // Build category index
      const cat = card.category.toLowerCase()
      if (!categoryIndex.has(cat)) categoryIndex.set(cat, [])
      categoryIndex.get(cat)!.push(name)

      // Build tag index
      for (const tag of card.tags) {
        const t = tag.toLowerCase()
        if (!tagIndex.has(t)) tagIndex.set(t, [])
        tagIndex.get(t)!.push(name)
      }
    }

    ready = true
    log.info("opcode cards loaded", { count: cardMap.size, categories: categoryIndex.size })
  }

  /**
   * Load opcode cards directly from an array (for build scripts).
   */
  export function loadFromArray(cards: OpcodeCard[]): void {
    loadFromBundle({
      opcodeCards: cards,
      graph: { nodes: [], edges: [] },
      stats: { totalOpcodes: cards.length, totalExamples: 0, totalProseChunks: 0, totalGraphNodes: 0, totalGraphEdges: 0 },
      version: "",
      createdAt: 0,
    })
  }

  /**
   * O(1) lookup by opcode name.
   */
  export function get(name: string): OpcodeCard | undefined {
    return cardMap.get(name.toLowerCase())
  }

  /**
   * Look up multiple opcodes at once.
   */
  export function getMany(names: string[]): OpcodeCard[] {
    const results: OpcodeCard[] = []
    for (const name of names) {
      const card = cardMap.get(name.toLowerCase())
      if (card) results.push(card)
    }
    return results
  }

  /**
   * Get all opcodes in a category.
   */
  export function byCategory(category: string): OpcodeCard[] {
    const names = categoryIndex.get(category.toLowerCase()) ?? []
    return names.map((n) => cardMap.get(n)!).filter(Boolean)
  }

  /**
   * Get all opcodes matching a tag.
   */
  export function byTag(tag: string): OpcodeCard[] {
    const names = tagIndex.get(tag.toLowerCase()) ?? []
    return names.map((n) => cardMap.get(n)!).filter(Boolean)
  }

  /**
   * Get all opcodes in a domain.
   */
  export function byDomain(domain: Domain): OpcodeCard[] {
    const results: OpcodeCard[] = []
    for (const card of cardMap.values()) {
      if (card.domain === domain) results.push(card)
    }
    return results
  }

  /**
   * Get "see also" related opcodes for an opcode.
   */
  export function related(name: string): OpcodeCard[] {
    const card = cardMap.get(name.toLowerCase())
    if (!card) return []
    return card.seeAlso
      .map((n) => cardMap.get(n.toLowerCase()))
      .filter((c): c is OpcodeCard => c !== undefined)
  }

  /**
   * Check if an opcode name exists in the cards.
   */
  export function has(name: string): boolean {
    return cardMap.has(name.toLowerCase())
  }

  /**
   * Get all category names.
   */
  export function categories(): string[] {
    return [...categoryIndex.keys()]
  }

  /**
   * Get total count.
   */
  export function count(): number {
    return cardMap.size
  }

  export function isReady(): boolean {
    return ready
  }

  /**
   * Format an opcode card for prompt injection.
   * ~200 tokens per card.
   */
  export function formatForPrompt(card: OpcodeCard): string {
    const params = card.parameters
      .map((p) => {
        let desc = `${p.name} (${p.rate}-rate): ${p.description}`
        if (p.range) desc += ` [${p.range[0]}-${p.range[1]}]`
        if (p.defaultValue) desc += ` (default: ${p.defaultValue})`
        return desc
      })
      .join("\n  ")

    const seeAlso = card.seeAlso.length > 0 ? `See also: ${card.seeAlso.join(", ")}` : ""

    return [
      `<opcode-reference opcode="${card.name}" category="${card.category}" confidence="exact">`,
      `Syntax: ${card.syntax}`,
      card.description,
      params ? `Parameters:\n  ${params}` : "",
      seeAlso,
      `</opcode-reference>`,
    ]
      .filter(Boolean)
      .join("\n")
  }
}
