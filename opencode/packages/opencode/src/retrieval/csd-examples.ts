/**
 * Tier 1: CSD Example Index — CAG (Cache-Augmented Generation).
 *
 * 1,963 CSD files with structured metadata. Tag-based filtering or Orama
 * search over metadata; full CSD content injected directly into prompt
 * without LLM processing. Content lazy-loaded on first CAG request.
 */

import { create, insertMultiple, search, save, load } from "@orama/orama"
import type { AnyOrama } from "@orama/orama"
import type { CsdExample, ExamplesBundle, CsdContentBundle, Domain } from "./schema"
import { Embeddings } from "./embeddings"
import { Log } from "../util/log"

export namespace CsdExamples {
  const log = Log.create({ service: "retrieval.csd-examples" })

  export interface ExampleSearchResult {
    example: CsdExample
    score: number
  }

  let examples: Map<string, CsdExample> = new Map()
  let db: AnyOrama | null = null
  let dimensions = 0
  let mode: "hybrid" | "bm25-only" = "bm25-only"
  let ready = false

  // Lazy-loaded CSD content
  let contentMap: Map<string, string> | null = null
  let contentBundlePath: string | null = null

  // Indexes for fast filtering
  let techniqueIndex: Map<string, string[]> = new Map()
  let opcodeIndex: Map<string, string[]> = new Map()
  let domainIndex: Map<Domain, string[]> = new Map()
  let sourceIndex: Map<string, string[]> = new Map()

  /**
   * Load examples from a pre-computed bundle.
   */
  export async function loadFromBundle(bundle: ExamplesBundle): Promise<void> {
    examples = new Map()
    techniqueIndex = new Map()
    opcodeIndex = new Map()
    domainIndex = new Map()
    sourceIndex = new Map()

    for (const ex of bundle.examples) {
      examples.set(ex.id, ex)
      indexExample(ex)
    }

    dimensions = bundle.dimensions ?? 0
    mode = bundle.mode ?? "bm25-only"

    // Load Orama index
    if (bundle.oramaIndex) {
      const schema: Record<string, any> = {
        title: "string",
        techniques: "string",
        opcodes: "string",
        domain: "string",
        description: "string",
        sonicTags: "string",
        primaryTechnique: "string",
      }
      if (dimensions > 0) {
        schema.embedding = `vector[${dimensions}]`
      }
      db = await create({ schema, id: "csd-examples" })
      await load(db, bundle.oramaIndex)
    }

    ready = true
    log.info("CSD examples loaded from bundle", {
      count: examples.size,
      mode,
    })
  }

  /**
   * Load examples from an array (for build-time).
   */
  export async function loadFromArray(
    exampleArray: CsdExample[],
    embeddings?: Map<string, number[]>,
  ): Promise<void> {
    examples = new Map()
    techniqueIndex = new Map()
    opcodeIndex = new Map()
    domainIndex = new Map()
    sourceIndex = new Map()

    for (const ex of exampleArray) {
      examples.set(ex.id, ex)
      indexExample(ex)
    }

    if (embeddings && embeddings.size > 0) {
      const firstVec = embeddings.values().next().value
      dimensions = firstVec?.length ?? 0
      mode = "hybrid"
    } else {
      dimensions = 0
      mode = "bm25-only"
    }

    // Build Orama index
    const schema: Record<string, any> = {
      title: "string",
      techniques: "string",
      opcodes: "string",
      domain: "string",
      description: "string",
      sonicTags: "string",
      primaryTechnique: "string",
    }
    if (dimensions > 0) {
      schema.embedding = `vector[${dimensions}]`
    }

    db = await create({ schema, id: "csd-examples" })

    const docs = exampleArray.map((ex) => {
      const doc: Record<string, any> = {
        id: ex.id,
        title: ex.title,
        techniques: ex.techniques.join(" "),
        opcodes: ex.opcodes.join(" "),
        domain: ex.domain,
        description: ex.description,
        sonicTags: ex.sonicTags.join(" "),
        primaryTechnique: ex.primaryTechnique,
      }
      if (dimensions > 0 && embeddings?.has(ex.id)) {
        doc.embedding = embeddings.get(ex.id)
      }
      return doc
    })

    await insertMultiple(db, docs)
    ready = true
    log.info("CSD examples indexed", { count: examples.size, mode })
  }

  function indexExample(ex: CsdExample): void {
    // Technique index
    for (const tech of ex.techniques) {
      const key = tech.toLowerCase()
      if (!techniqueIndex.has(key)) techniqueIndex.set(key, [])
      techniqueIndex.get(key)!.push(ex.id)
    }

    // Opcode index
    for (const op of ex.opcodes) {
      const key = op.toLowerCase()
      if (!opcodeIndex.has(key)) opcodeIndex.set(key, [])
      opcodeIndex.get(key)!.push(ex.id)
    }

    // Domain index
    if (!domainIndex.has(ex.domain)) domainIndex.set(ex.domain, [])
    domainIndex.get(ex.domain)!.push(ex.id)

    // Source index
    if (!sourceIndex.has(ex.source)) sourceIndex.set(ex.source, [])
    sourceIndex.get(ex.source)!.push(ex.id)
  }

  /**
   * Set the path for lazy-loading CSD content.
   */
  export function setContentBundlePath(bundlePath: string): void {
    contentBundlePath = bundlePath
  }

  /**
   * Get the full CSD content for an example (lazy-loaded).
   */
  export async function getContent(exampleID: string): Promise<string | null> {
    if (!contentMap && contentBundlePath) {
      try {
        const file = Bun.file(contentBundlePath)
        if (await file.exists()) {
          const bundle = (await file.json()) as CsdContentBundle
          contentMap = new Map(Object.entries(bundle.contents))
          log.info("CSD content bundle loaded", { count: contentMap.size })
        }
      } catch (e) {
        log.error("failed to load CSD content bundle", { error: e })
      }
    }

    return contentMap?.get(exampleID) ?? null
  }

  /**
   * Set content directly (for build scripts).
   */
  export function setContentMap(contents: Map<string, string>): void {
    contentMap = contents
  }

  /**
   * Search examples using Orama hybrid search.
   */
  export async function searchExamples(
    query: string,
    opts?: {
      domain?: Domain
      technique?: string
      limit?: number
      minScore?: number
    },
  ): Promise<ExampleSearchResult[]> {
    if (!ready || !db) return []

    const limit = opts?.limit ?? 5
    const minScore = opts?.minScore ?? 0.01

    try {
      let results: Array<{ id: string; score: number; document: any }>

      if (mode === "hybrid" && dimensions > 0) {
        const queryVector = await Embeddings.embedQuery(query)
        if (queryVector) {
          const hybridResult = await search(db, {
            term: query,
            mode: "hybrid",
            vector: { value: queryVector, property: "embedding" },
            properties: ["title", "techniques", "opcodes", "description", "sonicTags"],
            limit: limit * 3,
            hybridWeights: { text: 0.5, vector: 0.5 },
          } as any)
          results = hybridResult.hits
        } else {
          const bm25Result = await search(db, {
            term: query,
            properties: ["title", "techniques", "opcodes", "description", "sonicTags"],
            limit: limit * 3,
          })
          results = bm25Result.hits
        }
      } else {
        const bm25Result = await search(db, {
          term: query,
          properties: ["title", "techniques", "opcodes", "description", "sonicTags"],
          limit: limit * 3,
        })
        results = bm25Result.hits
      }

      // Filter and map
      const searchResults: ExampleSearchResult[] = []
      for (const hit of results) {
        if (hit.score < minScore) continue
        const example = examples.get(hit.id)
        if (!example) continue

        // Apply domain filter
        if (opts?.domain && opts.domain !== "general" && example.domain !== opts.domain) {
          continue
        }

        // Apply technique filter
        if (opts?.technique) {
          const techLower = opts.technique.toLowerCase()
          if (!example.techniques.some((t) => t.toLowerCase().includes(techLower))) {
            continue
          }
        }

        searchResults.push({ example, score: hit.score })
        if (searchResults.length >= limit) break
      }

      return searchResults
    } catch (e) {
      log.error("CSD example search failed", { error: e, query })
      return []
    }
  }

  /**
   * Get examples by technique (fast index lookup).
   */
  export function byTechnique(technique: string, limit = 10): CsdExample[] {
    const ids = techniqueIndex.get(technique.toLowerCase()) ?? []
    return ids
      .slice(0, limit)
      .map((id) => examples.get(id)!)
      .filter(Boolean)
      .sort((a, b) => b.qualityScore - a.qualityScore)
  }

  /**
   * Get examples that use a specific opcode (fast index lookup).
   */
  export function byOpcode(opcode: string, limit = 10): CsdExample[] {
    const ids = opcodeIndex.get(opcode.toLowerCase()) ?? []
    return ids
      .slice(0, limit)
      .map((id) => examples.get(id)!)
      .filter(Boolean)
      .sort((a, b) => b.qualityScore - a.qualityScore)
  }

  /**
   * Get examples by domain.
   */
  export function byDomain(domain: Domain, limit = 10): CsdExample[] {
    const ids = domainIndex.get(domain) ?? []
    return ids
      .slice(0, limit)
      .map((id) => examples.get(id)!)
      .filter(Boolean)
      .sort((a, b) => b.qualityScore - a.qualityScore)
  }

  /**
   * Get a specific example by ID.
   */
  export function get(id: string): CsdExample | undefined {
    return examples.get(id)
  }

  /**
   * Get example count.
   */
  export function count(): number {
    return examples.size
  }

  export function isReady(): boolean {
    return ready
  }

  /**
   * Export the Orama index for bundle serialization.
   */
  export async function exportIndex(): Promise<any> {
    if (!db) return null
    return await save(db)
  }

  /**
   * Format an example for CAG prompt injection.
   * Includes only the instruments section to stay within token budget.
   */
  export function formatForPrompt(example: CsdExample, csdContent?: string): string {
    const header = [
      `<csound-example id="${example.id}" technique="${example.primaryTechnique}" complexity="${example.complexity}">`,
    ]

    if (example.description) {
      header.push(`; ${example.description}`)
    }
    if (example.signalFlow) {
      header.push(`; Signal flow: ${example.signalFlow}`)
    }

    if (csdContent) {
      // Extract just <CsInstruments> section for token efficiency
      const instrMatch = csdContent.match(/<CsInstruments>([\s\S]*?)<\/CsInstruments>/i)
      if (instrMatch) {
        header.push("<CsInstruments>")
        header.push(instrMatch[1].trim())
        header.push("</CsInstruments>")
      } else {
        // Fallback: include full content truncated
        const truncated = csdContent.length > 3000 ? csdContent.slice(0, 3000) + "\n; ... (truncated)" : csdContent
        header.push(truncated)
      }
    }

    header.push("</csound-example>")
    return header.join("\n")
  }
}
