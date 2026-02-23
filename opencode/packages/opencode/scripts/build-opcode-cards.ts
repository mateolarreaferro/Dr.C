#!/usr/bin/env bun
/**
 * Build opcode reference cards from Canonical Manual text.
 *
 * Extracts structured opcode cards from the Csound Canonical Manual text
 * (produced by extract-pdf.ts). Uses regex patterns for bulk extraction
 * with optional LLM enrichment for descriptions and seeAlso links.
 *
 * Usage:
 *   bun run scripts/build-opcode-cards.ts [--no-llm] [--limit N]
 */

import fs from "fs/promises"
import path from "path"
import crypto from "crypto"
import type { OpcodeCard, OpcodeParameter, Domain } from "../src/retrieval/schema"

const ROOT = path.resolve(import.meta.dir, "..")
const SOURCES_DIR = path.join(ROOT, "resources", "knowledge", "sources")
const OUTPUT_DIR = path.join(ROOT, "resources", "knowledge")

const args = process.argv.slice(2)
const noLLM = args.includes("--no-llm")
const limitFlag = args.indexOf("--limit")
const limit = limitFlag >= 0 ? parseInt(args[limitFlag + 1], 10) : Infinity

// --- Opcode category mappings ---
const CATEGORY_MAP: Record<string, { category: string; domain: Domain }> = {
  // Oscillators & Synthesis
  oscil: { category: "oscillator", domain: "synthesis" },
  oscili: { category: "oscillator", domain: "synthesis" },
  oscil3: { category: "oscillator", domain: "synthesis" },
  poscil: { category: "oscillator", domain: "synthesis" },
  poscil3: { category: "oscillator", domain: "synthesis" },
  vco: { category: "oscillator", domain: "synthesis" },
  vco2: { category: "oscillator", domain: "synthesis" },
  vco2init: { category: "oscillator", domain: "synthesis" },
  buzz: { category: "oscillator", domain: "synthesis" },
  gbuzz: { category: "oscillator", domain: "synthesis" },
  foscil: { category: "fm-oscillator", domain: "synthesis" },
  foscili: { category: "fm-oscillator", domain: "synthesis" },
  crossfm: { category: "fm-oscillator", domain: "synthesis" },
  crossfmi: { category: "fm-oscillator", domain: "synthesis" },
  hsboscil: { category: "oscillator", domain: "synthesis" },
  oscbnk: { category: "oscillator", domain: "synthesis" },
  pdhalf: { category: "oscillator", domain: "synthesis" },
  pdhalfy: { category: "oscillator", domain: "synthesis" },
  pdclip: { category: "oscillator", domain: "synthesis" },

  // Granular
  grain: { category: "granular", domain: "synthesis" },
  grain3: { category: "granular", domain: "synthesis" },
  granule: { category: "granular", domain: "synthesis" },
  partikkel: { category: "granular", domain: "synthesis" },
  fog: { category: "granular", domain: "synthesis" },
  fof: { category: "formant", domain: "synthesis" },
  fof2: { category: "formant", domain: "synthesis" },
  diskgrain: { category: "granular", domain: "synthesis" },
  syncgrain: { category: "granular", domain: "synthesis" },

  // Physical Modeling
  wgbow: { category: "physical-model", domain: "synthesis" },
  wgflute: { category: "physical-model", domain: "synthesis" },
  wgclar: { category: "physical-model", domain: "synthesis" },
  wgbrass: { category: "physical-model", domain: "synthesis" },
  wgpluck: { category: "physical-model", domain: "synthesis" },
  wgpluck2: { category: "physical-model", domain: "synthesis" },
  repluck: { category: "physical-model", domain: "synthesis" },
  pluck: { category: "physical-model", domain: "synthesis" },
  streson: { category: "physical-model", domain: "synthesis" },
  barmodel: { category: "physical-model", domain: "synthesis" },
  mode: { category: "physical-model", domain: "synthesis" },

  // Sample Playback
  diskin: { category: "sample-playback", domain: "synthesis" },
  diskin2: { category: "sample-playback", domain: "synthesis" },
  loscil: { category: "sample-playback", domain: "synthesis" },
  loscil3: { category: "sample-playback", domain: "synthesis" },
  soundin: { category: "sample-playback", domain: "synthesis" },
  flooper: { category: "sample-playback", domain: "synthesis" },
  flooper2: { category: "sample-playback", domain: "synthesis" },
  sndwarp: { category: "sample-playback", domain: "synthesis" },
  sndwarpst: { category: "sample-playback", domain: "synthesis" },
  mincer: { category: "sample-playback", domain: "synthesis" },
  temposcal: { category: "sample-playback", domain: "synthesis" },

  // Noise
  noise: { category: "noise", domain: "synthesis" },
  pinkish: { category: "noise", domain: "synthesis" },
  dust: { category: "noise", domain: "synthesis" },
  dust2: { category: "noise", domain: "synthesis" },

  // Filters
  moogladder: { category: "filter", domain: "effects" },
  lpf18: { category: "filter", domain: "effects" },
  zdf_2pole: { category: "filter", domain: "effects" },
  zdf_ladder: { category: "filter", domain: "effects" },
  diode_ladder: { category: "filter", domain: "effects" },
  k35_lpf: { category: "filter", domain: "effects" },
  k35_hpf: { category: "filter", domain: "effects" },
  butterlp: { category: "filter", domain: "effects" },
  butterhp: { category: "filter", domain: "effects" },
  butterbp: { category: "filter", domain: "effects" },
  butterbs: { category: "filter", domain: "effects" },
  tone: { category: "filter", domain: "effects" },
  atone: { category: "filter", domain: "effects" },
  tonex: { category: "filter", domain: "effects" },
  atonex: { category: "filter", domain: "effects" },
  reson: { category: "filter", domain: "effects" },
  resonx: { category: "filter", domain: "effects" },
  areson: { category: "filter", domain: "effects" },
  bqrez: { category: "filter", domain: "effects" },
  svfilter: { category: "filter", domain: "effects" },
  statevar: { category: "filter", domain: "effects" },
  clfilt: { category: "filter", domain: "effects" },
  pareq: { category: "filter", domain: "effects" },
  eqfil: { category: "filter", domain: "effects" },

  // Reverb
  reverbsc: { category: "reverb", domain: "effects" },
  reverb: { category: "reverb", domain: "effects" },
  reverb2: { category: "reverb", domain: "effects" },
  freeverb: { category: "reverb", domain: "effects" },
  nreverb: { category: "reverb", domain: "effects" },
  babo: { category: "reverb", domain: "effects" },

  // Delay
  delay: { category: "delay", domain: "effects" },
  delay1: { category: "delay", domain: "effects" },
  delayr: { category: "delay", domain: "effects" },
  delayw: { category: "delay", domain: "effects" },
  deltap: { category: "delay", domain: "effects" },
  deltapi: { category: "delay", domain: "effects" },
  deltap3: { category: "delay", domain: "effects" },
  deltapx: { category: "delay", domain: "effects" },
  vdelay: { category: "delay", domain: "effects" },
  vdelay3: { category: "delay", domain: "effects" },
  multitap: { category: "delay", domain: "effects" },

  // Modulation effects
  flanger: { category: "modulation-effect", domain: "effects" },
  chorus: { category: "modulation-effect", domain: "effects" },
  phaser1: { category: "modulation-effect", domain: "effects" },
  phaser2: { category: "modulation-effect", domain: "effects" },

  // Distortion
  distort: { category: "distortion", domain: "effects" },
  distort1: { category: "distortion", domain: "effects" },
  clip: { category: "distortion", domain: "effects" },
  wrap: { category: "distortion", domain: "effects" },
  fold: { category: "distortion", domain: "effects" },
  powershape: { category: "distortion", domain: "effects" },
  tanh: { category: "distortion", domain: "effects" },
  chebyshevpoly: { category: "distortion", domain: "effects" },

  // Dynamics
  compress: { category: "dynamics", domain: "effects" },
  compress2: { category: "dynamics", domain: "effects" },
  dam: { category: "dynamics", domain: "effects" },
  follow: { category: "dynamics", domain: "effects" },
  follow2: { category: "dynamics", domain: "effects" },
  rms: { category: "dynamics", domain: "effects" },
  balance: { category: "dynamics", domain: "effects" },
  balance2: { category: "dynamics", domain: "effects" },

  // Spatialization
  pan2: { category: "spatialization", domain: "effects" },
  pan: { category: "spatialization", domain: "effects" },
  vbap4: { category: "spatialization", domain: "effects" },
  vbap8: { category: "spatialization", domain: "effects" },
  hrtfstat: { category: "spatialization", domain: "effects" },
  hrtfmove: { category: "spatialization", domain: "effects" },
  hrtfmove2: { category: "spatialization", domain: "effects" },
  bformenc1: { category: "spatialization", domain: "effects" },
  bformdec1: { category: "spatialization", domain: "effects" },

  // Convolution
  pconvolve: { category: "convolution", domain: "effects" },
  convolve: { category: "convolution", domain: "effects" },
  ftconv: { category: "convolution", domain: "effects" },
  dconv: { category: "convolution", domain: "effects" },

  // Spectral
  pvsanal: { category: "spectral", domain: "synthesis" },
  pvsynth: { category: "spectral", domain: "synthesis" },
  pvscross: { category: "spectral", domain: "synthesis" },
  pvsfilter: { category: "spectral", domain: "synthesis" },
  pvsmorph: { category: "spectral", domain: "synthesis" },
  pvsblur: { category: "spectral", domain: "synthesis" },
  pvswarp: { category: "spectral", domain: "synthesis" },
  pvshift: { category: "spectral", domain: "synthesis" },
  pvscale: { category: "spectral", domain: "synthesis" },
  pvsfreeze: { category: "spectral", domain: "synthesis" },
  pvsmaska: { category: "spectral", domain: "synthesis" },
  pvstencil: { category: "spectral", domain: "synthesis" },
  pvsadsyn: { category: "spectral", domain: "synthesis" },
  pvsbin: { category: "spectral", domain: "synthesis" },

  // Envelopes
  linen: { category: "envelope", domain: "modulation" },
  linenr: { category: "envelope", domain: "modulation" },
  adsr: { category: "envelope", domain: "modulation" },
  madsr: { category: "envelope", domain: "modulation" },
  mxadsr: { category: "envelope", domain: "modulation" },
  envlpx: { category: "envelope", domain: "modulation" },
  expon: { category: "envelope", domain: "modulation" },
  line: { category: "envelope", domain: "modulation" },
  linseg: { category: "envelope", domain: "modulation" },
  expseg: { category: "envelope", domain: "modulation" },
  transeg: { category: "envelope", domain: "modulation" },
  cosseg: { category: "envelope", domain: "modulation" },
  loopseg: { category: "envelope", domain: "modulation" },

  // LFO / Control
  lfo: { category: "lfo", domain: "modulation" },
  phasor: { category: "lfo", domain: "modulation" },
  jspline: { category: "random-control", domain: "modulation" },
  rspline: { category: "random-control", domain: "modulation" },
  jitter: { category: "random-control", domain: "modulation" },
  jitter2: { category: "random-control", domain: "modulation" },
  randh: { category: "random-control", domain: "modulation" },
  randi: { category: "random-control", domain: "modulation" },

  // Smoothing
  port: { category: "smoothing", domain: "modulation" },
  portk: { category: "smoothing", domain: "modulation" },
  tonek: { category: "smoothing", domain: "modulation" },
  atonek: { category: "smoothing", domain: "modulation" },

  // Scheduling
  schedule: { category: "scheduling", domain: "modulation" },
  schedkwhen: { category: "scheduling", domain: "modulation" },
  event: { category: "scheduling", domain: "modulation" },
  metro: { category: "scheduling", domain: "modulation" },
  trigger: { category: "scheduling", domain: "modulation" },
  changed: { category: "scheduling", domain: "modulation" },
  changed2: { category: "scheduling", domain: "modulation" },
  turnoff: { category: "scheduling", domain: "modulation" },
  turnoff2: { category: "scheduling", domain: "modulation" },

  // MIDI
  cpsmidi: { category: "midi", domain: "modulation" },
  ampmidi: { category: "midi", domain: "modulation" },
  notnum: { category: "midi", domain: "modulation" },
  veloc: { category: "midi", domain: "modulation" },
  ctrl7: { category: "midi", domain: "modulation" },
  ctrl14: { category: "midi", domain: "modulation" },
  ctrl21: { category: "midi", domain: "modulation" },
  massign: { category: "midi", domain: "modulation" },

  // Table
  ftgen: { category: "table", domain: "general" },
  table: { category: "table", domain: "general" },
  tablei: { category: "table", domain: "general" },
  tablew: { category: "table", domain: "general" },
  tablexkt: { category: "table", domain: "general" },

  // I/O
  chnget: { category: "channel-io", domain: "general" },
  chnset: { category: "channel-io", domain: "general" },
  outch: { category: "audio-io", domain: "general" },
  outs: { category: "audio-io", domain: "general" },
  out: { category: "audio-io", domain: "general" },
  inch: { category: "audio-io", domain: "general" },
  in: { category: "audio-io", domain: "general" },
  ins: { category: "audio-io", domain: "general" },
}

/**
 * Generate opcode cards from the category map.
 * When manual text is available, enrich with parsed descriptions.
 */
function generateCardsFromMap(): OpcodeCard[] {
  const cards: OpcodeCard[] = []

  for (const [name, { category, domain }] of Object.entries(CATEGORY_MAP)) {
    const card: OpcodeCard = {
      name,
      category,
      syntax: `... ${name} ...`, // Placeholder — enriched by LLM or manual parse
      description: `${name} — ${category} opcode`,
      parameters: [],
      seeAlso: findSeeAlso(name, category),
      domain,
      tags: [category, domain],
      exampleIDs: [],
    }

    cards.push(card)
  }

  return cards
}

function findSeeAlso(name: string, category: string): string[] {
  // Find other opcodes in the same category
  return Object.entries(CATEGORY_MAP)
    .filter(([n, c]) => c.category === category && n !== name)
    .map(([n]) => n)
    .slice(0, 4) // Limit to 4 related opcodes
}

/**
 * Parse opcode entries from Canonical Manual text (if available).
 */
async function parseManualText(manualPath: string): Promise<Map<string, Partial<OpcodeCard>>> {
  const parsed = new Map<string, Partial<OpcodeCard>>()

  try {
    const text = await fs.readFile(manualPath, "utf-8")
    const lines = text.split("\n")

    // Simple opcode entry detection
    // Manual typically has entries like:
    // opcodename
    //   Description text
    //   Syntax: aout opcode ain, kparam
    let currentOpcode: string | null = null
    let descLines: string[] = []
    let syntaxLine: string | null = null

    for (const line of lines) {
      const trimmed = line.trim()

      // Detect opcode name (single word on its own line, matches known opcodes)
      if (/^[a-z][a-z0-9_]+$/.test(trimmed) && CATEGORY_MAP[trimmed]) {
        // Save previous
        if (currentOpcode) {
          parsed.set(currentOpcode, {
            description: descLines.join(" ").slice(0, 200),
            syntax: syntaxLine ?? `... ${currentOpcode} ...`,
          })
        }
        currentOpcode = trimmed
        descLines = []
        syntaxLine = null
        continue
      }

      if (currentOpcode) {
        // Look for syntax line
        if (/^(Syntax|SYNTAX)/i.test(trimmed) || /^\w+\s+\w+\s+\w+,/.test(trimmed)) {
          syntaxLine = trimmed.replace(/^Syntax[:\s]*/i, "")
        }
        // Accumulate description
        else if (trimmed.length > 10 && descLines.length < 3) {
          descLines.push(trimmed)
        }
      }
    }

    // Save last
    if (currentOpcode) {
      parsed.set(currentOpcode, {
        description: descLines.join(" ").slice(0, 200),
        syntax: syntaxLine ?? `... ${currentOpcode} ...`,
      })
    }

    console.log(`  Parsed ${parsed.size} opcode descriptions from manual`)
  } catch {
    console.log("  No manual text available, using placeholder descriptions")
  }

  return parsed
}

/**
 * Enrich cards with CSD corpus usage data (exampleIDs).
 */
async function enrichWithExampleUsage(cards: OpcodeCard[]): Promise<void> {
  const examplesBundlePath = path.join(OUTPUT_DIR, "bundle-examples.json")

  try {
    const data = await fs.readFile(examplesBundlePath, "utf-8")
    const bundle = JSON.parse(data)

    for (const card of cards) {
      const matchingExamples = bundle.examples
        .filter((ex: any) => ex.opcodes.includes(card.name))
        .slice(0, 5)
        .map((ex: any) => ex.id)
      card.exampleIDs = matchingExamples
    }

    console.log(`  Enriched cards with example IDs from ${bundle.examples.length} examples`)
  } catch {
    console.log("  No examples bundle found, skipping example enrichment")
  }
}

async function main() {
  console.log("=== DrC Opcode Card Builder ===\n")

  // Generate base cards from category map
  let cards = generateCardsFromMap()
  console.log(`Generated ${cards.length} base opcode cards`)

  // Enrich with manual text if available
  const manualPath = path.join(SOURCES_DIR, "canonical_manual.txt")
  const manualParsed = await parseManualText(manualPath)
  for (const card of cards) {
    const manual = manualParsed.get(card.name)
    if (manual) {
      if (manual.description) card.description = manual.description
      if (manual.syntax) card.syntax = manual.syntax
    }
  }

  // Apply limit
  if (limit < Infinity) {
    cards = cards.slice(0, limit)
    console.log(`Limited to ${cards.length} cards`)
  }

  // Enrich with example usage
  await enrichWithExampleUsage(cards)

  // Write output
  await fs.mkdir(OUTPUT_DIR, { recursive: true })
  const outputPath = path.join(OUTPUT_DIR, "opcode-cards.json")
  await fs.writeFile(outputPath, JSON.stringify(cards, null, 2))

  const outputSize = (await fs.stat(outputPath)).size
  console.log(`\nOutput: ${outputPath}`)
  console.log(`  Cards: ${cards.length}`)
  console.log(`  Size: ${(outputSize / 1024).toFixed(0)} KB`)
  console.log(`  Categories: ${new Set(cards.map((c) => c.category)).size}`)
}

main().catch((e) => {
  console.error("Build failed:", e)
  process.exit(1)
})
