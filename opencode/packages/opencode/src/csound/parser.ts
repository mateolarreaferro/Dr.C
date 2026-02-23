import { Log } from "../util/log"

const log = Log.create({ service: "csd-parser" })

export namespace CsdParser {
  // --- Types ---

  export interface CsdParameter {
    /** Parameter name (channel name or variable name) */
    name: string
    /** Rate prefix: k (control), a (audio), i (init), or S (string) */
    rate: "k" | "a" | "i" | "S"
    /** How this parameter is sourced */
    source: "chnget" | "define" | "init" | "pfield"
    /** Default or current value (string representation) */
    value?: string
    /** Line number in the CSD file (1-indexed) */
    line: number
    /** Instrument number or name this belongs to, if any */
    instrument?: string
    /** Whether port/portk smoothing is applied */
    smoothed: boolean
    /** Smoothing time if smoothed */
    smoothTime?: number
    /** Detected range [min, max] from Cabbage widget or comments */
    range?: [number, number]
    /** Channel name for chnget-sourced params */
    channel?: string
    /** Whether this parameter is locked (should not be modified by the agent) */
    locked?: boolean
  }

  export interface CsdInstrument {
    /** Instrument number or name */
    id: string
    /** Start line (1-indexed) */
    startLine: number
    /** End line (1-indexed) */
    endLine: number
    /** Parameters belonging to this instrument */
    parameters: CsdParameter[]
    /** Comment/description if found on the same line or above */
    description?: string
  }

  export interface CsdGlobals {
    sr?: number
    ksmps?: number
    nchnls?: number
    "0dbfs"?: number
  }

  export interface CsdSection {
    name: string
    content: string
    startLine: number
    endLine: number
  }

  export interface CsdMacro {
    name: string
    value: string
    line: number
  }

  export interface CsdStructure {
    /** All extracted parameters, flattened */
    parameters: CsdParameter[]
    /** Instrument blocks */
    instruments: CsdInstrument[]
    /** Global header values */
    globals: CsdGlobals
    /** Top-level sections (CsOptions, CsInstruments, CsScore, Cabbage) */
    sections: CsdSection[]
    /** #define macros */
    macros: CsdMacro[]
    /** Cabbage widget channels (if Cabbage section exists) */
    widgetChannels: Map<string, WidgetChannel>
  }

  export interface WidgetChannel {
    name: string
    widgetType: string
    line: number
    range?: [number, number]
    defaultValue?: number
  }

  // --- Locked Parameters Store (shared between TUI and prompt) ---

  const _lockedParams = new Map<string, Set<string>>() // sessionID -> Set<"instrId:paramName">

  export function setLockedParams(sessionID: string, params: Set<string>): void {
    _lockedParams.set(sessionID, params)
  }

  export function getLockedParams(sessionID: string): Set<string> {
    return _lockedParams.get(sessionID) ?? new Set()
  }

  /**
   * Format locked params as a constraints block for system prompt injection.
   */
  export function formatLockedConstraints(
    sessionID: string,
    csdContent?: string,
  ): string | null {
    const locked = getLockedParams(sessionID)
    if (locked.size === 0) return null

    // If CSD content available, resolve current values
    let structure: CsdStructure | null = null
    if (csdContent) {
      try {
        structure = parse(csdContent)
      } catch { /* empty */ }
    }

    const lines: string[] = []
    for (const key of locked) {
      const [instrId, paramName] = key.includes(":") ? key.split(":", 2) : [undefined, key]
      let value = "unknown"
      if (structure) {
        const param = structure.parameters.find(
          (p) => p.name === paramName && (!instrId || p.instrument === instrId),
        )
        if (param?.value) value = param.value
      }
      const instrLabel = instrId ? ` in instr ${instrId}` : ""
      lines.push(`DO NOT modify: ${paramName} (currently ${value})${instrLabel}`)
    }

    return ["<constraints>", ...lines, "</constraints>"].join("\n")
  }

  // --- Parser ---

  export function parse(content: string): CsdStructure {
    const lines = content.split("\n")
    const sections = extractSections(content, lines)
    const instrumentsSection = sections.find((s) => s.name === "CsInstruments")
    const cabbageSection = sections.find((s) => s.name === "Cabbage")
    const scoreSection = sections.find((s) => s.name === "CsScore")

    const globals = instrumentsSection ? extractGlobals(instrumentsSection.content) : {}
    const macros = extractMacros(content, lines)
    const widgetChannels = cabbageSection ? extractWidgetChannels(cabbageSection) : new Map<string, WidgetChannel>()

    const instruments = instrumentsSection
      ? extractInstruments(instrumentsSection, widgetChannels)
      : []

    // Collect all parameters from instruments + top-level chngets
    const allParams: CsdParameter[] = []
    for (const instr of instruments) {
      allParams.push(...instr.parameters)
    }

    // Add macro-derived parameters
    for (const macro of macros) {
      const numValue = parseFloat(macro.value)
      if (!isNaN(numValue)) {
        allParams.push({
          name: macro.name,
          rate: "i",
          source: "define",
          value: macro.value,
          line: macro.line,
          smoothed: false,
        })
      }
    }

    // Add pfield parameters from score section
    if (scoreSection) {
      const pfieldParams = extractPfieldParameters(scoreSection, instruments)
      allParams.push(...pfieldParams)
    }

    log.info("parsed CSD", {
      parameters: allParams.length,
      instruments: instruments.length,
      macros: macros.length,
      sections: sections.length,
    })

    return {
      parameters: allParams,
      instruments,
      globals,
      sections,
      macros,
      widgetChannels,
    }
  }

  // --- Section extraction ---

  function extractSections(content: string, lines: string[]): CsdSection[] {
    const sections: CsdSection[] = []
    const sectionNames = ["CsOptions", "CsInstruments", "CsScore", "Cabbage"]

    for (const name of sectionNames) {
      const openTag = `<${name}>`
      const closeTag = `</${name}>`
      const openIdx = content.indexOf(openTag)
      const closeIdx = content.indexOf(closeTag)
      if (openIdx === -1 || closeIdx === -1) continue

      const sectionContent = content.slice(openIdx + openTag.length, closeIdx)
      const startLine = content.slice(0, openIdx).split("\n").length
      const endLine = content.slice(0, closeIdx + closeTag.length).split("\n").length

      sections.push({
        name,
        content: sectionContent,
        startLine,
        endLine,
      })
    }

    return sections
  }

  // --- Globals extraction ---

  function extractGlobals(instrumentsContent: string): CsdGlobals {
    const globals: CsdGlobals = {}
    const lines = instrumentsContent.split("\n")

    for (const line of lines) {
      const trimmed = line.trim()
      if (trimmed.startsWith(";") || !trimmed) continue

      const srMatch = trimmed.match(/^sr\s*=\s*(\d+)/)
      if (srMatch) globals.sr = parseInt(srMatch[1])

      const ksmpsMatch = trimmed.match(/^ksmps\s*=\s*(\d+)/)
      if (ksmpsMatch) globals.ksmps = parseInt(ksmpsMatch[1])

      const nchnlsMatch = trimmed.match(/^nchnls\s*=\s*(\d+)/)
      if (nchnlsMatch) globals.nchnls = parseInt(nchnlsMatch[1])

      const dbfsMatch = trimmed.match(/^0dbfs\s*=\s*([\d.]+)/)
      if (dbfsMatch) globals["0dbfs"] = parseFloat(dbfsMatch[1])
    }

    return globals
  }

  // --- Macro extraction ---

  function extractMacros(content: string, lines: string[]): CsdMacro[] {
    const macros: CsdMacro[] = []

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.startsWith(";") || !line) continue

      // Match: #define NAME #value# or #define NAME #value #
      const match = line.match(/^#define\s+(\w+)\s+#\s*([^#]*?)\s*#/)
      if (match) {
        macros.push({
          name: match[1],
          value: match[2].trim(),
          line: i + 1,
        })
      }
    }

    return macros
  }

  // --- Instrument extraction ---

  function extractInstruments(
    section: CsdSection,
    widgetChannels: Map<string, WidgetChannel>,
  ): CsdInstrument[] {
    const instruments: CsdInstrument[] = []
    const lines = section.content.split("\n")
    const sectionOffset = section.startLine

    let currentInstr: {
      id: string
      startLine: number
      description?: string
      bodyLines: { text: string; lineNum: number }[]
    } | null = null

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      const trimmed = line.trim()
      const lineNum = sectionOffset + i

      // Match instr start
      const instrMatch = trimmed.match(/^instr\s+(.+)/)
      if (instrMatch) {
        // Look for description comment on previous line
        let description: string | undefined
        if (i > 0) {
          const prevLine = lines[i - 1].trim()
          if (prevLine.startsWith(";")) {
            description = prevLine.slice(1).trim()
          }
        }

        currentInstr = {
          id: instrMatch[1].trim(),
          startLine: lineNum,
          description,
          bodyLines: [],
        }
        continue
      }

      // Match endin
      if (trimmed === "endin" && currentInstr) {
        const params = extractInstrumentParameters(
          currentInstr.bodyLines,
          currentInstr.id,
          widgetChannels,
        )
        instruments.push({
          id: currentInstr.id,
          startLine: currentInstr.startLine,
          endLine: lineNum,
          parameters: params,
          description: currentInstr.description,
        })
        currentInstr = null
        continue
      }

      if (currentInstr) {
        currentInstr.bodyLines.push({ text: trimmed, lineNum })
      }
    }

    return instruments
  }

  // --- Parameter extraction within an instrument ---

  function extractInstrumentParameters(
    bodyLines: { text: string; lineNum: number }[],
    instrumentId: string,
    widgetChannels: Map<string, WidgetChannel>,
  ): CsdParameter[] {
    const params: CsdParameter[] = []
    const smoothedVars = new Map<string, { time?: number }>()

    // First pass: find smoothed variables
    for (const { text } of bodyLines) {
      if (text.startsWith(";") || !text) continue
      // kSmoothed port kRaw, 0.01
      // kSmoothed portk kRaw, 0.01
      const smoothMatch = text.match(/(\w+)\s+(?:port|portk)\s+(\w+)(?:\s*,\s*([\d.]+))?/)
      if (smoothMatch) {
        smoothedVars.set(smoothMatch[2], {
          time: smoothMatch[3] ? parseFloat(smoothMatch[3]) : undefined,
        })
      }
    }

    // Second pass: extract parameters
    for (const { text, lineNum } of bodyLines) {
      if (text.startsWith(";") || !text) continue

      // chnget channels: kVar chnget "channelName"
      const chngetMatch = text.match(/(\w+)\s+chnget\s+"([^"]+)"/)
      if (chngetMatch) {
        const varName = chngetMatch[1]
        const channelName = chngetMatch[2]
        const rate = detectRate(varName)
        const widget = widgetChannels.get(channelName)
        const smooth = smoothedVars.get(varName)

        params.push({
          name: channelName,
          rate,
          source: "chnget",
          line: lineNum,
          instrument: instrumentId,
          smoothed: smooth !== undefined,
          smoothTime: smooth?.time,
          channel: channelName,
          range: widget?.range,
          value: widget?.defaultValue?.toString(),
        })
        continue
      }

      // init assignments: iVar = value, kVar init value
      const initMatch = text.match(/^([ikaS]\w+)\s*=\s*([\d.eE+-]+)/) ||
        text.match(/^([ikaS]\w+)\s+init\s+([\d.eE+-]+)/)
      if (initMatch) {
        const varName = initMatch[1]
        const value = initMatch[2]
        const rate = detectRate(varName)

        // Only include i-rate assignments that look like user-tuneable params
        // Skip loop counters, index vars, etc.
        if (rate === "i" && isLikelyParameter(varName, value)) {
          params.push({
            name: varName,
            rate,
            source: "init",
            value,
            line: lineNum,
            instrument: instrumentId,
            smoothed: false,
          })
        }
      }

      // pfield references: iVar = p4, iFreq = p5
      const pfieldMatch = text.match(/^(\w+)\s*=\s*p(\d+)/)
      if (pfieldMatch) {
        const varName = pfieldMatch[1]
        const pfieldNum = parseInt(pfieldMatch[2])
        if (pfieldNum >= 4) {
          params.push({
            name: varName,
            rate: "i",
            source: "pfield",
            value: `p${pfieldNum}`,
            line: lineNum,
            instrument: instrumentId,
            smoothed: false,
          })
        }
      }
    }

    return params
  }

  // --- Widget channel extraction from Cabbage section ---

  function extractWidgetChannels(section: CsdSection): Map<string, WidgetChannel> {
    const channels = new Map<string, WidgetChannel>()
    const lines = section.content.split("\n")

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.startsWith(";") || !line) continue

      const channelMatch = line.match(/channel\("([^"]+)"\)/)
      if (!channelMatch) continue

      const channelName = channelMatch[1]
      const widgetTypeMatch = line.match(/^(\w+)\s/)
      const widgetType = widgetTypeMatch ? widgetTypeMatch[1] : "unknown"

      // Extract range from range() or bounds from rslider, etc.
      let range: [number, number] | undefined
      let defaultValue: number | undefined
      const rangeMatch = line.match(/range\(([\d.eE+-]+)\s*,\s*([\d.eE+-]+)\s*,\s*([\d.eE+-]+)/)
      if (rangeMatch) {
        range = [parseFloat(rangeMatch[1]), parseFloat(rangeMatch[2])]
        defaultValue = parseFloat(rangeMatch[3])
      }

      channels.set(channelName, {
        name: channelName,
        widgetType,
        line: section.startLine + i,
        range,
        defaultValue,
      })
    }

    return channels
  }

  // --- Score pfield parameter detection ---

  function extractPfieldParameters(
    scoreSection: CsdSection,
    instruments: CsdInstrument[],
  ): CsdParameter[] {
    // Parse score events: "i <instrNum> <start> <dur> <p4> <p5> ..."
    const scoreEvents = new Map<string, number[][]>()

    for (const line of scoreSection.content.split("\n")) {
      const trimmed = line.trim()
      if (trimmed.startsWith(";") || !trimmed) continue
      const match = trimmed.match(/^i\s+(\S+)\s+(.+)/)
      if (!match) continue
      const instrId = match[1]
      const fields = match[2].split(/\s+/).map(s => parseFloat(s.split(";")[0]))
      if (!scoreEvents.has(instrId)) scoreEvents.set(instrId, [])
      scoreEvents.get(instrId)!.push(fields)
    }

    // For each instrument's pfield params, resolve values from score
    for (const instr of instruments) {
      const events = scoreEvents.get(instr.id)
      if (!events || events.length === 0) continue

      for (const param of instr.parameters) {
        if (param.source !== "pfield") continue
        const pfieldNum = parseInt(param.value?.replace("p", "") ?? "")
        if (isNaN(pfieldNum) || pfieldNum < 4) continue

        // pfield index in score: p4 → index 2 (after start, dur)
        const fieldIndex = pfieldNum - 2
        const values = events.map(e => e[fieldIndex]).filter(v => !isNaN(v))
        if (values.length === 0) continue

        // Resolve: first event value as the current value
        param.value = String(values[0])
        const allSame = values.every(v => v === values[0])

        // Only set range when values actually span a range;
        // for constant values, leave range undefined so the UI
        // can apply a smart heuristic based on param name
        if (!allSame) {
          param.range = [Math.min(...values), Math.max(...values)]
        }

        // Mark whether values vary across score events
        ;(param as any).pfieldNum = pfieldNum
        ;(param as any).pfieldVaries = !allSame
      }
    }

    return [] // params are mutated in-place on instrument objects, already in allParams
  }

  // --- Helpers ---

  function detectRate(varName: string): "k" | "a" | "i" | "S" {
    if (varName.startsWith("k") || varName.startsWith("K")) return "k"
    if (varName.startsWith("a") || varName.startsWith("A")) return "a"
    if (varName.startsWith("S")) return "S"
    return "i"
  }

  function isLikelyParameter(varName: string, value: string): boolean {
    // Skip common non-parameter patterns
    const skipPatterns = [/^i[A-Z]?ndx/, /^iCount/, /^iLen/, /^iNum/, /^iIdx/]
    for (const pat of skipPatterns) {
      if (pat.test(varName)) return false
    }
    // Include variables with descriptive names (Amp, Freq, Mul, Ratio, Time, etc.)
    const paramPatterns = [
      /[Aa]mp/, /[Ff]req/, /[Mm]ul/, /[Rr]atio/, /[Tt]ime/, /[Dd]el/,
      /[Ff]eedback/, /[Cc]utoff/, /[Rr]es/, /[Gg]ain/, /[Ll]evel/,
      /[Pp]an/, /[Dd]epth/, /[Rr]ate/, /[Ww]idth/, /[Mm]ix/,
      /[Aa]ttack/, /[Dd]ecay/, /[Ss]ustain/, /[Rr]elease/,
    ]
    return paramPatterns.some((pat) => pat.test(varName))
  }
}
