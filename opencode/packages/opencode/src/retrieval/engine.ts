import { create, insertMultiple, search, save, load, count } from "@orama/orama"
import type { AnyOrama } from "@orama/orama"
import fs from "fs/promises"
import path from "path"
import { KnowledgeSources } from "./knowledge-sources"
import { CsoundKnowledge } from "./knowledge"
import { Embeddings } from "./embeddings"
import { RetrievalFeedback } from "./feedback"
import { Log } from "../util/log"
import { Instance } from "../project/instance"

export namespace RetrievalEngine {
  const log = Log.create({ service: "retrieval.engine" })

  export type Domain = "synthesis" | "effects" | "modulation" | "debugging" | "general"

  export interface SearchResult {
    chunkID: string
    section: string
    subsection: string
    content: string
    score: number
    tags: string[]
  }

  export interface AdaptiveSearchResult {
    results: SearchResult[]
    totalScore: number
    truncatedAt: number
    confidence: "high" | "medium" | "low"
  }

  interface EngineState {
    db: AnyOrama | null
    chunks: CsoundKnowledge.Chunk[]
    embeddings: Map<string, number[]> | null
    dimensions: number
    ready: boolean
    mode: "hybrid" | "bm25-only"
  }

  let state: EngineState = {
    db: null,
    chunks: [],
    embeddings: null,
    dimensions: 0,
    ready: false,
    mode: "bm25-only",
  }

  let initPromise: Promise<void> | null = null

  // --- Query cache for parallel sub-agent deduplication ---
  interface CacheEntry {
    results: SearchResult[]
    totalScore: number
    confidence: "high" | "medium" | "low"
    timestamp: number
  }
  const queryCache = new Map<string, CacheEntry>()
  const CACHE_TTL = 60_000 // 60s

  // --- Session context window for multi-turn recency boost ---
  const sessionContext = new Map<string, string[]>() // sessionID -> last N chunk section keys
  const SESSION_CONTEXT_MAX = 10

  // --- Last retrieval tracking for user feedback ---
  export interface LastRetrieval {
    sessionID: string
    chunkIDs: string[]
    results: SearchResult[]
    confidence: "high" | "medium" | "low"
    timestamp: number
  }
  let _lastRetrieval: LastRetrieval | null = null

  export function setLastRetrieval(retrieval: LastRetrieval): void {
    _lastRetrieval = retrieval
  }

  export function getLastRetrieval(sessionID?: string): LastRetrieval | null {
    if (!_lastRetrieval) return null
    if (sessionID && _lastRetrieval.sessionID !== sessionID) return null
    return _lastRetrieval
  }

  // Domain keyword sets for section-biased scoring
  const DOMAIN_SECTION_KEYWORDS: Record<Domain, string[]> = {
    synthesis: ["oscillator", "synthesis", "waveform", "additive", "subtractive", "fm", "granular", "waveguide", "physical model", "wavetable", "sample", "noise", "tone"],
    effects: ["reverb", "delay", "filter", "distortion", "compress", "eq", "spatial", "pan", "chorus", "flanger", "phaser"],
    modulation: ["envelope", "lfo", "control", "midi", "osc", "schedule", "trigger", "automation", "modulation", "gate"],
    debugging: ["error", "debug", "performance", "optimization"],
    general: [],
  }

  function indexPath(): string {
    return path.join(KnowledgeSources.dataDir(), "index.json")
  }

  export function status(): { ready: boolean; chunkCount: number; mode: "hybrid" | "bm25-only" } {
    return {
      ready: state.ready,
      chunkCount: state.chunks.length,
      mode: state.mode,
    }
  }

  async function createDB(dimensions: number): Promise<AnyOrama> {
    const schema: Record<string, string> = {
      content: "string",
      section: "string",
      tags: "string",
    }

    if (dimensions > 0) {
      schema.embedding = `vector[${dimensions}]`
    }

    return await create({ schema, id: "csound-knowledge" })
  }

  export async function initialize(): Promise<void> {
    if (state.ready) return
    if (initPromise) return initPromise

    initPromise = doInit()
    return initPromise
  }

  async function doInit(): Promise<void> {
    try {
      // Priority 1: Try loading pre-computed bundle (shipped with binary)
      const bundled = await loadBundle()
      if (bundled) {
        state.ready = true
        log.info("loaded retrieval engine from bundle", {
          chunks: state.chunks.length,
          mode: state.mode,
        })
        return
      }

      // Priority 2: Try loading from disk cache
      const cached = await loadFromDisk()
      if (cached) {
        state.ready = true
        log.info("loaded retrieval engine from cache", {
          chunks: state.chunks.length,
          mode: state.mode,
        })
        return
      }

      // Priority 3: Build fresh from sources
      const sources = KnowledgeSources.list(Instance.worktree)
      let allChunks: CsoundKnowledge.Chunk[] = []

      for (const source of sources) {
        try {
          const chunks = await CsoundKnowledge.loadOrBuild(source)
          allChunks = allChunks.concat(chunks)
        } catch {
          // Source file may not exist — skip silently
        }
      }

      if (allChunks.length === 0) {
        log.warn("no knowledge chunks found, retrieval disabled")
        state.ready = false
        initPromise = null
        return
      }

      state.chunks = allChunks

      // Try to get embeddings
      const embeddingResult = await Embeddings.embedChunks(
        allChunks.map((c) => ({ id: c.id, content: c.content })),
      )

      if (embeddingResult && embeddingResult.size > 0) {
        state.embeddings = embeddingResult
        // Detect dimensions from first vector
        const firstVec = embeddingResult.values().next().value
        state.dimensions = firstVec?.length ?? 0
        state.mode = "hybrid"
      } else {
        state.dimensions = 0
        state.mode = "bm25-only"
      }

      // Create and populate Orama DB
      state.db = await createDB(state.dimensions)

      const docs = allChunks.map((chunk) => {
        const doc: Record<string, any> = {
          id: chunk.id,
          content: chunk.content,
          section: chunk.section,
          tags: chunk.tags.join(" "),
        }
        if (state.dimensions > 0 && state.embeddings?.has(chunk.id)) {
          doc.embedding = state.embeddings.get(chunk.id)
        }
        return doc
      })

      await insertMultiple(state.db, docs)

      // Persist index
      await saveToDisk()

      state.ready = true
      log.info("retrieval engine initialized", {
        chunks: allChunks.length,
        mode: state.mode,
        dimensions: state.dimensions,
      })
    } catch (e) {
      log.error("retrieval engine init failed", { error: e })
      state.ready = false
      initPromise = null
    }
  }

  /**
   * Load pre-computed bundle from resources/knowledge/bundle.json.
   * This is shipped with the binary and works without any API keys.
   */
  async function loadBundle(): Promise<boolean> {
    try {
      const bundlePath = KnowledgeSources.bundlePath()
      const file = Bun.file(bundlePath)
      if (!(await file.exists())) return false

      const bundle = await file.json()

      state.chunks = bundle.chunks
      state.dimensions = bundle.dimensions ?? 0
      state.mode = bundle.mode ?? "bm25-only"

      state.db = await createDB(state.dimensions)
      await load(state.db, bundle.oramaIndex)

      log.info("loaded pre-computed bundle", {
        version: bundle.version,
        chunks: state.chunks.length,
        mode: state.mode,
      })

      return true
    } catch (e) {
      log.info("no pre-computed bundle found", { error: String(e) })
      return false
    }
  }

  async function saveToDisk(): Promise<void> {
    if (!state.db) return
    try {
      const dir = KnowledgeSources.dataDir()
      await fs.mkdir(dir, { recursive: true })
      const raw = await save(state.db)
      await fs.writeFile(
        indexPath(),
        JSON.stringify({
          raw,
          chunks: state.chunks,
          dimensions: state.dimensions,
          mode: state.mode,
        }),
        "utf-8",
      )
    } catch (e) {
      log.error("failed to save index", { error: e })
    }
  }

  async function loadFromDisk(): Promise<boolean> {
    try {
      const data = await fs.readFile(indexPath(), "utf-8")
      const parsed = JSON.parse(data)

      state.chunks = parsed.chunks
      state.dimensions = parsed.dimensions ?? 0
      state.mode = parsed.mode ?? "bm25-only"

      state.db = await createDB(state.dimensions)
      await load(state.db, parsed.raw)

      // Also load embeddings cache if in hybrid mode
      if (state.mode === "hybrid") {
        state.embeddings = await Embeddings.embedChunks(
          state.chunks.map((c) => ({ id: c.id, content: c.content })),
        )
      }

      return true
    } catch {
      return false
    }
  }

  /**
   * Search for relevant chunks. Combines BM25 + vector search via Orama's hybrid mode,
   * then applies RLHF boost multipliers, domain biasing, and session context recency.
   *
   * Returns adaptive results with score-based truncation (2-8 chunks).
   */
  export async function searchChunks(
    query: string,
    opts?: { topK?: number; minScore?: number; sessionID?: string; domain?: Domain },
  ): Promise<SearchResult[]> {
    const adaptive = await searchChunksAdaptive(query, opts)
    return adaptive.results
  }

  /**
   * Adaptive search returning results with confidence and total score metadata.
   * Chunk count is determined by score dropoff rather than a fixed topK.
   */
  export async function searchChunksAdaptive(
    query: string,
    opts?: { topK?: number; minScore?: number; sessionID?: string; domain?: Domain },
  ): Promise<AdaptiveSearchResult> {
    const empty: AdaptiveSearchResult = { results: [], totalScore: 0, truncatedAt: 0, confidence: "low" }
    if (!state.ready || !state.db) return empty

    const maxK = 8
    const minScore = opts?.minScore ?? 0.01
    const domain = opts?.domain ?? "general"

    // Check query cache (use truncated key for better hit rate with expanded queries)
    const cacheKey = opts?.sessionID ? `${opts.sessionID}:${query.slice(0, 200)}` : query.slice(0, 200)
    const cached = queryCache.get(cacheKey)
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
      return { results: cached.results, totalScore: cached.totalScore, truncatedAt: cached.results.length, confidence: cached.confidence }
    }

    // Clean expired entries periodically
    if (queryCache.size > 100) {
      const now = Date.now()
      for (const [key, entry] of queryCache) {
        if (now - entry.timestamp > CACHE_TTL) queryCache.delete(key)
      }
    }

    try {
      let results: Array<{ id: string; score: number; document: any }>

      // Fetch extra candidates for re-ranking (3x instead of 2x)
      const fetchLimit = maxK * 3

      if (state.mode === "hybrid" && state.dimensions > 0) {
        const queryVector = await Embeddings.embedQuery(query)

        if (queryVector) {
          const hybridResult = await search(state.db, {
            term: query,
            mode: "hybrid",
            vector: {
              value: queryVector,
              property: "embedding",
            },
            properties: ["content", "tags", "section"],
            limit: fetchLimit,
            relevance: { k: 1.5, b: 0.75, d: 0.5 },
            similarity: 0.5,
            hybridWeights: { text: 0.6, vector: 0.4 },
          } as any)
          results = hybridResult.hits
        } else {
          const bm25Result = await search(state.db, {
            term: query,
            properties: ["content", "tags", "section"],
            limit: fetchLimit,
            relevance: { k: 1.5, b: 0.75, d: 0.5 },
          })
          results = bm25Result.hits
        }
      } else {
        const bm25Result = await search(state.db, {
          term: query,
          properties: ["content", "tags", "section"],
          limit: fetchLimit,
          relevance: { k: 1.5, b: 0.75, d: 0.5 },
        })
        results = bm25Result.hits
      }

      // Apply RLHF boosts
      const boosts = await RetrievalFeedback.getBoosts()
      const boosted = results.map((hit) => {
        const chunkID = hit.id
        let boost = boosts.get(chunkID) ?? 1.0

        // Domain bias: boost chunks whose section/tags match the domain
        if (domain !== "general") {
          const chunk = state.chunks.find((c) => c.id === chunkID)
          if (chunk) {
            const domainKeywords = DOMAIN_SECTION_KEYWORDS[domain]
            const sectionLower = chunk.section.toLowerCase()
            const tagsLower = chunk.tags.map((t) => t.toLowerCase())
            const hasDomainMatch = domainKeywords.some(
              (kw) => sectionLower.includes(kw) || tagsLower.some((t) => t.includes(kw)),
            )
            if (hasDomainMatch) boost *= 1.3
          }
        }

        // Session context recency boost
        if (opts?.sessionID) {
          const recentSections = sessionContext.get(opts.sessionID) ?? []
          const chunk = state.chunks.find((c) => c.id === chunkID)
          if (chunk && recentSections.includes(chunk.section)) {
            boost *= 1.15
          }
        }

        return {
          ...hit,
          score: hit.score * boost,
        }
      })

      // Sort by boosted score, dedup by section
      boosted.sort((a, b) => b.score - a.score)

      const seen = new Set<string>()
      const candidates: SearchResult[] = []

      for (const hit of boosted) {
        if (candidates.length >= maxK) break
        if (hit.score < minScore) continue

        const chunk = state.chunks.find((c) => c.id === hit.id)
        if (!chunk) continue

        const sectionKey = `${chunk.section}::${chunk.subsection}`
        if (seen.has(sectionKey) && candidates.length > 2) continue
        seen.add(sectionKey)

        candidates.push({
          chunkID: chunk.id,
          section: chunk.section,
          subsection: chunk.subsection,
          content: chunk.content,
          score: hit.score,
          tags: chunk.tags,
        })
      }

      // Adaptive truncation: find score dropoff point
      let truncateAt = candidates.length
      for (let i = 0; i < candidates.length - 1; i++) {
        if (candidates[i + 1].score < 0.4 * candidates[i].score) {
          truncateAt = i + 1
          break
        }
      }

      // Clamp between 2 and 8
      truncateAt = Math.max(2, Math.min(maxK, truncateAt))
      const final = candidates.slice(0, truncateAt)

      const totalScore = final.reduce((sum, r) => sum + r.score, 0)
      const confidence: "high" | "medium" | "low" =
        final.length > 0 && final[0].score > 0.5 ? "high" : final.length > 0 && final[0].score > 0.2 ? "medium" : "low"

      // Update session context window
      if (opts?.sessionID && final.length > 0) {
        const sections = final.map((r) => r.section)
        const existing = sessionContext.get(opts.sessionID) ?? []
        const updated = [...sections, ...existing].slice(0, SESSION_CONTEXT_MAX)
        sessionContext.set(opts.sessionID, updated)
      }

      // Cache the results
      queryCache.set(cacheKey, { results: final, totalScore, confidence, timestamp: Date.now() })

      return { results: final, totalScore, truncatedAt: truncateAt, confidence }
    } catch (e) {
      log.error("search failed", { error: e, query })
      return empty
    }
  }
}
