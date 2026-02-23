/**
 * Rule-based opcode-to-technique classifier for CSD files.
 * Maps sets of opcodes to synthesis/processing techniques with confidence scoring.
 * Used as first-pass classification before optional LLM enrichment.
 */

import type { Domain } from "./schema"

export namespace TechniqueClassifier {
  export interface TechniqueMatch {
    technique: string
    confidence: number // 0-1
    domain: Domain
    matchedOpcodes: string[]
  }

  export interface ClassificationResult {
    techniques: TechniqueMatch[]
    primaryTechnique: string
    domain: Domain
    complexity: "basic" | "intermediate" | "advanced"
  }

  // Each pattern: opcodes that strongly indicate a technique.
  // 'required' opcodes must be present; 'indicators' add confidence.
  interface TechniquePattern {
    technique: string
    domain: Domain
    required: string[][] // OR groups — any group match satisfies
    indicators: string[] // Additional opcodes that boost confidence
    weight: number // Base relevance weight
  }

  const PATTERNS: TechniquePattern[] = [
    // --- Synthesis ---
    {
      technique: "FM synthesis",
      domain: "synthesis",
      required: [["foscil", "foscili"], ["crossfm", "crossfmi"]],
      indicators: ["fmbell", "fmrhode", "fmwurlie", "fmmetal", "fmpercfl", "fmvoice", "fmb3"],
      weight: 1.0,
    },
    {
      technique: "additive synthesis",
      domain: "synthesis",
      required: [["oscil", "oscili", "poscil"], ["GEN10", "GEN09", "GEN19"]],
      indicators: ["ftgen", "oscilikt", "oscbnk"],
      weight: 0.7, // Lower since oscil alone is generic
    },
    {
      technique: "subtractive synthesis",
      domain: "synthesis",
      required: [
        ["moogladder", "lpf18", "zdf_ladder", "zdf_2pole", "butterlp", "bqrez", "svfilter", "statevar", "diode_ladder", "k35_lpf"],
      ],
      indicators: ["vco2", "vco", "sawtooth", "square", "pulse", "buzz", "gbuzz", "noise", "pinkish"],
      weight: 0.9,
    },
    {
      technique: "wavetable synthesis",
      domain: "synthesis",
      required: [["tablei", "table", "tablexkt", "oscili"]],
      indicators: ["ftgen", "GEN07", "GEN05", "GEN27", "GEN10", "tableikt"],
      weight: 0.6,
    },
    {
      technique: "granular synthesis",
      domain: "synthesis",
      required: [["grain", "grain3", "granule", "partikkel", "fog", "diskgrain", "syncgrain", "fof", "fof2"]],
      indicators: ["sndwarp", "sndwarpst", "mincer", "temposcal"],
      weight: 1.0,
    },
    {
      technique: "physical modeling",
      domain: "synthesis",
      required: [
        ["wgbow", "wgflute", "wgclar", "wgbrass", "wgpluck", "wgpluck2", "repluck", "pluck"],
        ["streson", "strtod", "barmodel"],
        ["mode"],
      ],
      indicators: ["exciter", "bowedbar"],
      weight: 1.0,
    },
    {
      technique: "spectral processing",
      domain: "synthesis",
      required: [["pvsanal"], ["pvsynth", "pvsosc"]],
      indicators: [
        "pvscross", "pvsfilter", "pvsmorph", "pvsblur", "pvswarp", "pvsshift",
        "pvsmix", "pvsinfo", "pvsbin", "pvslock", "pvsadsyn", "pvsftw",
        "pvsftr", "pvsbufread", "pvsbufwrite", "pvsin", "pvsout",
        "pvscale", "pvshift", "pvsfreeze", "pvstencil", "pvsmaska",
      ],
      weight: 1.0,
    },
    {
      technique: "sample playback",
      domain: "synthesis",
      required: [["diskin", "diskin2", "loscil", "loscil3", "soundin", "flooper", "flooper2"]],
      indicators: ["lpread", "lpreson", "pvoc"],
      weight: 0.8,
    },
    {
      technique: "waveshaping",
      domain: "synthesis",
      required: [["distort", "distort1", "powershape", "chebyshevpoly"]],
      indicators: ["tanh", "GEN03", "GEN13", "GEN14", "GEN15"],
      weight: 0.9,
    },
    {
      technique: "ring modulation",
      domain: "synthesis",
      required: [], // Detected by multiplication pattern in code
      indicators: ["oscili", "poscil", "vco2"],
      weight: 0.5,
    },
    {
      technique: "Karplus-Strong synthesis",
      domain: "synthesis",
      required: [["pluck", "repluck", "wgpluck", "wgpluck2"]],
      indicators: ["delayr", "delayw", "deltap"],
      weight: 1.0,
    },
    {
      technique: "noise synthesis",
      domain: "synthesis",
      required: [["noise", "pinkish", "rand", "randh", "randi", "gauss", "dust", "dust2"]],
      indicators: ["butterlp", "butterhp", "reson", "areson"],
      weight: 0.7,
    },
    {
      technique: "phase distortion synthesis",
      domain: "synthesis",
      required: [["pdhalf", "pdhalfy", "pdclip"]],
      indicators: ["phasor", "tablei"],
      weight: 1.0,
    },
    {
      technique: "vector synthesis",
      domain: "synthesis",
      required: [["vco", "vco2"]],
      indicators: ["crossfade", "xin", "xout"],
      weight: 0.6,
    },

    // --- Effects ---
    {
      technique: "reverb",
      domain: "effects",
      required: [["reverbsc", "reverb", "reverb2", "freeverb", "nreverb", "babo", "hrtfreverb"]],
      indicators: ["denorm", "alpass", "comb"],
      weight: 1.0,
    },
    {
      technique: "delay effects",
      domain: "effects",
      required: [["delayr", "delayw"], ["delay", "delay1", "vdelay", "vdelay3", "multitap"]],
      indicators: ["deltap", "deltap3", "deltapi", "deltapx", "deltapxw"],
      weight: 1.0,
    },
    {
      technique: "chorus/flanger",
      domain: "effects",
      required: [["flanger", "chorus"]],
      indicators: ["vdelay", "vdelay3", "lfo", "oscili"],
      weight: 1.0,
    },
    {
      technique: "phaser",
      domain: "effects",
      required: [["phaser1", "phaser2"]],
      indicators: ["lfo"],
      weight: 1.0,
    },
    {
      technique: "filter design",
      domain: "effects",
      required: [
        [
          "moogladder", "lpf18", "zdf_2pole", "zdf_ladder",
          "butterlp", "butterhp", "butterbp", "butterbs",
          "bqrez", "svfilter", "statevar", "reson", "resonx",
          "areson", "tone", "atone", "tonex", "atonex",
          "mode", "k35_lpf", "k35_hpf", "diode_ladder",
          "clfilt", "pareq", "eqfil",
        ],
      ],
      indicators: ["port", "portk", "lfo"],
      weight: 0.8,
    },
    {
      technique: "distortion/saturation",
      domain: "effects",
      required: [["distort", "distort1", "clip", "wrap", "fold", "tanh", "powershape"]],
      indicators: ["limit", "mirror"],
      weight: 0.9,
    },
    {
      technique: "bitcrushing",
      domain: "effects",
      required: [["bitcrusher", "decimator", "fold"]],
      indicators: ["downsamp"],
      weight: 1.0,
    },
    {
      technique: "dynamics processing",
      domain: "effects",
      required: [["compress", "compress2", "dam"]],
      indicators: ["rms", "follow", "follow2", "balance", "balance2"],
      weight: 1.0,
    },
    {
      technique: "spatialization",
      domain: "effects",
      required: [["pan2", "vbap4", "vbap8", "hrtfstat", "hrtfmove", "hrtfmove2", "bformenc1", "bformdec1"]],
      indicators: ["pan", "vbap", "vbaplsinit"],
      weight: 1.0,
    },
    {
      technique: "convolution",
      domain: "effects",
      required: [["pconvolve", "convolve", "ftconv", "dconv"]],
      indicators: [],
      weight: 1.0,
    },
    {
      technique: "pitch shifting",
      domain: "effects",
      required: [["pvshift", "pvscale", "mincer", "temposcal"]],
      indicators: ["pvsanal", "pvsynth"],
      weight: 1.0,
    },

    // --- Modulation ---
    {
      technique: "envelope shaping",
      domain: "modulation",
      required: [["linen", "linenr", "adsr", "madsr", "mxadsr", "envlpx", "linseg", "expseg", "transeg", "cosseg"]],
      indicators: ["expon", "line", "loopseg", "looptseg"],
      weight: 0.7,
    },
    {
      technique: "LFO modulation",
      domain: "modulation",
      required: [["lfo"]],
      indicators: ["oscili", "phasor", "jspline", "rspline", "randh", "randi", "jitter", "jitter2"],
      weight: 0.8,
    },
    {
      technique: "MIDI control",
      domain: "modulation",
      required: [["cpsmidi", "ampmidi", "notnum", "veloc", "ctrl7", "ctrl14", "midiin", "massign"]],
      indicators: ["ctrl21", "pchbend", "aftouch", "midic7", "midic14"],
      weight: 1.0,
    },
    {
      technique: "algorithmic composition",
      domain: "modulation",
      required: [["schedkwhen", "schedule", "event", "event_i"]],
      indicators: ["metro", "trigger", "changed", "changed2", "turnoff", "turnoff2"],
      weight: 0.8,
    },
    {
      technique: "random/stochastic control",
      domain: "modulation",
      required: [["jspline", "rspline", "jitter", "jitter2", "randh", "randi", "gauss", "cauchy", "betarand"]],
      indicators: ["random", "rnd31", "seed"],
      weight: 0.8,
    },
  ]

  /**
   * Classify a CSD file's techniques from its list of opcodes.
   */
  export function classify(opcodes: string[]): ClassificationResult {
    const opcodeLower = new Set(opcodes.map((o) => o.toLowerCase()))
    const matches: TechniqueMatch[] = []

    for (const pattern of PATTERNS) {
      let matched = false
      const matchedOpcodes: string[] = []

      // Check required groups (OR logic between groups)
      if (pattern.required.length === 0) {
        // No required opcodes — pattern is indicator-only, skip unless indicators match
        continue
      }

      for (const group of pattern.required) {
        const groupMatches = group.filter((op) => opcodeLower.has(op))
        if (groupMatches.length > 0) {
          matched = true
          matchedOpcodes.push(...groupMatches)
        }
      }

      if (!matched) continue

      // Count indicator matches for confidence boost
      const indicatorMatches = pattern.indicators.filter((op) => opcodeLower.has(op))
      matchedOpcodes.push(...indicatorMatches)

      // Calculate confidence from required + indicator matches
      const totalPossible = pattern.required.flat().length + pattern.indicators.length
      const totalMatched = matchedOpcodes.length
      const confidence = Math.min(1.0, (totalMatched / Math.max(totalPossible, 1)) * pattern.weight * 2)

      matches.push({
        technique: pattern.technique,
        confidence: Math.round(confidence * 100) / 100,
        domain: pattern.domain,
        matchedOpcodes: [...new Set(matchedOpcodes)],
      })
    }

    // Sort by confidence descending
    matches.sort((a, b) => b.confidence - a.confidence)

    // Determine primary technique
    const primaryTechnique = matches.length > 0 ? matches[0].technique : "general"

    // Determine primary domain from highest-confidence match
    const domain: Domain = matches.length > 0 ? matches[0].domain : "general"

    // Assess complexity
    const complexity = scoreComplexity(opcodes, matches)

    return { techniques: matches, primaryTechnique, domain, complexity }
  }

  /**
   * Score complexity based on opcode diversity, technique count, and advanced features.
   */
  function scoreComplexity(
    opcodes: string[],
    techniques: TechniqueMatch[],
  ): "basic" | "intermediate" | "advanced" {
    const uniqueOpcodes = new Set(opcodes.map((o) => o.toLowerCase()))
    let score = 0

    // Opcode count contributes
    if (uniqueOpcodes.size > 20) score += 2
    else if (uniqueOpcodes.size > 10) score += 1

    // Multiple techniques
    if (techniques.length > 3) score += 2
    else if (techniques.length > 1) score += 1

    // Advanced features
    const advancedOpcodes = [
      "pvsanal", "pvsynth", "partikkel", "hrtfmove2", "bformenc1",
      "oscbnk", "schedkwhen", "compressh", "pconvolve",
    ]
    if (advancedOpcodes.some((op) => uniqueOpcodes.has(op))) score += 2

    // UDO usage (opcode/instr pattern in code won't be visible here,
    // but presence of xin/xout indicates UDOs)
    if (uniqueOpcodes.has("xin") || uniqueOpcodes.has("xout")) score += 1

    if (score >= 4) return "advanced"
    if (score >= 2) return "intermediate"
    return "basic"
  }

  /**
   * Get all known technique names for reference.
   */
  export function allTechniqueNames(): string[] {
    return PATTERNS.map((p) => p.technique)
  }

  /**
   * Get the domain for a technique name.
   */
  export function domainForTechnique(technique: string): Domain {
    const pattern = PATTERNS.find((p) => p.technique === technique)
    return pattern?.domain ?? "general"
  }
}
