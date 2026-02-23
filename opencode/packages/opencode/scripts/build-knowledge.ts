#!/usr/bin/env bun
/**
 * Unified knowledge bundle builder for multi-tier knowledge system.
 *
 * Produces split bundles:
 *   bundle.json        — Prose chunks + Orama index (Tier 2, backward compatible)
 *   bundle-core.json   — Opcode cards + knowledge graph (Tiers 0 + 3)
 *   bundle-examples.json — CSD example metadata + Orama index (Tier 1)
 *   bundle-csd.json    — Full CSD content (Tier 1, lazy-loaded)
 *
 * Usage:
 *   bun run scripts/build-knowledge.ts           # Build prose bundle only (existing behavior)
 *   bun run scripts/build-knowledge.ts --all     # Build all tiers
 *   bun run scripts/build-knowledge.ts --prose   # Build prose bundle only
 *
 * For individual tier builds, use:
 *   bun run scripts/build-csd-index.ts           # Tier 1: CSD examples
 *   bun run scripts/build-opcode-cards.ts        # Tier 0: Opcode cards
 *   bun run scripts/build-knowledge-graph.ts     # Tier 3: Knowledge graph
 *   bun run scripts/extract-pdf.ts               # Extract PDF books to text
 */

import { create, insertMultiple, save } from "@orama/orama"
import fs from "fs/promises"
import path from "path"
import crypto from "crypto"
import { loadCache, saveCache, hashContent, EMBEDDING_MODEL, type BuildCache } from "./lib/build-cache"

const ROOT = path.resolve(import.meta.dir, "..")
const SOURCES_DIR = path.join(ROOT, "resources", "knowledge", "sources")
const BUNDLE_PATH = path.join(ROOT, "resources", "knowledge", "bundle.json")
const MANIFEST_PATH = path.join(ROOT, "resources", "knowledge", "manifest.json")
const OUTPUT_DIR = path.join(ROOT, "resources", "knowledge")

const args = process.argv.slice(2)
const buildAll = args.includes("--all")

interface Chunk {
  id: string
  source: string
  section: string
  subsection: string
  content: string
  tokens: number
  tags: string[]
}

interface Bundle {
  version: string
  createdAt: number
  mode: "hybrid" | "bm25-only"
  dimensions: number
  chunks: Chunk[]
  oramaIndex: any
  sourceHashes: Record<string, string>
}

// --- Chunking (mirrors src/retrieval/knowledge.ts) ---

const OPCODE_PATTERN =
  /\b(oscil[is]?|phasor|tablei?|foscil[i]?|buzz|gbuzz|vco2?|pluck|grain[23]?|fog|sndwarp|loscil[3]?|diskin[2]?|poscil[3]?|lpf18|moogladder|moogvcf[2]?|butterlp|butterhp|butterbp|butterbr|tonex?|atonex?|resonx?|reson[xyz]?|clfilt|statevar|svfilter|zdf_[12]pole|diode_ladder|K35_[lh]pf|wpkurtz|bqrez|pareq|rbjeq|eqfil|peak|shelf|low_shelf|high_shelf|freeverb|reverbsc|reverb[12]?|alpass|comb|nestedap|nreverb|delay[1w]?|vdelay[3]?|flanger|phaser[12]|chorus|lfo|jitter[2]?|randh|randi|random|line[n]?|linseg[r]?|expseg[ra]?|transeg|madsr|mxadsr|adsr|xadsr|expon|jspline|rspline|oscbnk|hsboscil|GEN\d+|ftgen|table[iw]?|tablexkt|pan2|pan|vbap[gz]?|ampmidi|cpsmidi|notnum|veloc|midictrl|ctrl7|ctrl14|ctrl21|pcount|pindex|turnoff[2]?|schedkwhen|event|scoreline[_i]?|outch|out[ahq]?|outs|vincr|clear|zakinit|za[rw]|zkr|zkw|init|tival|reinit|rireturn|tigoto|timout|chnget|chnset|chn_k|chn_a|chn_S|invalue|outvalue|OSCsend|OSClisten|fout|foutk|fiopen|ficlose|pvoc|pvs\w+|partials|resyn|adsyn|sinsyn|tradsyn|stft|istft|window|pvscross|pvsfilter|pvsvoc|pvsmix|pvscale|pvshift|pvsfreeze|pvsmaska|pvsanal|pvsynth|pvsadsyn|pvsfread|pvsifd|pvsdiskin|pvscent|pvspitch|pvsbin|pvsblur|pvstencil|convolve|pconvolve|ftconv|dconv|lpread|lpreson|lpcfilter|cross2|distort[1]?|clip|powershape|chebyshevpoly|waveset|fold|decimator|bitcrush|declick|compress[2]?|dam|follow[2]?|rms|peak|max_k|downsamp|upsamp|interp|integ|diff|samphold|trigger|changed[2]?|metro[2]?|dust[2]?|gausstrig|mpulse|schedulek?|linsegr|expsegr|release|xtratim|active)\b/gi

const TECHNIQUE_PATTERN =
  /\b(FM synthesis|frequency modulation|additive synthesis|subtractive synthesis|granular synthesis|physical model|waveguide|modal synthesis|spectral processing|phase vocoder|convolution|wavetable|wave shaping|wave[- ]?terrain|ring modulation|amplitude modulation|cross[- ]?synthesis|formant|vocoder|noise|stochastic|Karplus.?Strong|bowed string|plucked string|wind instrument|brass|reed|flute|drum|percussion|envelope|LFO|vibrato|tremolo|portamento|glissando|reverb|delay|echo|filter|resonance|distortion|chorus|flanger|phaser|pan|spatialization|ambisonics|binaural|HRTF|MIDI|OSC|sampling|looping|time[- ]?stretch|pitch[- ]?shift|freeze|morph|interpolat)/gi

function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4)
}

function extractTags(text: string): string[] {
  const tags = new Set<string>()
  const opcodeMatches = text.match(OPCODE_PATTERN)
  if (opcodeMatches) opcodeMatches.forEach((m) => tags.add(m.toLowerCase()))
  const techMatches = text.match(TECHNIQUE_PATTERN)
  if (techMatches) techMatches.forEach((m) => tags.add(m.toLowerCase()))
  return [...tags]
}

function sanitizeID(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 60)
}

function isChapterHeader(line: string): { level: number; title: string } | null {
  const chapterMatch = line.match(/^(Chapter|CHAPTER|Part|PART)\s+(\d+|[IVXLC]+)[.:]\s*(.*)/)
  if (chapterMatch) return { level: 1, title: line.trim() }
  const sectionMatch = line.match(/^(\d+\.\d+)\s+(.+)/)
  if (sectionMatch) return { level: 2, title: line.trim() }
  if (line.length > 10 && line.length < 100 && line === line.toUpperCase() && /[A-Z]/.test(line)) {
    return { level: 1, title: line.trim() }
  }
  return null
}

function chunkSource(sourcePath: string, content: string, maxTokens = 350, overlapTokens = 30): Chunk[] {
  const lines = content.split("\n")
  const chunks: Chunk[] = []
  const sourceID = path.basename(sourcePath, path.extname(sourcePath))

  let currentSection = "Introduction"
  let currentSubsection = ""
  let buffer: string[] = []
  let bufferTokens = 0
  let chunkIndex = 0
  let inFrontMatter = true

  const flush = () => {
    if (buffer.length === 0 || bufferTokens < 20) return

    const text = buffer.join("\n").trim()
    if (!text) return

    const id = `${sourceID}-${sanitizeID(currentSection)}-${chunkIndex++}`
    chunks.push({
      id,
      source: sourceID,
      section: currentSection,
      subsection: currentSubsection,
      content: text,
      tokens: estimateTokens(text),
      tags: extractTags(text),
    })

    // Keep overlap
    const overlapLines: string[] = []
    let overlapCount = 0
    for (let i = buffer.length - 1; i >= 0 && overlapCount < overlapTokens; i--) {
      overlapLines.unshift(buffer[i])
      overlapCount += estimateTokens(buffer[i])
    }
    buffer = overlapLines
    bufferTokens = overlapCount
  }

  for (const line of lines) {
    // Skip front matter (match runtime knowledge.ts patterns)
    if (inFrontMatter) {
      const trimmed = line.trim()
      if (
        /^(Chapter|CHAPTER)\s+1\b/.test(trimmed) ||
        /^Part\s+[I1]\b/.test(trimmed) ||
        /^(Foreword|Introduction to Sound Design|1\.\s+Introduction)/i.test(trimmed)
      ) {
        inFrontMatter = false
      } else {
        continue
      }
    }

    const header = isChapterHeader(line)
    if (header) {
      flush()
      if (header.level === 1) {
        currentSection = header.title
        currentSubsection = ""
      } else {
        currentSubsection = header.title
      }
      continue
    }

    buffer.push(line)
    bufferTokens += estimateTokens(line)

    if (bufferTokens >= maxTokens) {
      flush()
    }
  }

  flush()
  return chunks
}

// --- Embedding ---

async function embedBatch(texts: string[], apiKey: string): Promise<number[][]> {
  const batchSize = 100
  const allVectors: number[][] = []

  for (let i = 0; i < texts.length; i += batchSize) {
    const batch = texts.slice(i, i + batchSize)
    console.log(`  Embedding batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(texts.length / batchSize)} (${batch.length} texts)...`)

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
    })

    if (!response.ok) {
      const err = await response.text()
      throw new Error(`OpenAI embedding failed: ${response.status} ${err}`)
    }

    const data = (await response.json()) as { data: Array<{ embedding: number[] }> }
    allVectors.push(...data.data.map((d) => d.embedding))

    if (i + batchSize < texts.length) {
      await new Promise((r) => setTimeout(r, 200))
    }
  }

  return allVectors
}

// --- Prose Bundle (Tier 2) ---

async function buildProseBundle() {
  console.log("=== Building Prose Bundle (Tier 2) ===\n")

  // Find source files
  const sourceFiles: string[] = []

  try {
    const entries = await fs.readdir(SOURCES_DIR)
    for (const entry of entries) {
      if (entry.endsWith(".txt") || entry.endsWith(".md")) {
        sourceFiles.push(path.join(SOURCES_DIR, entry))
      }
    }
  } catch {
    console.log(`Sources directory not found at ${SOURCES_DIR}`)
  }

  // Also check project root for csound_book.txt
  const rootBook = path.join(ROOT, "..", "..", "..", "csound_book.txt")
  try {
    await fs.stat(rootBook)
    sourceFiles.push(rootBook)
    console.log(`Found csound_book.txt at project root`)
  } catch {}

  if (sourceFiles.length === 0) {
    console.error("No knowledge source files found!")
    console.error(`Place .txt or .md files in ${SOURCES_DIR}`)
    process.exit(1)
  }

  console.log(`Found ${sourceFiles.length} source file(s):`)
  const sourceHashes: Record<string, string> = {}

  // Chunk all sources
  let allChunks: Chunk[] = []

  for (const sourcePath of sourceFiles) {
    const content = await fs.readFile(sourcePath, "utf-8")
    const hash = crypto.createHash("sha256").update(content).digest("hex").slice(0, 16)
    sourceHashes[path.basename(sourcePath)] = hash

    console.log(`  ${path.basename(sourcePath)}: ${content.split("\n").length} lines, hash=${hash}`)

    const chunks = chunkSource(sourcePath, content)
    console.log(`    -> ${chunks.length} chunks`)
    allChunks = allChunks.concat(chunks)
  }

  console.log(`\nTotal chunks: ${allChunks.length}`)

  // Load build cache for incremental embedding
  console.log("\nLoading build cache...")
  const cache = await loadCache()

  // Generate embeddings
  const apiKey = process.env.OPENAI_API_KEY
  let dimensions = 0
  let mode: "hybrid" | "bm25-only" = "bm25-only"
  const embeddingMap = new Map<string, number[]>()

  if (apiKey) {
    console.log("\nGenerating embeddings with OpenAI text-embedding-3-small...")
    try {
      const texts = allChunks.map((c) => c.content)

      // Check cache for each chunk embedding
      const missIndices: number[] = []
      const missTexts: string[] = []
      let embedCacheHits = 0

      for (let i = 0; i < allChunks.length; i++) {
        const contentHash = hashContent(texts[i])
        const cached = cache.embeddings[allChunks[i].id]
        if (cached && cached.contentHash === contentHash && cached.model === EMBEDDING_MODEL) {
          embeddingMap.set(allChunks[i].id, cached.vector)
          embedCacheHits++
        } else {
          missIndices.push(i)
          missTexts.push(texts[i])
        }
      }

      if (missTexts.length > 0) {
        console.log(`  Prose embeddings: ${embedCacheHits} cached, ${missTexts.length} new`)
        const vectors = await embedBatch(missTexts, apiKey)
        dimensions = vectors[0]?.length ?? 0

        for (let j = 0; j < missIndices.length; j++) {
          const idx = missIndices[j]
          embeddingMap.set(allChunks[idx].id, vectors[j])
          // Write to cache
          cache.embeddings[allChunks[idx].id] = {
            contentHash: hashContent(texts[idx]),
            vector: vectors[j],
            model: EMBEDDING_MODEL,
            timestamp: Date.now(),
          }
        }
        console.log(`  Generated ${vectors.length} new embeddings`)
      } else {
        console.log(`  Prose embeddings: ${embedCacheHits} cached, 0 new (all cached!)`)
        const firstCached = embeddingMap.values().next().value
        dimensions = firstCached?.length ?? 0
      }

      if (dimensions === 0) {
        const anyVec = embeddingMap.values().next().value
        dimensions = anyVec?.length ?? 0
      }
      mode = "hybrid"
    } catch (e) {
      console.warn(`  Embedding failed: ${e}`)
      console.log("  Falling back to BM25-only bundle")
    }
  } else {
    console.log("\nNo OPENAI_API_KEY — building BM25-only bundle")
    console.log("Set OPENAI_API_KEY to include vector embeddings")
  }

  // Save build cache
  await saveCache(cache)

  // Create Orama index
  console.log("\nBuilding Orama index...")

  const schema = {
    content: "string" as const,
    section: "string" as const,
    tags: "string" as const,
  } as Record<string, any>
  if (dimensions > 0) {
    schema.embedding = `vector[${dimensions}]`
  }

  const db = await create({ schema, id: "csound-knowledge" })

  const docs = allChunks.map((chunk) => {
    const doc: Record<string, any> = {
      id: chunk.id,
      content: chunk.content,
      section: chunk.section,
      tags: chunk.tags.join(" "),
    }
    if (dimensions > 0 && embeddingMap.has(chunk.id)) {
      doc.embedding = embeddingMap.get(chunk.id)
    }
    return doc
  })

  await insertMultiple(db, docs)
  const raw = await save(db)

  // Write bundle (backward compatible with existing format)
  const bundle: Bundle = {
    version: crypto.createHash("sha256").update(JSON.stringify(sourceHashes)).digest("hex").slice(0, 16),
    createdAt: Date.now(),
    mode,
    dimensions,
    chunks: allChunks,
    oramaIndex: raw,
    sourceHashes,
  }

  await fs.mkdir(path.dirname(BUNDLE_PATH), { recursive: true })
  await fs.writeFile(BUNDLE_PATH, JSON.stringify(bundle))

  const bundleSize = (await fs.stat(BUNDLE_PATH)).size
  console.log(`\nProse bundle written to ${BUNDLE_PATH}`)
  console.log(`  Size: ${(bundleSize / 1024 / 1024).toFixed(1)} MB`)
  console.log(`  Mode: ${mode}`)
  console.log(`  Chunks: ${allChunks.length}`)
  console.log(`  Version: ${bundle.version}`)

  // Write manifest
  await fs.writeFile(
    MANIFEST_PATH,
    JSON.stringify(
      {
        version: bundle.version,
        createdAt: bundle.createdAt,
        mode: bundle.mode,
        chunkCount: allChunks.length,
        sourceHashes,
      },
      null,
      2,
    ),
  )
  console.log(`  Manifest: ${MANIFEST_PATH}`)
}

// --- Full multi-tier build ---

async function buildAllTiers() {
  console.log("=== DrC Full Knowledge Bundle Builder (All Tiers) ===\n")
  console.log("This will build all four tiers:\n")
  console.log("  Tier 0: Opcode Cards      (bun run scripts/build-opcode-cards.ts)")
  console.log("  Tier 1: CSD Examples       (bun run scripts/build-csd-index.ts)")
  console.log("  Tier 2: Prose Chunks       (this script)")
  console.log("  Tier 3: Knowledge Graph    (bun run scripts/build-knowledge-graph.ts)")
  console.log()

  const { $ } = await import("bun")
  const scriptsDir = path.resolve(import.meta.dir)

  // Step 1: Build prose bundle (Tier 2)
  console.log("--- Step 1/4: Prose Bundle (Tier 2) ---\n")
  await buildProseBundle()

  // Step 2: Build CSD index (Tier 1)
  console.log("\n--- Step 2/4: CSD Example Index (Tier 1) ---\n")
  try {
    await $`bun run ${path.join(scriptsDir, "build-csd-index.ts")} --no-llm`
  } catch (e) {
    console.warn(`  Warning: CSD index build failed: ${e}`)
  }

  // Step 3: Build opcode cards (Tier 0)
  console.log("\n--- Step 3/4: Opcode Cards (Tier 0) ---\n")
  try {
    await $`bun run ${path.join(scriptsDir, "build-opcode-cards.ts")}`
  } catch (e) {
    console.warn(`  Warning: Opcode cards build failed: ${e}`)
  }

  // Step 4: Build knowledge graph (Tier 3) — depends on all other tiers
  console.log("\n--- Step 4/4: Knowledge Graph (Tier 3) ---\n")
  try {
    await $`bun run ${path.join(scriptsDir, "build-knowledge-graph.ts")}`
  } catch (e) {
    console.warn(`  Warning: Knowledge graph build failed: ${e}`)
  }

  // Summary
  console.log("\n=== Build Complete ===\n")
  console.log("Generated bundles:")
  const bundleFiles = ["bundle.json", "bundle-core.json", "bundle-examples.json", "bundle-csd.json", "opcode-cards.json"]
  for (const file of bundleFiles) {
    const filePath = path.join(OUTPUT_DIR, file)
    try {
      const stat = await fs.stat(filePath)
      console.log(`  ${file}: ${(stat.size / 1024 / 1024).toFixed(1)} MB`)
    } catch {
      console.log(`  ${file}: not generated`)
    }
  }
}

// --- Main ---

async function main() {
  if (buildAll) {
    await buildAllTiers()
  } else {
    await buildProseBundle()
  }
}

main().catch((e) => {
  console.error("Build failed:", e)
  process.exit(1)
})
