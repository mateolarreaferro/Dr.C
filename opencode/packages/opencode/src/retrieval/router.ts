/**
 * Query Router — rule-based intent classification and tier dispatch.
 *
 * Classifies user queries into intents and determines which knowledge tiers
 * to query, with token budget allocation per tier. No LLM call needed (<1ms).
 */

import type { QueryIntent, RouteResult, Domain } from "./schema"
import { OpcodeCards } from "./opcode-cards"

export namespace QueryRouter {
  // Known opcode names for detection (pattern matches common opcodes)
  // We also check against OpcodeCards for exact matches
  const OPCODE_PATTERN =
    /\b(oscili?|poscil|vco2?|moogladder|lpf18|zdf_2pole|zdf_ladder|butterlp|butterhp|butterbp|butterbs|reverbsc|reverb2?|freeverb|nreverb|delay[rw]?|deltap[i3]?|flanger|chorus|phaser[12]|distort1?|tanh|powershape|clip|wrap|fold|bitcrusher|decimator|loscil[3]?|diskin2?|soundin|foscili?|buzz|gbuzz|grain3?|partikkel|fog|fof2?|wgpluck2?|wgbow|wgflute|wgclar|repluck|pluck|noise|pinkish|rand[hi]?|jitter2?|randi?|linen|linenr|adsr|madsr|mxadsr|expon|line|envlpx|linseg|expseg|transeg|cosseg|loopseg|jspline|rspline|port|portk|tonek?|atonek?|tonex|reson|resonx?|areson|bqrez|svfilter|statevar|mode|compress2?|dam|follow2?|rms|balance2?|pan2?|vbap[48]?|hrtfstat|hrtfmove2?|pvsanal|pvsynth|pvscross|pvsfilter|pvsmorph|pvsblur|pvswarp|pvshift|pvscale|lfo|phasor|metro|trigger|schedule|schedkwhen|ftgen|chnget|chnset|GEN\d{1,2}|tablei?|oscbnk|mincer|temposcal|flooper2?|pconvolve|ftconv)\b/gi

  // Intent detection patterns
  const EXAMPLE_PATTERNS = [
    /\b(show\s+me|give\s+me|example\s+of|template\s+for|code\s+for|sample|demonstrate|how\s+to\s+(make|create|build|write))\b/i,
    /\b(CSD|instrument|.csd)\s*(example|template|sample|code)/i,
  ]

  const EXPLAIN_PATTERNS = [
    /\b(how\s+does|what\s+is|explain|describe|tell\s+me\s+about|what\s+are|overview\s+of|concept\s+of|theory\s+behind)\b/i,
    /\b(how|why)\s+(does|do|is|are|can|should)\b/i,
  ]

  const COMPARISON_PATTERNS = [
    /\b(vs\.?|versus|compared?\s+to|difference\s+between|which\s+(is|should|would)\s+(better|best|faster|more))\b/i,
    /\bor\b.*\b(better|prefer|recommend|choose)\b/i,
  ]

  const DEBUG_PATTERNS = [
    /\b(error|bug|crash|fail|broken|wrong|silent|no\s+sound|doesn't\s+work|won't\s+compile|fix|debug|issue|problem|not\s+working|help\s+with)\b/i,
    /\b(why\s+(is|does|doesn't|won't|can't))\b/i,
  ]

  const DESIGN_PATTERNS = [
    /\b(warm|warmer|bright|brighter|dark|darker|fat|fatter|thin|thick|harsh|smooth|mellow|metallic|organic|digital|analog|lush|crispy|punchy|airy|spacious|tight|loose|wide|narrow)\b/i,
    /\b(make\s+it|sound\s+more|sound\s+like|sonic|texture|character|quality|vibe|feel|mood)\b/i,
    /\b(pad|lead|bass|string|brass|bell|drum|kick|snare|hat|pluck|stab|drone|ambient|percussion)\b/i,
  ]

  /**
   * Extract opcode names from a query string.
   * Uses both regex patterns and OpcodeCards lookup for accuracy.
   */
  function extractOpcodeNames(query: string): string[] {
    const matches = query.match(OPCODE_PATTERN) ?? []
    const opcodes = new Set(matches.map((m) => m.toLowerCase()))

    // Also check individual words against the opcode card map
    const words = query.split(/\s+/)
    for (const word of words) {
      const clean = word.replace(/[^a-zA-Z0-9_]/g, "").toLowerCase()
      if (clean.length >= 3 && OpcodeCards.has(clean)) {
        opcodes.add(clean)
      }
    }

    return [...opcodes]
  }

  /**
   * Route a query to the appropriate knowledge tiers.
   */
  export function route(query: string, domain?: Domain): RouteResult {
    const opcodeNames = extractOpcodeNames(query)

    // Rule-based intent classification (priority order)
    let intent: QueryIntent = "general"

    // 1. Opcode lookup — query mentions specific opcode names
    if (opcodeNames.length > 0 && query.length < 80) {
      // Short query with opcode names → likely a lookup
      intent = "opcode_lookup"
    }

    // 2. Debug — error/problem keywords
    if (intent === "general" || intent === "opcode_lookup") {
      for (const pattern of DEBUG_PATTERNS) {
        if (pattern.test(query)) {
          intent = "debug"
          break
        }
      }
    }

    // 3. Comparison — vs/difference patterns
    if (intent === "general") {
      for (const pattern of COMPARISON_PATTERNS) {
        if (pattern.test(query)) {
          intent = "comparison"
          break
        }
      }
    }

    // 4. Example request — "show me", "example of"
    if (intent === "general") {
      for (const pattern of EXAMPLE_PATTERNS) {
        if (pattern.test(query)) {
          intent = "example_request"
          break
        }
      }
    }

    // 5. Technique explanation — "how does", "explain"
    if (intent === "general") {
      for (const pattern of EXPLAIN_PATTERNS) {
        if (pattern.test(query)) {
          intent = "technique_explain"
          break
        }
      }
    }

    // 6. Design exploration — adjective-heavy, sonic descriptors
    if (intent === "general") {
      let designScore = 0
      for (const pattern of DESIGN_PATTERNS) {
        if (pattern.test(query)) designScore++
      }
      if (designScore >= 1) {
        intent = "design_explore"
      }
    }

    // Override: if opcode names detected in any intent, enrich with opcode lookup
    // Also: an opcode lookup query that also asks "how" → technique_explain
    if (opcodeNames.length > 0 && intent === "general") {
      intent = "opcode_lookup"
    }

    return buildRoute(intent, opcodeNames)
  }

  /**
   * Build the tier dispatch and token budget for an intent.
   */
  function buildRoute(intent: QueryIntent, opcodeNames: string[]): RouteResult {
    // Total budget: ~4000 tokens
    switch (intent) {
      case "opcode_lookup":
        return {
          intent,
          tiers: [0, 1], // Card + examples
          opcodeNames,
          tokenBudget: { opcodeCards: 400, csdExamples: 1500, proseChunks: 0 },
        }

      case "example_request":
        return {
          intent,
          tiers: [1, 2], // CAG primary, prose secondary
          opcodeNames,
          tokenBudget: { opcodeCards: 0, csdExamples: 2500, proseChunks: 1000 },
        }

      case "technique_explain":
        return {
          intent,
          tiers: [2, 0, 1], // Prose primary, opcode cards, examples
          opcodeNames,
          tokenBudget: { opcodeCards: 200, csdExamples: 800, proseChunks: 2500 },
        }

      case "comparison":
        return {
          intent,
          tiers: [0, 3], // Opcode cards + graph traversal
          opcodeNames,
          tokenBudget: { opcodeCards: 600, csdExamples: 500, proseChunks: 1500 },
        }

      case "debug":
        return {
          intent,
          tiers: [2], // Prose only (debugging info)
          opcodeNames,
          tokenBudget: { opcodeCards: 200, csdExamples: 0, proseChunks: 3000 },
        }

      case "design_explore":
        return {
          intent,
          tiers: [1, 2, 3], // Examples + prose + graph
          opcodeNames,
          tokenBudget: { opcodeCards: 0, csdExamples: 1500, proseChunks: 1500 },
        }

      case "general":
      default:
        return {
          intent,
          tiers: [2], // Prose only (existing behavior)
          opcodeNames,
          tokenBudget: { opcodeCards: 0, csdExamples: 0, proseChunks: 3500 },
        }
    }
  }
}
