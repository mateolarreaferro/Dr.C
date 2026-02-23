#!/usr/bin/env bun
/**
 * Build-time CSD example index for Tier 1 (CAG).
 *
 * Processes all CSD files in knowledge/curated/ and knowledge/examples/:
 * 1. Parse instruments, opcodes, globals using CSD section extraction
 * 2. Classify techniques with rule-based opcode-to-technique mapper
 * 3. Optionally enrich with LLM (Claude Haiku) for descriptions, sonic tags
 * 4. Score complexity
 * 5. Build Orama sub-index over metadata
 * 6. Generate embeddings (OpenAI text-embedding-3-small)
 * 7. Store CSD content separately in bundle-csd.json
 *
 * Usage:
 *   bun run scripts/build-csd-index.ts [--no-llm] [--no-embeddings] [--limit N]
 */

import { create, insertMultiple, save } from "@orama/orama"
import fs from "fs/promises"
import path from "path"
import crypto from "crypto"
import { TechniqueClassifier } from "../src/retrieval/technique-classifier"
import type { CsdExample, CsdInstrumentMeta, ExamplesBundle, CsdContentBundle, Domain } from "../src/retrieval/schema"
import { enrichBatch, estimateCost } from "./lib/llm-enrichment"
import type { EnrichmentInput } from "./lib/llm-enrichment"
import { loadCache, saveCache, hashContent, ENRICHMENT_MODEL, EMBEDDING_MODEL, type BuildCache } from "./lib/build-cache"

const ROOT = path.resolve(import.meta.dir, "..")
const PROJECT_ROOT = path.resolve(ROOT, "..", "..", "..")
const KNOWLEDGE_DIR = path.join(PROJECT_ROOT, "knowledge")
const OUTPUT_DIR = path.join(ROOT, "resources", "knowledge")

// Parse CLI flags
const args = process.argv.slice(2)
const noLLM = args.includes("--no-llm")
const noEmbeddings = args.includes("--no-embeddings")
const limitFlag = args.indexOf("--limit")
const limit = limitFlag >= 0 ? parseInt(args[limitFlag + 1], 10) : Infinity

// --- CSD source directories ---
const CSD_DIRS = [
  { dir: path.join(KNOWLEDGE_DIR, "curated"), prefix: "curated" },
  { dir: path.join(KNOWLEDGE_DIR, "examples"), prefix: "examples" },
]

// --- Source name mapping ---
const SOURCE_MAP: Record<string, string> = {
  "_CURATED-SYNTHESIS-BoulangerBook": "BoulangerBook",
  "_CURATED-SYNTHESIS-Boulanger-Trapped+Variations": "BoulangerTrapped",
  "_CURATED-SYNTHESIS-BoulangerBook-CD": "BoulangerCD",
  "_CURATED-SYNTHESIS-DodgeBook": "DodgeBook",
  "_CURATED-SYNTHESIS-HornerBook": "HornerBook",
  "_CURATED-SYNTHESIS-LazzariniBook-Csound": "LazzariniCsound",
  "_CURATED-SYNTHESIS-LazzariniBook-Spectral": "LazzariniSpectral",
  "_CURATED-SYNTHESIS-Manual-Csound": "CsoundManual",
  "_CURATED-SYNTHESIS-ZuccoBook": "ZuccoBook",
  "_CURATED-SYNTHESIS-Biancinni&CiprianiBook": "BianchiniCipriani",
  "_EXAMPLES-MANUAL-Floss-V7": "FlossManual",
}

// --- CSD Parsing (lightweight, no full CsdParser dependency) ---

interface ParsedCsd {
  instruments: CsdInstrumentMeta[]
  opcodes: string[]
  globals: { sr?: number; ksmps?: number; nchnls?: number; dbfs?: number }
  instrumentsSection: string
  hasScore: boolean
  hasOptions: boolean
}

const OPCODE_PATTERN =
  /\b(oscili?|poscil|vco2?|moogladder|lpf18|zdf_2pole|zdf_ladder|butterlp|butterhp|butterbp|butterbs|reverbsc|reverb2?|freeverb|nreverb|delay[rw]?|deltap[i3]?|flanger|chorus|phaser[12]|distort1?|tanh|powershape|clip|wrap|fold|bitcrusher|decimator|loscil[3]?|diskin2?|soundin|foscili?|buzz|gbuzz|grain3?|partikkel|fog|fof2?|wgpluck2?|wgbow|wgflute|wgclar|repluck|pluck|noise|pinkish|rand[hi]?|jitter2?|randi?|linen|linenr|adsr|madsr|mxadsr|expon|line|envlpx|linseg|expseg|transeg|cosseg|loopseg|jspline|rspline|port|portk|tonek?|atonek?|tonex|reson|resonx?|areson|bqrez|svfilter|statevar|mode|compress2?|dam|follow2?|rms|balance2?|pan2?|vbap[48]?|hrtfstat|hrtfmove2?|pvsanal|pvsynth|pvscross|pvsfilter|pvsmorph|pvsblur|pvswarp|pvshift|pvscale|pvsfread|pvsfreeze|pvsmaska|pvstencil|pvsadsyn|pvsbin|lfo|phasor|metro|trigger|changed2?|schedule|schedkwhen|ftgen|chnget|chnset|tablei?|oscbnk|mincer|temposcal|flooper2?|pconvolve|ftconv|dconv|GEN\d{1,2}|outch|outs|out|inch|ins?|xin|xout|setksmps|turnoff2?|active|massign|pgmassign|cpsmidi|ampmidi|notnum|veloc|ctrl7|ctrl14|pdhalf|pdhalfy|pdclip|chebyshevpoly|crossfm|crossfmi|hsboscil|oscbnk|dust2?|gausstrig|mpulse|vco2init|delayr|delayw|alpass|comb|nestedap|nreverb|babo|hrtfreverb|vdelay|vdelay3|multitap|pan|vbaplsinit|bformenc1|bformdec1|streson|barmodel|exciter|downsamp|upsamp|interp|peak|max_k|samphold|diff|integ|mirror|limit|divz|abs|sqrt|exp|log|pow|frac|int|round|ceil|floor|db|ampdb|ampdbfs|dbamp|dbfsamp|cpsoct|octcps|cpspch|semitone|cent)\b/gi

function parseCsd(content: string): ParsedCsd {
  const result: ParsedCsd = {
    instruments: [],
    opcodes: [],
    globals: {},
    instrumentsSection: "",
    hasScore: false,
    hasOptions: false,
  }

  // Extract sections
  const instrMatch = content.match(/<CsInstruments>([\s\S]*?)<\/CsInstruments>/i)
  if (instrMatch) result.instrumentsSection = instrMatch[1].trim()

  result.hasScore = /<CsScore>/i.test(content)
  result.hasOptions = /<CsOptions>/i.test(content)

  // Extract globals
  const srMatch = result.instrumentsSection.match(/\bsr\s*=\s*(\d+)/i)
  if (srMatch) result.globals.sr = parseInt(srMatch[1])
  const ksmpsMatch = result.instrumentsSection.match(/\bksmps\s*=\s*(\d+)/i)
  if (ksmpsMatch) result.globals.ksmps = parseInt(ksmpsMatch[1])
  const nchnlsMatch = result.instrumentsSection.match(/\bnchnls\s*=\s*(\d+)/i)
  if (nchnlsMatch) result.globals.nchnls = parseInt(nchnlsMatch[1])
  const dbfsMatch = result.instrumentsSection.match(/\b0dbfs\s*=\s*([\d.]+)/i)
  if (dbfsMatch) result.globals.dbfs = parseFloat(dbfsMatch[1])

  // Extract instruments
  const instrBlocks = result.instrumentsSection.matchAll(/\binstr\s+(\S+)([\s\S]*?)\bendin\b/gi)
  for (const match of instrBlocks) {
    const instrId = match[1]
    const instrBody = match[2]
    const instrOpcodes = instrBody.match(OPCODE_PATTERN) ?? []
    const uniqueOpcodes = [...new Set(instrOpcodes.map((o) => o.toLowerCase()))]

    // Count tuneable parameters (k-rate variables with init or chnget)
    const paramCount = (instrBody.match(/\bk\w+\s+(init|chnget|=)/gi) ?? []).length

    result.instruments.push({
      id: instrId,
      opcodes: uniqueOpcodes,
      paramCount,
    })
  }

  // Extract all opcodes from the full instruments section
  const allOpcodes = result.instrumentsSection.match(OPCODE_PATTERN) ?? []
  result.opcodes = [...new Set(allOpcodes.map((o) => o.toLowerCase()))]

  return result
}

function resolveSource(filePath: string): string {
  for (const [dirName, sourceName] of Object.entries(SOURCE_MAP)) {
    if (filePath.includes(dirName)) return sourceName
  }
  return "Unknown"
}

function generateExampleID(source: string, filename: string): string {
  const baseName = path.basename(filename, ".csd")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
  return `${source.toLowerCase()}-${baseName}`
}

function generateTitle(filename: string, source: string): string {
  const baseName = path.basename(filename, ".csd")
  // Convert snake_case/kebab-case to title case
  return baseName
    .replace(/[_-]+/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase())
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
  console.log("=== DrC CSD Example Index Builder ===\n")

  // Discover all CSD files
  const csdFiles: Array<{ path: string; source: string }> = []

  for (const { dir } of CSD_DIRS) {
    try {
      await fs.access(dir)
    } catch {
      console.log(`Skipping ${dir} (not found)`)
      continue
    }

    // Recursively find .csd files
    const findCsd = async (dirPath: string) => {
      const entries = await fs.readdir(dirPath, { withFileTypes: true })
      for (const entry of entries) {
        const fullPath = path.join(dirPath, entry.name)
        if (entry.isDirectory()) {
          await findCsd(fullPath)
        } else if (entry.name.endsWith(".csd")) {
          const source = resolveSource(fullPath)
          csdFiles.push({ path: fullPath, source })
        }
      }
    }

    await findCsd(dir)
  }

  const totalFiles = Math.min(csdFiles.length, limit)
  console.log(`Found ${csdFiles.length} CSD files, processing ${totalFiles}`)

  if (totalFiles === 0) {
    console.error("No CSD files found!")
    process.exit(1)
  }

  // Process each CSD
  const examples: CsdExample[] = []
  const contentMap: Record<string, string> = {}
  const enrichmentInputs: EnrichmentInput[] = []
  let parseErrors = 0

  console.log("\nPhase 1: Parsing and classifying CSD files...")

  for (let i = 0; i < totalFiles; i++) {
    const { path: csdPath, source } = csdFiles[i]
    const filename = path.basename(csdPath)

    if (i > 0 && i % 200 === 0) {
      console.log(`  Processed ${i}/${totalFiles}...`)
    }

    try {
      const content = await fs.readFile(csdPath, "utf-8")

      // Skip empty or trivially small files
      if (content.length < 50) continue

      const parsed = parseCsd(content)

      // Skip files with no instruments
      if (parsed.instruments.length === 0 && parsed.opcodes.length === 0) continue

      const id = generateExampleID(source, filename)
      const title = generateTitle(filename, source)

      // Classify techniques
      const classification = TechniqueClassifier.classify(parsed.opcodes)

      const example: CsdExample = {
        id,
        source,
        filename,
        title,
        techniques: classification.techniques.map((t) => t.technique),
        primaryTechnique: classification.primaryTechnique,
        opcodes: parsed.opcodes,
        domain: classification.domain,
        complexity: classification.complexity,
        instruments: parsed.instruments,
        description: "", // Filled by LLM or fallback
        pedagogicalValue: "",
        signalFlow: "",
        sonicTags: [],
        qualityScore: 0.5, // Default neutral
      }

      examples.push(example)
      contentMap[id] = content

      // Prepare for LLM enrichment
      enrichmentInputs.push({
        id,
        filename,
        source,
        instrumentsSection: parsed.instrumentsSection,
        opcodes: parsed.opcodes,
        ruleBasedTechnique: classification.primaryTechnique,
      })
    } catch (e) {
      parseErrors++
      if (parseErrors <= 5) {
        console.warn(`  Warning: Failed to parse ${filename}: ${e}`)
      }
    }
  }

  console.log(`\n  Parsed: ${examples.length} examples`)
  console.log(`  Parse errors: ${parseErrors}`)
  console.log(`  Techniques found: ${new Set(examples.map((e) => e.primaryTechnique)).size} unique`)

  // Print technique distribution
  const techCounts = new Map<string, number>()
  for (const ex of examples) {
    techCounts.set(ex.primaryTechnique, (techCounts.get(ex.primaryTechnique) ?? 0) + 1)
  }
  console.log("\n  Technique distribution:")
  const sorted = [...techCounts.entries()].sort((a, b) => b[1] - a[1])
  for (const [tech, count] of sorted.slice(0, 15)) {
    console.log(`    ${tech}: ${count}`)
  }

  // Load build cache for incremental processing
  console.log("\nLoading build cache...")
  const cache = await loadCache()

  // Phase 2: LLM enrichment (optional)
  const anthropicKey = process.env.ANTHROPIC_API_KEY
  if (!noLLM && anthropicKey) {
    console.log(`\nPhase 2: LLM enrichment with Claude Haiku`)

    // Check cache for each enrichment input
    const cacheMisses: EnrichmentInput[] = []
    let cacheHits = 0

    for (const input of enrichmentInputs) {
      const contentHash = hashContent(input.instrumentsSection)
      const cached = cache.enrichments[input.id]
      if (cached && cached.contentHash === contentHash && cached.model === ENRICHMENT_MODEL) {
        // Cache hit — apply cached enrichment directly
        const example = examples.find((e) => e.id === input.id)
        if (example) {
          example.description = cached.enrichment.description
          example.primaryTechnique = cached.enrichment.primaryTechnique
          example.pedagogicalValue = cached.enrichment.pedagogicalValue
          example.signalFlow = cached.enrichment.signalFlow
          example.sonicTags = cached.enrichment.sonicTags
        }
        cacheHits++
      } else {
        cacheMisses.push(input)
      }
    }

    if (cacheMisses.length > 0) {
      const cost = estimateCost(cacheMisses.length)
      console.log(`  LLM enrichment: ${cacheHits} cached, ${cacheMisses.length} new`)
      console.log(`  Estimated cost for new: ~$${cost.estimatedUSD.toFixed(2)}`)

      const enriched = await enrichBatch(cacheMisses, anthropicKey)

      // Apply enrichment results and update cache
      const enrichMap = new Map(enriched.map((e) => [e.id, e]))
      for (const input of cacheMisses) {
        const enrichment = enrichMap.get(input.id)
        if (enrichment) {
          const example = examples.find((e) => e.id === input.id)
          if (example) {
            example.description = enrichment.description
            example.primaryTechnique = enrichment.primaryTechnique
            example.pedagogicalValue = enrichment.pedagogicalValue
            example.signalFlow = enrichment.signalFlow
            example.sonicTags = enrichment.sonicTags
          }
          // Write to cache
          cache.enrichments[input.id] = {
            contentHash: hashContent(input.instrumentsSection),
            enrichment: {
              description: enrichment.description,
              primaryTechnique: enrichment.primaryTechnique,
              pedagogicalValue: enrichment.pedagogicalValue,
              signalFlow: enrichment.signalFlow,
              sonicTags: enrichment.sonicTags,
            },
            model: ENRICHMENT_MODEL,
            timestamp: Date.now(),
          }
        }
      }

      console.log(`  Enriched ${enriched.length} new examples`)
    } else {
      console.log(`  LLM enrichment: ${cacheHits} cached, 0 new (all cached!)`)
    }
  } else if (noLLM) {
    console.log("\nPhase 2: Skipping LLM enrichment (--no-llm)")
    // Apply rule-based fallback descriptions
    for (const example of examples) {
      example.description = `${example.primaryTechnique} instrument using ${example.opcodes.slice(0, 3).join(", ")}`
      example.pedagogicalValue = `Demonstrates ${example.primaryTechnique} techniques`
      example.signalFlow = "signal -> output"
    }
  } else {
    console.log("\nPhase 2: Skipping LLM enrichment (no ANTHROPIC_API_KEY)")
    for (const example of examples) {
      example.description = `${example.primaryTechnique} instrument using ${example.opcodes.slice(0, 3).join(", ")}`
      example.pedagogicalValue = `Demonstrates ${example.primaryTechnique} techniques`
      example.signalFlow = "signal -> output"
    }
  }

  // Phase 3: Embeddings (optional)
  const openaiKey = process.env.OPENAI_API_KEY
  let dimensions = 0
  let mode: "hybrid" | "bm25-only" = "bm25-only"
  const embeddingMap = new Map<string, number[]>()

  if (!noEmbeddings && openaiKey) {
    console.log("\nPhase 3: Generating embeddings with OpenAI text-embedding-3-small...")
    try {
      // Create embedding text from metadata
      const texts = examples.map(
        (ex) => `${ex.title} ${ex.description} ${ex.primaryTechnique} ${ex.techniques.join(" ")} ${ex.sonicTags.join(" ")} ${ex.opcodes.slice(0, 10).join(" ")}`,
      )

      // Check cache for each embedding
      const missIndices: number[] = []
      const missTexts: string[] = []
      let embedCacheHits = 0

      for (let i = 0; i < examples.length; i++) {
        const contentHash = hashContent(texts[i])
        const cached = cache.embeddings[examples[i].id]
        if (cached && cached.contentHash === contentHash && cached.model === EMBEDDING_MODEL) {
          embeddingMap.set(examples[i].id, cached.vector)
          embedCacheHits++
        } else {
          missIndices.push(i)
          missTexts.push(texts[i])
        }
      }

      if (missTexts.length > 0) {
        console.log(`  Embeddings: ${embedCacheHits} cached, ${missTexts.length} new`)
        const vectors = await embedBatch(missTexts, openaiKey)
        dimensions = vectors[0]?.length ?? 0

        for (let j = 0; j < missIndices.length; j++) {
          const idx = missIndices[j]
          embeddingMap.set(examples[idx].id, vectors[j])
          // Write to cache
          cache.embeddings[examples[idx].id] = {
            contentHash: hashContent(texts[idx]),
            vector: vectors[j],
            model: EMBEDDING_MODEL,
            timestamp: Date.now(),
          }
        }
        console.log(`  Generated ${vectors.length} new embeddings`)
      } else {
        console.log(`  Embeddings: ${embedCacheHits} cached, 0 new (all cached!)`)
        // Get dimensions from a cached vector
        const firstCached = embeddingMap.values().next().value
        dimensions = firstCached?.length ?? 0
      }

      // Set dimensions from any available vector if not yet set
      if (dimensions === 0) {
        const anyVec = embeddingMap.values().next().value
        dimensions = anyVec?.length ?? 0
      }
      mode = "hybrid"
    } catch (e) {
      console.warn(`  Embedding failed: ${e}`)
      console.log("  Falling back to BM25-only")
    }
  } else {
    console.log("\nPhase 3: Skipping embeddings" + (noEmbeddings ? " (--no-embeddings)" : " (no OPENAI_API_KEY)"))
  }

  // Save build cache
  await saveCache(cache)

  // Phase 4: Build Orama index
  console.log("\nPhase 4: Building Orama search index...")

  const schema = {
    title: "string" as const,
    techniques: "string" as const,
    opcodes: "string" as const,
    domain: "string" as const,
    description: "string" as const,
    sonicTags: "string" as const,
    primaryTechnique: "string" as const,
  } as Record<string, any>
  if (dimensions > 0) {
    schema.embedding = `vector[${dimensions}]`
  }

  const db = await create({ schema, id: "csd-examples" })

  const docs = examples.map((ex) => {
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
    if (dimensions > 0 && embeddingMap.has(ex.id)) {
      doc.embedding = embeddingMap.get(ex.id)
    }
    return doc
  })

  await insertMultiple(db, docs)
  const oramaIndex = await save(db)

  // Phase 5: Write output bundles
  console.log("\nPhase 5: Writing output bundles...")

  await fs.mkdir(OUTPUT_DIR, { recursive: true })

  // bundle-examples.json (metadata + Orama index)
  const examplesBundle: ExamplesBundle = {
    version: crypto.createHash("sha256").update(JSON.stringify(examples.map((e) => e.id))).digest("hex").slice(0, 16),
    createdAt: Date.now(),
    mode,
    dimensions,
    examples,
    oramaIndex,
  }

  const examplesBundlePath = path.join(OUTPUT_DIR, "bundle-examples.json")
  await fs.writeFile(examplesBundlePath, JSON.stringify(examplesBundle))
  const exBundleSize = (await fs.stat(examplesBundlePath)).size

  // bundle-csd.json (full CSD content, lazy-loaded)
  const csdBundle: CsdContentBundle = {
    version: examplesBundle.version,
    createdAt: Date.now(),
    contents: contentMap,
  }

  const csdBundlePath = path.join(OUTPUT_DIR, "bundle-csd.json")
  await fs.writeFile(csdBundlePath, JSON.stringify(csdBundle))
  const csdBundleSize = (await fs.stat(csdBundlePath)).size

  console.log(`\n=== Build Complete ===`)
  console.log(`  Examples: ${examples.length}`)
  console.log(`  Mode: ${mode}`)
  console.log(`  bundle-examples.json: ${(exBundleSize / 1024 / 1024).toFixed(1)} MB`)
  console.log(`  bundle-csd.json: ${(csdBundleSize / 1024 / 1024).toFixed(1)} MB`)
  console.log(`  Unique techniques: ${new Set(examples.map((e) => e.primaryTechnique)).size}`)
  console.log(`  Unique sources: ${new Set(examples.map((e) => e.source)).size}`)

  // Domain distribution
  const domainCounts = new Map<string, number>()
  for (const ex of examples) {
    domainCounts.set(ex.domain, (domainCounts.get(ex.domain) ?? 0) + 1)
  }
  console.log(`  Domain distribution:`)
  for (const [domain, count] of domainCounts) {
    console.log(`    ${domain}: ${count}`)
  }
}

main().catch((e) => {
  console.error("Build failed:", e)
  process.exit(1)
})
