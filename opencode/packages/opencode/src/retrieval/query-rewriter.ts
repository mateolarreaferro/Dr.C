import { CsdParser } from "../csound/parser"
import { Log } from "../util/log"

const log = Log.create({ service: "retrieval.query-rewriter" })

export namespace QueryRewriter {
  export type Domain = "synthesis" | "effects" | "modulation" | "debugging" | "general"

  export interface RewrittenQuery {
    query: string
    domain: Domain
    rawQuery: string
  }

  // Reuse opcode/technique patterns from knowledge.ts for domain classification
  const SYNTHESIS_KEYWORDS =
    /\b(oscil[i3]?|poscil|vco2|foscili?|buzz|gbuzz|grain3?|partikkel|fog|fof2?|wgpluck2?|wgbow|wgflute|wgclar|repluck|pluck|noise|pinker?|loscil[3]?|diskin2?|soundin|additive|subtractive|waveguide|granular|wavetable|FM|frequency modulation|physical model|sample|oscillator|waveshaping|karplus|ring modulation|amplitude modulation|harmonics?|partials?|spectrum|timbre|tone|bright|warm|dark|rich|thin|fat|thick|harsh|smooth|mellow|metallic)\b/gi

  const EFFECTS_KEYWORDS =
    /\b(reverbsc|reverb2?|freeverb|nreverb|delay[rw]?|deltap[i3]?|flanger|chorus|phaser[12]|distort|tanh|powershape|clip|wrap|fold|bitcrusher|decimator|compress2?|dam|follow2?|rms|balance2?|pan2?|vbap[48]?|hrtfstat|hrtfmove2?|pvs\w+|reverb|delay|filter|distortion|EQ|dynamics|spatial|wet|dry|mix|send|return|room|hall|plate|spring|tape|echo|feedback|diffusion|damping|resonance|cutoff|bandwidth)\b/gi

  const MODULATION_KEYWORDS =
    /\b(linen|adsr|madsr|mxadsr|expon|line|envlpx|linseg|expseg|transeg|cosseg|loopseg|jspline|rspline|port|portk|tonek|atonek|lfo|phasor|metro|trigger|changed2?|schedkwhen|schedule|event|envelope|LFO|control|modulation|automation|MIDI|OSC|mapping|sweep|ramp|attack|decay|sustain|release|tempo|rhythm|sequence|pattern|gate|trigger)\b/gi

  const DEBUGGING_KEYWORDS =
    /\b(error|bug|crash|fail|broken|wrong|silent|no sound|doesn't work|won't compile|fix|debug|issue|problem|help|perf|performance|warning|glitch|click|pop|artifact|distort(?:ed|ion)?|clip(?:ping)?)\b/gi

  const TECHNIQUE_PATTERN =
    /\b(FM synthesis|frequency modulation|subtractive|additive|waveguide|granular|wavetable|spectral|phase vocoder|formant|FOF|physical model|sample-based|ring modulation|amplitude modulation|waveshaping|karplus.strong|convolution|morphing|cross.synthesis|vocoder|pitch shifting|time stretching)\b/gi

  function classifyDomain(text: string): Domain {
    const scores: Record<Domain, number> = {
      synthesis: 0,
      effects: 0,
      modulation: 0,
      debugging: 0,
      general: 0,
    }

    scores.synthesis = (text.match(SYNTHESIS_KEYWORDS) ?? []).length
    scores.effects = (text.match(EFFECTS_KEYWORDS) ?? []).length
    scores.modulation = (text.match(MODULATION_KEYWORDS) ?? []).length
    scores.debugging = (text.match(DEBUGGING_KEYWORDS) ?? []).length

    const max = Math.max(scores.synthesis, scores.effects, scores.modulation, scores.debugging)
    if (max === 0) return "general"

    if (scores.debugging === max) return "debugging"
    if (scores.synthesis === max) return "synthesis"
    if (scores.effects === max) return "effects"
    if (scores.modulation === max) return "modulation"
    return "general"
  }

  function extractOpcodesFromCsd(csdContent: string): string[] {
    const OPCODE_PATTERN =
      /\b(oscili?|poscil|vco2|moogladder|lpf18|zdf_2pole|zdf_ladder|butterlp|butterhp|butterbp|butterbs|reverbsc|reverb2?|freeverb|nreverb|delay|delayr|delayw|deltap[i3]?|flanger|chorus|phaser[12]|distort|tanh|powershape|clip|wrap|fold|loscil[3]?|diskin2?|soundin|foscili?|buzz|gbuzz|grain3?|partikkel|fog|fof2?|wgpluck2?|wgbow|wgflute|wgclar|repluck|pluck|noise|pinker?|rand[hi]?|jitter2?|randi?|linen|adsr|madsr|mxadsr|expon|line|envlpx|linseg|expseg|transeg|cosseg|loopseg|jspline|rspline|port|portk|tonek|atonek|tonex|atone|reson|resonx?|areson|bqrez|svfilter|statevar|mode|compress2?|dam|follow2?|rms|balance2?|pan2|pan|vbap[48]?|hrtfstat|hrtfmove2?|pvs\w+|lfo|phasor|metro|trigger|schedule|schedkwhen|ftgen|chnget|chnset)\b/gi

    const matches = csdContent.match(OPCODE_PATTERN) ?? []
    return [...new Set(matches.map((m) => m.toLowerCase()))]
  }

  function extractTechniqueKeywords(text: string): string[] {
    const matches = text.match(TECHNIQUE_PATTERN) ?? []
    return [...new Set(matches.map((m) => m.toLowerCase()))]
  }

  function extractTextFromMessages(
    messages: Array<{ info: { role: string }; parts: Array<{ type: string; text?: string; synthetic?: boolean }> }>,
    role: string,
    count: number,
  ): string[] {
    const texts: string[] = []
    for (let i = messages.length - 1; i >= 0 && texts.length < count; i--) {
      const msg = messages[i]
      if (msg.info.role !== role) continue
      for (const part of msg.parts) {
        if (part.type === "text" && !part.synthetic && part.text?.trim()) {
          texts.push(part.text.trim())
          break
        }
      }
    }
    return texts
  }

  /**
   * Rewrite a raw user query with context from recent messages and active CSD.
   * Returns an expanded query + domain classification for biased retrieval.
   * Accepts optional pre-read CSD content to avoid redundant disk reads.
   */
  export async function rewrite(
    messages: Array<{ info: { role: string }; parts: Array<{ type: string; text?: string; synthetic?: boolean }> }>,
    activeCsdPath?: string,
    csdContent?: string,
  ): Promise<RewrittenQuery | null> {
    // Get last 3 user messages for context
    const userTexts = extractTextFromMessages(messages, "user", 3)
    if (userTexts.length === 0) return null

    const rawQuery = userTexts[0]

    // Get technique keywords from recent assistant messages
    const assistantTexts = extractTextFromMessages(messages, "assistant", 2)
    const assistantContext = assistantTexts.join(" ")
    const techniqueKeywords = extractTechniqueKeywords(assistantContext)

    // Extract opcodes from active CSD if available
    let csdOpcodes: string[] = []
    if (csdContent) {
      csdOpcodes = extractOpcodesFromCsd(csdContent)
    } else if (activeCsdPath) {
      try {
        const content = await Bun.file(activeCsdPath).text()
        csdOpcodes = extractOpcodesFromCsd(content)
      } catch {
        // CSD file may not exist yet
      }
    }

    // Build expanded query — CSD content is ground truth, message history is secondary.
    // After a design tree restore, messages still describe the old version,
    // so current CSD opcodes must dominate.
    const contextParts: string[] = [rawQuery]

    // CSD opcodes first — this IS the current state
    if (csdOpcodes.length > 0) {
      contextParts.push(csdOpcodes.slice(0, 15).join(" "))
    }

    // Technique keywords from assistant (secondary, may be stale after restore)
    if (techniqueKeywords.length > 0 && csdOpcodes.length === 0) {
      // Only use assistant context when there's no CSD to ground us
      contextParts.push(techniqueKeywords.join(" "))
    }

    // Prior user messages for multi-turn context (abbreviated, lowest priority)
    if (userTexts.length > 1) {
      const priorContext = userTexts
        .slice(1, 2) // only 1 prior message, not 2
        .map((t) => (t.length > 60 ? t.slice(0, 57) + "..." : t))
      contextParts.push(...priorContext)
    }

    const expandedQuery = contextParts.join(" ")

    // Classify domain — CSD opcodes are the strongest signal
    const allContext = csdOpcodes.length > 0
      ? [rawQuery, ...csdOpcodes].join(" ")
      : [rawQuery, ...assistantTexts].join(" ")
    const domain = classifyDomain(allContext)

    log.info("query rewritten", {
      raw: rawQuery.slice(0, 60),
      domain,
      opcodes: csdOpcodes.length,
      techniques: techniqueKeywords.length,
      expandedLength: expandedQuery.length,
    })

    return {
      query: expandedQuery,
      domain,
      rawQuery,
    }
  }
}
