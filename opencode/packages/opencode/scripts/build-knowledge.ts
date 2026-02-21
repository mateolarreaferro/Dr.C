#!/usr/bin/env bun
/**
 * Build-time script to pre-compute knowledge index + embeddings.
 *
 * Usage:
 *   bun run scripts/build-knowledge.ts
 *
 * This script:
 * 1. Reads all knowledge source files
 * 2. Chunks them using CsoundKnowledge.chunk()
 * 3. Generates embeddings via OpenAI API (requires OPENAI_API_KEY)
 * 4. Creates an Orama index with chunks + embeddings
 * 5. Saves bundle to resources/knowledge/bundle.json
 *
 * The bundle is shipped with the binary so users don't need API keys
 * for retrieval to work.
 */

import { create, insertMultiple, save } from "@orama/orama"
import fs from "fs/promises"
import path from "path"
import crypto from "crypto"

const ROOT = path.resolve(import.meta.dir, "..")
const SOURCES_DIR = path.join(ROOT, "resources", "knowledge", "sources")
const BUNDLE_PATH = path.join(ROOT, "resources", "knowledge", "bundle.json")
const MANIFEST_PATH = path.join(ROOT, "resources", "knowledge", "manifest.json")

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
    // Skip front matter
    if (inFrontMatter) {
      if (/^(Chapter|CHAPTER)\s+1\b/.test(line) || /^Part\s+[I1]\b/.test(line)) {
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

// --- Main ---

async function main() {
  console.log("=== DrC Knowledge Bundle Builder ===\n")

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
  const rootBook = path.join(ROOT, "..", "..", "csound_book.txt")
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
    console.log(`    → ${chunks.length} chunks`)
    allChunks = allChunks.concat(chunks)
  }

  console.log(`\nTotal chunks: ${allChunks.length}`)

  // Generate embeddings
  const apiKey = process.env.OPENAI_API_KEY
  let dimensions = 0
  let mode: "hybrid" | "bm25-only" = "bm25-only"
  const embeddingMap = new Map<string, number[]>()

  if (apiKey) {
    console.log("\nGenerating embeddings with OpenAI text-embedding-3-small...")
    try {
      const texts = allChunks.map((c) => c.content)
      const vectors = await embedBatch(texts, apiKey)
      dimensions = vectors[0]?.length ?? 0
      mode = "hybrid"

      for (let i = 0; i < allChunks.length; i++) {
        embeddingMap.set(allChunks[i].id, vectors[i])
      }
      console.log(`  ✓ ${vectors.length} embeddings (${dimensions} dimensions)`)
    } catch (e) {
      console.warn(`  ✗ Embedding failed: ${e}`)
      console.log("  Falling back to BM25-only bundle")
    }
  } else {
    console.log("\nNo OPENAI_API_KEY — building BM25-only bundle")
    console.log("Set OPENAI_API_KEY to include vector embeddings")
  }

  // Create Orama index
  console.log("\nBuilding Orama index...")

  const schema: Record<string, string> = {
    content: "string",
    section: "string",
    tags: "string",
  }
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

  // Write bundle
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
  console.log(`\n✓ Bundle written to ${BUNDLE_PATH}`)
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

main().catch((e) => {
  console.error("Build failed:", e)
  process.exit(1)
})
