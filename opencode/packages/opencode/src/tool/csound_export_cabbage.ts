/**
 * Generate a Cabbage-ready CSD from a plain CSD by adding a <Cabbage> section
 * with auto-generated widgets mapped to detected parameters.
 */

interface CabbageParam {
  varName: string
  channel: string
  label: string
  value: number
  min: number
  max: number
  widgetType: "rslider" | "hslider" | "combobox" | "checkbox"
}

export function generateCabbageCsd(
  csdContent: string,
  mode: "vst" | "standalone" = "vst",
): string {
  const params = extractCabbageParams(csdContent)
  const cabbageSection = buildCabbageSection(params, mode)
  const rewrittenCsd = injectChannels(csdContent, params)

  // Insert <Cabbage> section before <CsoundSynthesizer> or at the top
  if (rewrittenCsd.includes("<CsoundSynthesizer>")) {
    return rewrittenCsd.replace(
      "<CsoundSynthesizer>",
      `<Cabbage>\n${cabbageSection}\n</Cabbage>\n<CsoundSynthesizer>`,
    )
  }
  return `<Cabbage>\n${cabbageSection}\n</Cabbage>\n${rewrittenCsd}`
}

function buildCabbageSection(params: CabbageParam[], mode: "vst" | "standalone"): string {
  const lines: string[] = []

  // Form: main container
  const formWidth = Math.max(400, Math.min(800, params.length * 100 + 200))
  const formHeight = Math.max(300, 100 + Math.ceil(params.length / 3) * 100)

  if (mode === "standalone") {
    lines.push(`form caption("DrC Export") size(${formWidth}, ${formHeight}), pluginId("DrC1"), guiMode("queue")`)
  } else {
    lines.push(`form caption("DrC Export") size(${formWidth}, ${formHeight}), pluginId("DrC1")`)
  }

  // Background
  lines.push(`image bounds(0, 0, ${formWidth}, ${formHeight}), colour(20, 20, 30)`)

  // Title label
  lines.push(`label bounds(10, 10, ${formWidth - 20}, 25), text("DrC Export"), fontColour(200, 200, 200), fontSize(16)`)

  // Layout params in a grid — 3 columns
  const cols = 3
  const padX = 15
  const padY = 50
  const knobSize = 80
  const spacing = Math.floor((formWidth - padX * 2) / cols)

  for (let i = 0; i < params.length; i++) {
    const p = params[i]
    const col = i % cols
    const row = Math.floor(i / cols)
    const x = padX + col * spacing + (spacing - knobSize) / 2
    const y = padY + row * 100

    if (p.widgetType === "rslider") {
      lines.push(
        `rslider bounds(${Math.round(x)}, ${y}, ${knobSize}, ${knobSize}), ` +
        `channel("${p.channel}"), range(${p.min}, ${p.max}, ${p.value}, 1, ${computeIncrement(p.min, p.max)}), ` +
        `text("${p.label}"), textColour(180, 180, 180), ` +
        `trackerColour(100, 220, 170), colour(40, 40, 50), outlineColour(60, 60, 70)`
      )
    } else if (p.widgetType === "hslider") {
      lines.push(
        `hslider bounds(${padX + col * spacing}, ${y}, ${spacing - 10}, 30), ` +
        `channel("${p.channel}"), range(${p.min}, ${p.max}, ${p.value}, 1, ${computeIncrement(p.min, p.max)}), ` +
        `text("${p.label}"), textColour(180, 180, 180), ` +
        `trackerColour(100, 220, 170), colour(40, 40, 50)`
      )
    } else if (p.widgetType === "checkbox") {
      lines.push(
        `checkbox bounds(${Math.round(x)}, ${y}, ${knobSize}, 25), ` +
        `channel("${p.channel}"), value(${p.value}), ` +
        `text("${p.label}"), fontColour(180, 180, 180), colour(100, 220, 170)`
      )
    }
  }

  return lines.join("\n")
}

function extractCabbageParams(csd: string): CabbageParam[] {
  const params: CabbageParam[] = []
  const seen = new Set<string>()
  const lines = csd.split("\n")

  // Match chnget-based params
  const chngetRe = /\b(k\w+)\s+chnget\s+"([^"]+)"/g
  const chngetFuncRe = /\b(k\w+)\s*=\s*chnget:k\(\s*"([^"]+)"\s*\)/g

  for (const re of [chngetRe, chngetFuncRe]) {
    for (const m of csd.matchAll(re)) {
      const varName = m[1]
      const channel = m[2]
      if (seen.has(channel)) continue
      seen.add(channel)
      const range = inferParamRange(channel, varName, lines)
      params.push({
        varName,
        channel,
        label: humanLabel(channel),
        widgetType: guessWidget(channel, range),
        ...range,
      })
    }
  }

  // Match k-rate constant assignments
  for (const line of lines) {
    const trimmed = line.replace(/;.*$/, "").trim()
    const m = trimmed.match(/^(k\w+)\s*=\s*([0-9]*\.?[0-9]+(?:[eE][+-]?[0-9]+)?)\s*$/)
    if (!m) continue

    const varName = m[1]
    const rawValue = parseFloat(m[2])
    if (isNaN(rawValue) || seen.has(varName)) continue

    const lower = varName.toLowerCase()
    if (lower.includes("ndx") || lower.includes("count") || lower.includes("flag") || lower === "ksmps") continue

    seen.add(varName)
    const channel = varName
    const range = inferParamRange(varName, varName, lines)
    range.value = rawValue

    params.push({
      varName,
      channel,
      label: humanLabel(varName),
      widgetType: guessWidget(varName, range),
      ...range,
    })
  }

  return params
}

function injectChannels(csd: string, params: CabbageParam[]): string {
  // For k-rate assignments (not already chnget), rewrite to chnget
  const assignmentParams = params.filter((p) => p.channel === p.varName)
  if (assignmentParams.length === 0) return csd

  const lines = csd.split("\n")
  const declarations = assignmentParams.map(
    (p) => `chn_k "${p.channel}", 1  ; Cabbage widget channel`,
  )

  let injected = false
  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].replace(/;.*$/, "").trim()

    if (!injected && (/^0dbfs\b/.test(trimmed) || /^seed\b/.test(trimmed))) {
      lines[i] = lines[i] + "\n" + declarations.join("\n")
      injected = true
    }

    for (const p of assignmentParams) {
      const re = new RegExp(
        `^(${escapeRegExp(p.varName)})\\s*=\\s*[0-9]*\\.?[0-9]+(?:[eE][+-]?[0-9]+)?\\s*$`,
      )
      if (re.test(trimmed)) {
        const indent = lines[i].match(/^\s*/)?.[0] || ""
        lines[i] = `${indent}${p.varName} chnget "${p.channel}"`
      }
    }
  }

  if (!injected) {
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].trim() === "<CsInstruments>") {
        lines[i] = lines[i] + "\n" + declarations.join("\n")
        break
      }
    }
  }

  return lines.join("\n")
}

function guessWidget(
  name: string,
  range: { min: number; max: number; value: number },
): "rslider" | "hslider" | "checkbox" | "combobox" {
  if (range.max === 1 && range.min === 0 && (range.value === 0 || range.value === 1)) {
    return "checkbox"
  }
  // Wide ranges → horizontal slider, narrow → rotary knob
  if (range.max - range.min > 5000) return "hslider"
  return "rslider"
}

function inferParamRange(
  name: string,
  varName: string,
  lines: string[],
): { value: number; min: number; max: number } {
  let value = 0.5
  let min = 0
  let max = 1

  for (const line of lines) {
    const trimmed = line.replace(/;.*$/, "").trim()
    const initMatch = trimmed.match(new RegExp(`\\b${escapeRegExp(varName)}\\s+init\\s+([\\d.eE+-]+)`))
    if (initMatch) value = parseFloat(initMatch[1])
    const assignMatch = trimmed.match(new RegExp(`\\b${escapeRegExp(varName)}\\s*=\\s*([\\d.eE+-]+)\\s*$`))
    if (assignMatch) value = parseFloat(assignMatch[1])
  }

  const lower = name.toLowerCase()
  if (lower.includes("freq") || lower.includes("pitch") || lower.includes("hz")) {
    min = 20; max = 8000; value = value || 440
  } else if (lower.includes("cutoff") || lower.includes("filt")) {
    min = 20; max = 12000; value = value || 2000
  } else if (lower.includes("amp") || lower.includes("vol") || lower.includes("gain") || lower.includes("level")) {
    min = 0; max = 1; value = value || 0.5
  } else if (lower.includes("res") || lower.includes("q")) {
    min = 0; max = 1; value = value || 0.3
  } else if (lower.includes("pan")) {
    min = 0; max = 1; value = value || 0.5
  } else if (lower.includes("rate") || lower.includes("speed")) {
    min = 0.1; max = 20; value = value || 1
  } else if (lower.includes("mix") || lower.includes("wet") || lower.includes("dry") || lower.includes("depth")) {
    min = 0; max = 1; value = value || 0.5
  } else if (lower.includes("attack") || lower.includes("decay") || lower.includes("release")) {
    min = 0.001; max = 5; value = value || 0.1
  } else if (lower.includes("sustain")) {
    min = 0; max = 1; value = value || 0.7
  } else if (lower.includes("feedback") || lower.includes("fb")) {
    min = 0; max = 0.99; value = value || 0.3
  } else if (lower.includes("delay") || lower.includes("time")) {
    min = 0; max = 2; value = value || 0.25
  } else if (lower.includes("base")) {
    if (value > 100) { min = 20; max = value * 3 }
    else { min = 0; max = value * 3 || 1 }
  } else if (lower.includes("env") && lower.includes("depth")) {
    min = 0; max = value * 2 || 5000
  } else {
    if (value > 1000) { min = 0; max = value * 3 }
    else if (value > 100) { min = 0; max = value * 2 }
    else if (value > 1) { min = 0; max = value * 3 }
    else { min = 0; max = 1 }
  }

  return { value, min, max }
}

function computeIncrement(min: number, max: number): number {
  const range = max - min
  if (range > 1000) return 1
  if (range > 100) return 0.1
  if (range > 10) return 0.01
  return 0.001
}

function humanLabel(name: string): string {
  return name
    .replace(/^k/, "")
    .replace(/([A-Z])/g, " $1")
    .replace(/[_-]/g, " ")
    .trim()
    .replace(/^\w/, (c) => c.toUpperCase()) || name
}

function escapeRegExp(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
}
