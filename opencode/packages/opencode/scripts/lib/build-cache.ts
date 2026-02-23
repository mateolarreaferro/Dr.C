/**
 * Build cache for incremental knowledge pipeline.
 *
 * Caches expensive operations (LLM enrichment + OpenAI embeddings)
 * keyed by SHA256 content hash. If a file hasn't changed, its hash
 * matches and we skip the API call.
 *
 * Cache lives at ~/.drc/knowledge/build-cache.json
 */

import fs from "fs/promises"
import path from "path"
import crypto from "crypto"
import os from "os"

export interface EnrichmentCacheEntry {
  contentHash: string
  enrichment: {
    description: string
    primaryTechnique: string
    pedagogicalValue: string
    signalFlow: string
    sonicTags: string[]
  }
  model: string
  timestamp: number
}

export interface EmbeddingCacheEntry {
  contentHash: string
  vector: number[]
  model: string
  timestamp: number
}

export interface BuildCache {
  version: "1"
  enrichments: Record<string, EnrichmentCacheEntry>
  embeddings: Record<string, EmbeddingCacheEntry>
}

export const CACHE_DIR = path.join(os.homedir(), ".drc", "knowledge")
export const CACHE_PATH = path.join(CACHE_DIR, "build-cache.json")
export const CACHE_VERSION = "1"
export const ENRICHMENT_MODEL = "claude-haiku-4-5-20251001"
export const EMBEDDING_MODEL = "text-embedding-3-small"

function emptyCache(): BuildCache {
  return { version: "1", enrichments: {}, embeddings: {} }
}

export async function loadCache(): Promise<BuildCache> {
  try {
    const raw = await fs.readFile(CACHE_PATH, "utf-8")
    const parsed = JSON.parse(raw) as BuildCache
    if (parsed.version !== CACHE_VERSION) {
      console.log(`  Cache version mismatch (got ${parsed.version}, want ${CACHE_VERSION}), starting fresh`)
      return emptyCache()
    }
    const enrichCount = Object.keys(parsed.enrichments).length
    const embedCount = Object.keys(parsed.embeddings).length
    console.log(`  Loaded build cache: ${enrichCount} enrichments, ${embedCount} embeddings`)
    return parsed
  } catch {
    console.log("  No existing build cache found, starting fresh")
    return emptyCache()
  }
}

export async function saveCache(cache: BuildCache): Promise<void> {
  await fs.mkdir(CACHE_DIR, { recursive: true })
  const tmpPath = CACHE_PATH + ".tmp"
  await fs.writeFile(tmpPath, JSON.stringify(cache))
  await fs.rename(tmpPath, CACHE_PATH)
  const enrichCount = Object.keys(cache.enrichments).length
  const embedCount = Object.keys(cache.embeddings).length
  console.log(`  Saved build cache: ${enrichCount} enrichments, ${embedCount} embeddings`)
}

export function hashContent(text: string): string {
  return crypto.createHash("sha256").update(text).digest("hex").slice(0, 32)
}
