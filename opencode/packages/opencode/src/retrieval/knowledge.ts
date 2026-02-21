import fs from "fs/promises"
import path from "path"
import { KnowledgeSources } from "./knowledge-sources"
import { Log } from "../util/log"

export namespace CsoundKnowledge {
  const log = Log.create({ service: "retrieval.knowledge" })

  export interface Chunk {
    id: string
    source: string
    section: string
    subsection: string
    content: string
    tokens: number
    tags: string[]
  }

  // Known Csound opcodes for tag extraction
  const OPCODE_PATTERN =
    /\b(oscili?|poscil|vco2|moogladder|lpf18|zdf_2pole|zdf_ladder|butterlp|butterhp|butterbp|butterbs|reverbsc|reverb2?|freeverb|nreverb|delay|delayr|delayw|deltap[i3]?|flanger|chorus|phaser[12]|distort|tanh|powershape|clip|wrap|fold|bitcrusher|decimator|loscil[3]?|diskin2?|soundin|foscili?|buzz|gbuzz|grain3?|partikkel|fog|fof2?|wgpluck2?|wgbow|wgflute|wgclar|repluck|pluck|noise|pinker?|rand[hi]?|jitter2?|randi?|linen|adsr|madsr|mxadsr|expon|line|envlpx|linseg|expseg|transeg|cosseg|loopseg|jspline|rspline|port|portk|tonek|atonek|tonex|atone|reson|resonx?|areson|bqrez|svfilter|statevar|mode|compress2?|dam|follow2?|rms|balance2?|pan2|pan|vbap[48]?|hrtfstat|hrtfmove2?|pvs(?:anal|synth|cross|filter|morph|blur|warp|shift|mix|info|bin|lock|adsyn|ftw|ftr|bufread|bufwrite|in|out)|pvadd|table[iw3]?|tablexkt|ftgen|oscbnk|GEN\d{1,2}|chnget|chnset|chn_[kaSi]|inch|outch|outs|out|ins|in|phasor|tablei|ftlen|cpsmidi|ampmidi|notnum|veloc|ctrl7|ctrl14|ctrl21|massign|midi[ck]hn|cpsoct|octcps|cpspch|pchcps|ampdb|dbamp|ampdbfs|dbfsamp|semitone|cent|turnoff2?|schedkwhen|schedule|event|trigger|changed2?|metro|lfo|oscilikt|pdhalf|pdhalfy|distort1|powoftwo|log2|limit|mirror|round|int|frac|abs|sqrt|exp|log|pow|divz|min|max|sum|product|mac|maca)\b/gi

  // Synthesis technique keywords
  const TECHNIQUE_PATTERN =
    /\b(FM synthesis|frequency modulation|subtractive|additive|waveguide|granular|wavetable|spectral|phase vocoder|formant|FOF|physical model|sample-based|ring modulation|amplitude modulation|waveshaping|karplus.strong|convolution|morphing|cross.synthesis|vocoder|pitch shifting|time stretching|reverb(?:eration)?|delay line|chorus|flanger|phaser|filter|envelope|LFO|oscillator|noise|random|chaos|fractal|stochastic)\b/gi

  function estimateTokens(text: string): number {
    // ~4 chars per token for English technical text
    return Math.ceil(text.length / 4)
  }

  function extractTags(text: string): string[] {
    const tags = new Set<string>()
    const opcodeMatches = text.match(OPCODE_PATTERN) ?? []
    for (const m of opcodeMatches) tags.add(m.toLowerCase())
    const techMatches = text.match(TECHNIQUE_PATTERN) ?? []
    for (const m of techMatches) tags.add(m.toLowerCase())
    return [...tags]
  }

  function sanitizeID(text: string): string {
    return text
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
      .slice(0, 60)
  }

  /**
   * Detect chapter/section headers in the Csound Book.
   * Headers are lines like "1.  Introduction to Sound Design in Csound"
   * or all-caps short lines, or lines ending with a page number.
   */
  function isChapterHeader(line: string): string | null {
    // Pattern: "N.  Chapter Title" or "N.N  Section Title"
    const chapterMatch = line.match(/^(\d{1,2}\.(?:\d{1,2})?)\s+(.+)/)
    if (chapterMatch && chapterMatch[2].length > 5) return chapterMatch[2].trim()

    // Lines that are section-like: short, title-cased, no period at end
    if (line.length > 5 && line.length < 100 && !line.endsWith(".") && /^[A-Z][A-Za-z\s:,'\-—()]+$/.test(line)) {
      // Exclude lines that are just names (Author Name pattern)
      if (/^[A-Z][a-z]+ [A-Z][a-z]+$/.test(line)) return null
      // Exclude page numbers and short metadata
      if (/^\d+$/.test(line.trim())) return null
      return line.trim()
    }
    return null
  }

  export async function chunk(sourcePath: string): Promise<Chunk[]> {
    const content = await fs.readFile(sourcePath, "utf-8")
    const lines = content.split("\n")
    const sourceID = path.basename(sourcePath, path.extname(sourcePath))

    const chunks: Chunk[] = []
    let currentSection = "Introduction"
    let currentSubsection = ""
    let buffer: string[] = []
    let chunkIndex = 0

    function flushBuffer() {
      const text = buffer.join("\n").trim()
      if (!text || estimateTokens(text) < 20) {
        buffer = []
        return
      }

      const tags = extractTags(text)
      const id = `${sourceID}-${sanitizeID(currentSection)}-${chunkIndex}`
      chunks.push({
        id,
        source: sourceID,
        section: currentSection,
        subsection: currentSubsection,
        content: text,
        tokens: estimateTokens(text),
        tags,
      })
      chunkIndex++
      buffer = []
    }

    // Skip the front-matter (TOC, copyright, etc.)
    let contentStarted = false
    let blankLineCount = 0

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      const trimmed = line.trim()

      // Skip blank lines at start
      if (!contentStarted) {
        // Look for "Foreword" or "Chapter 1" as content start
        if (/^(Foreword|Introduction to Sound Design|1\.\s+Introduction)/i.test(trimmed)) {
          contentStarted = true
        } else {
          continue
        }
      }

      // Skip page numbers, "Book Contents", and other metadata
      if (/^(Book Contents|CD-ROM Contents)$/i.test(trimmed)) continue
      if (/^[ivxlc]+$/i.test(trimmed)) continue // Roman numerals
      if (/^\d{1,4}$/.test(trimmed) && trimmed.length <= 4) {
        blankLineCount++
        continue // Standalone page numbers
      }

      // Detect headers
      const header = isChapterHeader(trimmed)
      if (header && trimmed.length > 8) {
        flushBuffer()
        // Check if it's a major section or subsection
        if (/^\d+\./.test(trimmed) || header.length > 20) {
          currentSection = header
          currentSubsection = ""
        } else {
          currentSubsection = header
        }
        continue
      }

      // Track blank lines for paragraph detection
      if (!trimmed) {
        blankLineCount++
        if (blankLineCount >= 2 && estimateTokens(buffer.join("\n")) > 200) {
          flushBuffer()
        }
        continue
      }

      blankLineCount = 0
      buffer.push(trimmed)

      // Flush if buffer gets large enough
      if (estimateTokens(buffer.join("\n")) >= 350) {
        flushBuffer()
      }
    }

    // Flush remaining
    flushBuffer()

    log.info("chunked knowledge source", { source: sourcePath, chunks: chunks.length })
    return chunks
  }

  export async function loadOrBuild(source: KnowledgeSources.Source): Promise<Chunk[]> {
    const dataDir = KnowledgeSources.dataDir()
    const cachePath = path.join(dataDir, `chunks-${source.id}.json`)

    try {
      const cached = await fs.readFile(cachePath, "utf-8")
      const chunks = JSON.parse(cached) as Chunk[]
      if (chunks.length > 0) {
        log.info("loaded cached chunks", { source: source.id, count: chunks.length })
        return chunks
      }
    } catch {
      // No cache, build fresh
    }

    // Check if source file exists
    try {
      await fs.access(source.path)
    } catch {
      log.warn("knowledge source not found", { path: source.path })
      return []
    }

    const chunks = await chunk(source.path)

    // Persist
    await fs.mkdir(dataDir, { recursive: true })
    await fs.writeFile(cachePath, JSON.stringify(chunks), "utf-8")
    log.info("built and cached chunks", { source: source.id, count: chunks.length })

    return chunks
  }
}
