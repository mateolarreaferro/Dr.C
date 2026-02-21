import fs from "fs/promises"
import path from "path"
import { KnowledgeSources } from "./knowledge-sources"
import { Log } from "../util/log"

export namespace Embeddings {
  const log = Log.create({ service: "retrieval.embeddings" })

  export type Provider = "openai" | "anthropic" | "none"

  interface EmbeddingCache {
    provider: string
    model: string
    dimensions: number
    vectors: Record<string, number[]>
  }

  function cachePath(): string {
    return path.join(KnowledgeSources.dataDir(), "embeddings.json")
  }

  async function loadCache(): Promise<EmbeddingCache | null> {
    try {
      const raw = await fs.readFile(cachePath(), "utf-8")
      return JSON.parse(raw)
    } catch {
      return null
    }
  }

  async function saveCache(cache: EmbeddingCache): Promise<void> {
    await fs.mkdir(path.dirname(cachePath()), { recursive: true })
    await fs.writeFile(cachePath(), JSON.stringify(cache), "utf-8")
  }

  function detectProvider(): { provider: Provider; apiKey: string } {
    // Check for OpenAI key (supports text-embedding-3-small)
    const openaiKey = process.env.OPENAI_API_KEY
    if (openaiKey) return { provider: "openai", apiKey: openaiKey }

    // Check for Anthropic/Voyage key
    const voyageKey = process.env.VOYAGE_API_KEY
    if (voyageKey) return { provider: "anthropic", apiKey: voyageKey }

    return { provider: "none", apiKey: "" }
  }

  export function isAvailable(): boolean {
    return detectProvider().provider !== "none"
  }

  /**
   * Check if pre-computed embeddings exist in the bundle.
   * When bundle is loaded, embedChunks can return cached vectors
   * without requiring API keys.
   */
  let precomputedVectors: Map<string, number[]> | null = null

  export function setPrecomputed(vectors: Map<string, number[]>): void {
    precomputedVectors = vectors
  }

  async function embedOpenAI(texts: string[], apiKey: string): Promise<number[][]> {
    const batchSize = 100
    const allVectors: number[][] = []

    for (let i = 0; i < texts.length; i += batchSize) {
      const batch = texts.slice(i, i + batchSize)
      const response = await fetch("https://api.openai.com/v1/embeddings", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: "text-embedding-3-small",
          input: batch,
        }),
        signal: AbortSignal.timeout(5000), // 5s timeout for query embeddings
      })

      if (!response.ok) {
        const err = await response.text()
        throw new Error(`OpenAI embedding failed: ${response.status} ${err}`)
      }

      const data = (await response.json()) as { data: Array<{ embedding: number[] }> }
      allVectors.push(...data.data.map((d) => d.embedding))

      if (i + batchSize < texts.length) {
        // Rate limit courtesy
        await new Promise((r) => setTimeout(r, 200))
      }
    }

    return allVectors
  }

  async function embedVoyage(texts: string[], apiKey: string): Promise<number[][]> {
    const batchSize = 50
    const allVectors: number[][] = []

    for (let i = 0; i < texts.length; i += batchSize) {
      const batch = texts.slice(i, i + batchSize)
      const response = await fetch("https://api.voyageai.com/v1/embeddings", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: "voyage-3-lite",
          input: batch,
          input_type: "document",
        }),
        signal: AbortSignal.timeout(5000), // 5s timeout for query embeddings
      })

      if (!response.ok) {
        const err = await response.text()
        throw new Error(`Voyage embedding failed: ${response.status} ${err}`)
      }

      const data = (await response.json()) as { data: Array<{ embedding: number[] }> }
      allVectors.push(...data.data.map((d) => d.embedding))

      if (i + batchSize < texts.length) {
        await new Promise((r) => setTimeout(r, 200))
      }
    }

    return allVectors
  }

  export async function embed(texts: string[]): Promise<{ vectors: number[][]; dimensions: number } | null> {
    const { provider, apiKey } = detectProvider()
    if (provider === "none") return null

    try {
      if (provider === "openai") {
        const vectors = await embedOpenAI(texts, apiKey)
        return { vectors, dimensions: 1536 }
      }
      if (provider === "anthropic") {
        const vectors = await embedVoyage(texts, apiKey)
        return { vectors, dimensions: 1024 }
      }
    } catch (e) {
      log.error("embedding failed", { provider, error: e })
      return null
    }

    return null
  }

  /**
   * Embed all chunks, using cache for previously embedded chunks.
   * Returns a map of chunkID -> vector, or null if no provider available.
   */
  export async function embedChunks(
    chunks: Array<{ id: string; content: string }>,
  ): Promise<Map<string, number[]> | null> {
    const { provider } = detectProvider()
    if (provider === "none") return null

    const cache = await loadCache()
    const result = new Map<string, number[]>()

    // Determine which chunks need embedding
    const needsEmbedding: Array<{ id: string; content: string }> = []
    for (const chunk of chunks) {
      if (cache?.vectors[chunk.id]) {
        result.set(chunk.id, cache.vectors[chunk.id])
      } else {
        needsEmbedding.push(chunk)
      }
    }

    if (needsEmbedding.length === 0) {
      log.info("all chunks already embedded", { count: chunks.length })
      return result
    }

    log.info("embedding chunks", { total: chunks.length, new: needsEmbedding.length })

    const texts = needsEmbedding.map((c) => c.content)
    const embedded = await embed(texts)
    if (!embedded) return result.size > 0 ? result : null

    for (let i = 0; i < needsEmbedding.length; i++) {
      result.set(needsEmbedding[i].id, embedded.vectors[i])
    }

    // Update cache
    const newCache: EmbeddingCache = {
      provider,
      model: provider === "openai" ? "text-embedding-3-small" : "voyage-3-lite",
      dimensions: embedded.dimensions,
      vectors: Object.fromEntries(result),
    }
    await saveCache(newCache)

    log.info("embedding complete", { total: result.size, dimensions: embedded.dimensions })
    return result
  }

  /**
   * Embed a single query for search.
   * Uses an in-memory cache to avoid redundant API calls for similar queries.
   */
  const queryEmbeddingCache = new Map<string, { vector: number[]; timestamp: number }>()
  const QUERY_CACHE_TTL = 300_000 // 5 minutes
  const QUERY_CACHE_MAX = 50

  export async function embedQuery(text: string): Promise<number[] | null> {
    // Normalize query for cache lookup (trim + lowercase for near-duplicates)
    const cacheKey = text.trim().toLowerCase().slice(0, 200)

    const cached = queryEmbeddingCache.get(cacheKey)
    if (cached && Date.now() - cached.timestamp < QUERY_CACHE_TTL) {
      return cached.vector
    }

    const result = await embed([text])
    const vector = result?.vectors[0] ?? null

    if (vector) {
      // Evict oldest entries if cache is full
      if (queryEmbeddingCache.size >= QUERY_CACHE_MAX) {
        const oldest = [...queryEmbeddingCache.entries()].sort((a, b) => a[1].timestamp - b[1].timestamp)[0]
        if (oldest) queryEmbeddingCache.delete(oldest[0])
      }
      queryEmbeddingCache.set(cacheKey, { vector, timestamp: Date.now() })
    }

    return vector
  }
}
