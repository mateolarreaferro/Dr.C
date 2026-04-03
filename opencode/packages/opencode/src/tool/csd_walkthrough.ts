import z from "zod"
import { Tool } from "./tool"
import { SessionWorkspace } from "../session/workspace"
import { CsdParser } from "../csound/parser"
import { FLOSS_LINKS } from "../educational/floss-links"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.csd-walkthrough" })

const DESCRIPTION = `Generate a line-by-line educational walkthrough of a CSD file, explaining what each meaningful line does, why it matters, and linking to relevant FLOSS manual pages.

Use this tool when the user asks for an explanation of their CSD code, wants to understand how a Csound file works, or is learning from an example. You can explain the full file or a specific line range.

The walkthrough parses the CSD structure and provides context-aware explanations including instrument boundaries, global settings, opcode purposes, and signal flow.`

export const CsdWalkthroughTool = Tool.define(
  "csd_walkthrough",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file to explain"),
      lineRange: z
        .string()
        .optional()
        .describe(
          'Optional line range to explain (e.g., "10-25"). If omitted, explains the entire file.',
        ),
    }),
    async execute(params, ctx) {
      const filePath = SessionWorkspace.resolve(ctx.sessionID, params.filePath)

      const file = Bun.file(filePath)
      if (!(await file.exists())) {
        throw new Error(`File not found: ${filePath}`)
      }

      if (!filePath.endsWith(".csd")) {
        throw new Error(`Expected a .csd file, got: ${filePath}`)
      }

      const content = await file.text()
      const lines = content.split("\n")

      log.info("generating CSD walkthrough", {
        filePath,
        lineRange: params.lineRange,
        totalLines: lines.length,
      })

      // Parse the CSD structure for context
      let structure: CsdParser.CsdStructure | null = null
      try {
        structure = CsdParser.parse(content)
      } catch {
        // Continue without structure — we can still explain line by line
      }

      // Determine line range
      let startLine = 1
      let endLine = lines.length
      if (params.lineRange) {
        const rangeMatch = params.lineRange.match(/^(\d+)\s*-\s*(\d+)$/)
        if (rangeMatch) {
          startLine = Math.max(1, parseInt(rangeMatch[1]))
          endLine = Math.min(lines.length, parseInt(rangeMatch[2]))
        } else {
          const singleLine = parseInt(params.lineRange)
          if (!isNaN(singleLine)) {
            startLine = Math.max(1, singleLine)
            endLine = startLine
          }
        }
      }

      // Build section context map (which section each line belongs to)
      const sectionMap = new Map<number, string>()
      if (structure) {
        for (const section of structure.sections) {
          for (let i = section.startLine; i <= section.endLine; i++) {
            sectionMap.set(i, section.name)
          }
        }
      }

      // Build instrument context map
      const instrMap = new Map<number, string>()
      if (structure) {
        for (const instr of structure.instruments) {
          for (let i = instr.startLine; i <= instr.endLine; i++) {
            instrMap.set(i, instr.id)
          }
        }
      }

      // Generate walkthrough
      const parts: string[] = []
      parts.push(`## CSD Walkthrough: ${filePath.split("/").pop()}`)

      if (params.lineRange) {
        parts.push(`Lines ${startLine}-${endLine}`)
      }
      parts.push("")

      // Add structure overview
      if (structure && !params.lineRange) {
        parts.push(`### Structure Overview`)
        if (structure.globals.sr) parts.push(`- Sample rate: ${structure.globals.sr} Hz`)
        if (structure.globals.ksmps) parts.push(`- ksmps: ${structure.globals.ksmps} (control rate = ${structure.globals.sr ? Math.round(structure.globals.sr / structure.globals.ksmps) : "?"} Hz)`)
        if (structure.globals.nchnls) parts.push(`- Channels: ${structure.globals.nchnls}`)
        if (structure.globals["0dbfs"]) parts.push(`- 0dBFS: ${structure.globals["0dbfs"]}`)
        if (structure.instruments.length > 0) {
          parts.push(`- Instruments: ${structure.instruments.map((i) => i.id).join(", ")}`)
        }
        if (structure.parameters.length > 0) {
          parts.push(`- Parameters: ${structure.parameters.length} detected`)
        }
        parts.push("")
      }

      parts.push(`### Line-by-Line`)
      parts.push("")

      let currentSection = ""
      let currentInstr = ""

      for (let lineNum = startLine; lineNum <= endLine; lineNum++) {
        const line = lines[lineNum - 1]
        const trimmed = line.trim()

        // Skip blank lines
        if (!trimmed) continue

        // Track section changes
        const section = sectionMap.get(lineNum) ?? ""
        if (section !== currentSection) {
          currentSection = section
          if (section) {
            parts.push(`--- *Entering <${section}> section* ---`)
            parts.push("")
          }
        }

        // Track instrument changes
        const instr = instrMap.get(lineNum) ?? ""
        if (instr !== currentInstr) {
          currentInstr = instr
        }

        // Generate explanation for this line
        const explanation = explainLine(trimmed, lineNum, currentSection, currentInstr, structure)
        if (explanation) {
          parts.push(`**Line ${lineNum}:** \`${trimmed}\``)
          parts.push(`  ${explanation.what}`)
          if (explanation.why) {
            parts.push(`  *Why:* ${explanation.why}`)
          }
          if (explanation.flossLink) {
            parts.push(`  FLOSS: ${explanation.flossLink}`)
          }
          parts.push("")
        }
      }

      return {
        title: `Walkthrough: ${filePath.split("/").pop()}`,
        output: parts.join("\n"),
        metadata: {
          filePath,
          lineRange: params.lineRange,
          linesExplained: endLine - startLine + 1,
          sections: structure?.sections.map((s) => s.name) ?? [],
        },
      }
    },
  },
)

interface LineExplanation {
  what: string
  why?: string
  flossLink?: string
}

function explainLine(
  line: string,
  lineNum: number,
  section: string,
  instrId: string,
  structure: CsdParser.CsdStructure | null,
): LineExplanation | null {
  // XML tags
  if (line.match(/^<\/?Csound/i)) {
    return { what: "CSD file boundary tag.", why: "Marks the beginning/end of a Csound Structured Data file." }
  }
  if (line.match(/^<CsOptions>/i)) {
    return { what: "Opens the options section.", why: "Command-line flags for Csound runtime behavior go here." }
  }
  if (line.match(/^<\/CsOptions>/i)) {
    return { what: "Closes the options section." }
  }
  if (line.match(/^<CsInstruments>/i)) {
    return { what: "Opens the orchestra (instruments) section.", why: "All instrument definitions, global settings, and UDOs are defined here." }
  }
  if (line.match(/^<\/CsInstruments>/i)) {
    return { what: "Closes the orchestra section." }
  }
  if (line.match(/^<CsScore>/i)) {
    return { what: "Opens the score section.", why: "Score events trigger instruments with timing, duration, and parameter values." }
  }
  if (line.match(/^<\/CsScore>/i)) {
    return { what: "Closes the score section." }
  }

  // Comments
  if (line.startsWith(";")) {
    return { what: `Comment: ${line.slice(1).trim()}` }
  }

  // Options
  if (section === "CsOptions") {
    if (line.includes("-o dac")) return { what: "Output to the system audio device (real-time playback)." }
    if (line.includes("-o")) return { what: `Sets the output destination.` }
    if (line.includes("-d")) return { what: "Suppress display output." }
    if (line.includes("-m")) return { what: "Sets the message verbosity level." }
    if (line.includes("-W")) return { what: "Write output as WAV format." }
    return { what: `Csound command-line option: ${line}` }
  }

  // Global settings
  const srMatch = line.match(/^sr\s*=\s*(\d+)/)
  if (srMatch) {
    return {
      what: `Sets the sample rate to ${srMatch[1]} Hz.`,
      why: "The sample rate determines the highest frequency that can be represented (Nyquist = sr/2). 44100 is CD quality.",
    }
  }

  const ksmpsMatch = line.match(/^ksmps\s*=\s*(\d+)/)
  if (ksmpsMatch) {
    const ksmps = parseInt(ksmpsMatch[1])
    return {
      what: `Sets ksmps (samples per control period) to ${ksmps}.`,
      why: `Control-rate signals update every ${ksmps} samples. Lower ksmps = more precise control but higher CPU cost.`,
    }
  }

  const nchnlsMatch = line.match(/^nchnls\s*=\s*(\d+)/)
  if (nchnlsMatch) {
    return {
      what: `Sets output to ${nchnlsMatch[1]} channel${nchnlsMatch[1] === "1" ? "" : "s"}.`,
      why: nchnlsMatch[1] === "2" ? "Stereo output — the standard for most audio work." : undefined,
    }
  }

  const dbfsMatch = line.match(/^0dbfs\s*=\s*([\d.]+)/)
  if (dbfsMatch) {
    return {
      what: `Sets 0dBFS (full-scale amplitude) to ${dbfsMatch[1]}.`,
      why: "With 0dbfs=1, amplitude values range from 0 to 1. This is the modern Csound convention — older code uses 0dbfs=32768.",
    }
  }

  // Seed
  if (line.match(/^seed\s+/)) {
    return {
      what: "Seeds the random number generator.",
      why: "seed 0 uses the system time for different results each run. A fixed seed gives reproducible randomness.",
    }
  }

  // Instrument definition
  const instrMatch = line.match(/^instr\s+(.+)/)
  if (instrMatch) {
    return {
      what: `Begins instrument definition: ${instrMatch[1]}.`,
      why: "Instruments are the building blocks of Csound. Each instrument processes audio from its start time for its duration.",
    }
  }

  if (line === "endin") {
    return {
      what: `Ends instrument ${instrId || "definition"}.`,
    }
  }

  // ftgen / function tables
  const ftgenMatch = line.match(/ftgen\s+/)
  if (ftgenMatch) {
    const genMatch = line.match(/,\s*(\d+)\s*,/)
    const gen = genMatch ? genMatch[1] : undefined
    let why: string | undefined
    if (line.includes("GEN10") || line.match(/,\s*10\s*,/)) {
      why = "GEN10 creates a waveform from a harmonic series. The values are the relative strengths of harmonics 1, 2, 3, etc."
    } else if (line.includes("GEN20") || line.match(/,\s*20\s*,/)) {
      why = "GEN20 creates window functions (Hanning, Hamming, etc.) — commonly used as grain envelopes in granular synthesis."
    }
    return {
      what: "Creates a function table (wavetable) in memory.",
      why,
      flossLink: FLOSS_LINKS["ftgen"],
    }
  }

  // Opcode detection — find the main opcode on the line
  const opcodeInfo = detectOpcode(line)
  if (opcodeInfo) {
    return {
      what: opcodeInfo.explanation,
      why: opcodeInfo.why,
      flossLink: FLOSS_LINKS[opcodeInfo.opcode],
    }
  }

  // Variable assignments
  const assignMatch = line.match(/^([ikaS]\w+)\s*=\s*(.+)/)
  if (assignMatch) {
    const varName = assignMatch[1]
    const rate = varName[0] === "k" ? "control-rate" : varName[0] === "a" ? "audio-rate" : varName[0] === "i" ? "init-time" : "string"
    return {
      what: `Assigns ${rate} variable \`${varName}\`.`,
    }
  }

  // Score events
  if (section === "CsScore") {
    const scoreMatch = line.match(/^([ifeatbsvrmnq])\s+(.+)/)
    if (scoreMatch) {
      const type = scoreMatch[1]
      if (type === "i") {
        const fields = scoreMatch[2].split(/\s+/)
        const instrNum = fields[0]
        const start = fields[1]
        const dur = fields[2]
        return {
          what: `Triggers instrument ${instrNum} at time ${start}s for ${dur}s${fields.length > 3 ? ` with p-fields: ${fields.slice(3).join(", ")}` : ""}.`,
          why: "Score i-statements are the primary way to schedule instrument events. p4, p5, etc. pass values to the instrument.",
        }
      }
      if (type === "f") {
        return {
          what: `Function table definition in score.`,
          why: line.includes("f 0") ? "f 0 with a long duration keeps the Csound engine running (useful for real-time or MIDI)." : undefined,
        }
      }
      if (type === "e") {
        return { what: "End-of-score marker." }
      }
    }
  }

  // #define macros
  const defineMatch = line.match(/^#define\s+(\w+)\s+#([^#]*)#/)
  if (defineMatch) {
    return {
      what: `Defines macro \`${defineMatch[1]}\` with value \`${defineMatch[2].trim()}\`.`,
      why: "Macros allow reusable constants and code fragments. Reference with $NAME.",
    }
  }

  // Catch-all for non-empty lines
  return { what: `${line}` }
}

interface OpcodeInfo {
  opcode: string
  explanation: string
  why?: string
}

function detectOpcode(line: string): OpcodeInfo | null {
  // Pattern: [output] opcode [inputs]
  // Match: varName opcode args  OR  opcode args
  const opcodeMatch = line.match(/(?:\w+\s+)?(\w+)\s+(?:[\w"$].*)/) ||
    line.match(/^\s*(\w+)\s+/)

  if (!opcodeMatch) return null
  const candidate = opcodeMatch[1].toLowerCase()

  const opcodeExplanations: Record<string, { explanation: string; why?: string }> = {
    oscil: { explanation: "Table-lookup oscillator (linear interpolation).", why: "The fundamental building block of digital synthesis — reads values from a stored waveform at the specified frequency." },
    oscili: { explanation: "Table-lookup oscillator with linear interpolation.", why: "Like oscil but with interpolation for smoother output, especially at low frequencies." },
    poscil: { explanation: "High-precision oscillator with cubic interpolation.", why: "Better quality than oscili for precise frequency work. Uses a 64-bit phase accumulator." },
    vco2: { explanation: "Band-limited oscillator (saw, pulse, triangle, square).", why: "Unlike raw waveforms, vco2 avoids aliasing artifacts. Essential for subtractive synthesis." },
    noise: { explanation: "White noise generator.", why: "Produces random samples at audio rate — the starting point for subtractive synthesis and special effects." },
    foscil: { explanation: "FM oscillator (carrier + modulator pair).", why: "A single opcode that implements basic 2-operator FM synthesis, controlled by carrier ratio, modulator ratio, and index." },
    foscili: { explanation: "FM oscillator with interpolation.", why: "Same as foscil but with linear interpolation for cleaner output." },
    fmbell: { explanation: "FM bell preset using Chowning/Bristow algorithm." },
    moogladder: { explanation: "Moog ladder filter emulation (24dB/oct low-pass).", why: "Digital model of the classic Moog transistor ladder filter — warm, musical resonance character." },
    moogvcf: { explanation: "Moog voltage-controlled filter emulation." },
    lpf18: { explanation: "3-pole low-pass filter with resonance and distortion.", why: "Based on the TB-303 filter topology — great for acid bass sounds." },
    butterlp: { explanation: "Butterworth low-pass filter.", why: "Maximally flat magnitude response — no ripple in the passband." },
    butterhp: { explanation: "Butterworth high-pass filter." },
    statevar: { explanation: "State-variable filter (simultaneous LP, HP, BP, BR outputs).", why: "One filter, four outputs — useful when you need multiple filter types from one source." },
    linseg: { explanation: "Linear segment envelope generator.", why: "Creates piecewise-linear shapes over time — the workhorse envelope for shaping amplitude, frequency, and filter parameters." },
    linsegr: { explanation: "Linear segment envelope with release.", why: "Like linseg but adds a release segment when the note ends, preventing clicks." },
    expseg: { explanation: "Exponential segment envelope.", why: "More natural-sounding for amplitude and frequency changes because human perception is logarithmic." },
    expsegr: { explanation: "Exponential segment envelope with release." },
    expon: { explanation: "Exponential curve from start to end value." },
    madsr: { explanation: "MIDI-aware ADSR envelope.", why: "Standard Attack-Decay-Sustain-Release envelope. Sustain level holds until note-off, then release begins." },
    adsr: { explanation: "ADSR envelope generator." },
    transeg: { explanation: "Transeg envelope with curved segments.", why: "Each segment can have a different curvature — more expressive than linear envelopes." },
    reverbsc: { explanation: "Stereo reverb (Sean Costello algorithm).", why: "High-quality feedback delay network reverb with natural decay characteristics." },
    freeverb: { explanation: "Freeverb stereo reverb.", why: "Based on Jezar's public domain Freeverb — efficient and musical." },
    delay: { explanation: "Simple audio delay." },
    vdelay3: { explanation: "Variable delay with cubic interpolation.", why: "Useful for chorus, flanger, and pitch-shifting effects where delay time varies." },
    pan2: { explanation: "Stereo panning.", why: "Distributes a mono signal between left and right channels using equal-power panning." },
    outs: { explanation: "Outputs stereo audio signal.", why: "Sends audio to the stereo output bus — the final step in the signal chain." },
    outch: { explanation: "Output to specific channel number(s)." },
    chnget: { explanation: "Reads a value from a named channel.", why: "Used for real-time parameter control via GUI widgets, OSC, or MIDI mapping." },
    chnset: { explanation: "Writes a value to a named channel." },
    pvsanal: { explanation: "Spectral analysis via phase vocoder (FFT).", why: "Converts audio into frequency-domain representation for spectral processing." },
    pvsynth: { explanation: "Spectral resynthesis (inverse FFT).", why: "Converts frequency-domain data back to audio after spectral manipulation." },
    pvsfreeze: { explanation: "Freezes spectral amplitudes and/or frequencies.", why: "Captures and holds the spectral snapshot — creates sustained, frozen textures." },
    partikkel: { explanation: "Advanced granular synthesis engine.", why: "Highly flexible grain generator supporting multiple sources, FM of grains, and trainlet synthesis." },
    grain: { explanation: "Basic granular synthesis opcode." },
    grain3: { explanation: "Granular synthesis with more control parameters." },
    pluck: { explanation: "Karplus-Strong plucked string synthesis.", why: "Elegantly simple physical model: a short delay line with filtering produces convincing plucked strings." },
    wgbow: { explanation: "Waveguide bowed string model.", why: "Physical model based on Julius O. Smith's waveguide synthesis — simulates the physics of a bowed string." },
    wgflute: { explanation: "Waveguide flute model." },
    wgclar: { explanation: "Waveguide clarinet model." },
    wgbrass: { explanation: "Waveguide brass model." },
    repluck: { explanation: "Enhanced Karplus-Strong plucked string." },
    diskin: { explanation: "Reads audio from a sound file on disk." },
    diskin2: { explanation: "Reads audio from disk with resampling." },
    loscil: { explanation: "Looping oscillator for sample playback." },
    metro: { explanation: "Metronome trigger generator.", why: "Outputs a 1-sample trigger at a specified rate — fundamental for algorithmic rhythmic patterns." },
    schedkwhen: { explanation: "Schedule instrument events on k-rate trigger.", why: "Triggers instrument events from within another instrument — the basis of algorithmic composition in Csound." },
    event: { explanation: "Generate a score event at performance time." },
    lfo: { explanation: "Low-frequency oscillator.", why: "Generates slow periodic modulation signals for vibrato, tremolo, filter sweeps, and other cyclic effects." },
    jitter: { explanation: "Random jitter signal generator.", why: "Produces smooth random control signals — useful for adding organic variation to parameters." },
    port: { explanation: "Portamento (glide) on a control signal.", why: "Smooths abrupt value changes — essential for preventing zipper noise on control parameters." },
    portk: { explanation: "Portamento with k-rate control of glide time." },
    compress2: { explanation: "Dynamic range compressor." },
    distort1: { explanation: "Waveshaping distortion." },
    clip: { explanation: "Hard/soft clipping distortion." },
    powershape: { explanation: "Waveshaping with adjustable transfer function." },
    buzz: { explanation: "Band-limited additive synthesis (N equal-amplitude harmonics).", why: "Generates a pulse-like waveform by summing harmonics — the starting point for many subtractive patches." },
    gbuzz: { explanation: "Band-limited additive synthesis with controllable harmonic range." },
    init: { explanation: "Initializes a variable to a specific value." },
    comb: { explanation: "Comb filter.", why: "A delay with feedback creates a series of equally-spaced resonant peaks — the basis of flanging and Karplus-Strong." },
    reson: { explanation: "Second-order resonant bandpass filter." },
    table: { explanation: "Table lookup (no interpolation)." },
    tablei: { explanation: "Table lookup with linear interpolation." },
  }

  if (opcodeExplanations[candidate]) {
    return {
      opcode: candidate,
      ...opcodeExplanations[candidate],
    }
  }

  return null
}
