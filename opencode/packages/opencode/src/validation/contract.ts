import { Log } from "../util/log"

const log = Log.create({ service: "contract-validator" })

export namespace ContractValidator {
  export interface ContractViolation {
    type: "orphan_channel" | "unbound_widget" | "missing_smoothing" | "overlapping_bounds" | "missing_section"
    severity: "error" | "warning"
    message: string
    channel?: string
    line?: number
    section?: string
  }

  export function validate(csdContent: string): ContractViolation[] {
    const violations: ContractViolation[] = []

    // Extract sections
    const cabbage = extractSection(csdContent, "Cabbage")
    const instruments = extractSection(csdContent, "CsInstruments")
    const score = extractSection(csdContent, "CsScore")

    // Check required sections
    if (!instruments) {
      violations.push({
        type: "missing_section",
        severity: "error",
        message: "Missing <CsInstruments> section",
        section: "CsInstruments",
      })
      return violations // Can't validate further without instruments
    }

    // Extract widget channels from Cabbage section
    const widgetChannels = extractWidgetChannels(cabbage || "")

    // Extract chnget channels from CsInstruments
    const chngetChannels = extractChngetChannels(instruments)

    // Extract channels with smoothing (port/portk)
    const smoothedChannels = extractSmoothedChannels(instruments)

    // Check for orphan channels (chnget without widget)
    for (const ch of chngetChannels) {
      if (!widgetChannels.has(ch.name) && cabbage) {
        violations.push({
          type: "orphan_channel",
          severity: "warning",
          message: `Channel "${ch.name}" has chnget but no Cabbage widget`,
          channel: ch.name,
          line: ch.line,
          section: "CsInstruments",
        })
      }
    }

    // Check for unbound widgets (widget without chnget)
    if (cabbage) {
      for (const [channel, info] of widgetChannels) {
        const hasChnget = chngetChannels.some((c) => c.name === channel)
        if (!hasChnget) {
          violations.push({
            type: "unbound_widget",
            severity: "error",
            message: `Widget channel "${channel}" has no corresponding chnget in CsInstruments`,
            channel,
            line: info.line,
            section: "Cabbage",
          })
        }
      }
    }

    // Check for missing smoothing on k-rate channels
    if (cabbage) {
      for (const ch of chngetChannels) {
        if (widgetChannels.has(ch.name) && !smoothedChannels.has(ch.name)) {
          // Only warn for continuous controls (not combobox/button/checkbox)
          const widget = widgetChannels.get(ch.name)
          if (widget && !["combobox", "button", "checkbox"].includes(widget.type)) {
            violations.push({
              type: "missing_smoothing",
              severity: "warning",
              message: `Channel "${ch.name}" is read via chnget but has no port/portk smoothing (may cause zipper noise)`,
              channel: ch.name,
              line: ch.line,
              section: "CsInstruments",
            })
          }
        }
      }
    }

    // Check for overlapping bounds in Cabbage widgets
    if (cabbage) {
      const bounds = extractWidgetBounds(cabbage)
      for (let i = 0; i < bounds.length; i++) {
        for (let j = i + 1; j < bounds.length; j++) {
          if (boundsOverlap(bounds[i].rect, bounds[j].rect)) {
            violations.push({
              type: "overlapping_bounds",
              severity: "warning",
              message: `Widgets "${bounds[i].channel}" and "${bounds[j].channel}" have overlapping bounds`,
              channel: bounds[i].channel,
              section: "Cabbage",
            })
          }
        }
      }
    }

    log.info("contract validation complete", {
      violations: violations.length,
      errors: violations.filter((v) => v.severity === "error").length,
      warnings: violations.filter((v) => v.severity === "warning").length,
    })

    return violations
  }

  function extractSection(content: string, section: string): string | null {
    const openTag = `<${section}>`
    const closeTag = `</${section}>`
    const start = content.indexOf(openTag)
    const end = content.indexOf(closeTag)
    if (start === -1 || end === -1) return null
    return content.slice(start + openTag.length, end)
  }

  interface WidgetInfo {
    type: string
    line: number
    channel: string
  }

  function extractWidgetChannels(cabbage: string): Map<string, WidgetInfo> {
    const channels = new Map<string, WidgetInfo>()
    const lines = cabbage.split("\n")

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.startsWith(";") || !line) continue

      const channelMatch = line.match(/channel\("([^"]+)"\)/)
      if (channelMatch) {
        const widgetType = line.match(/^(\w+)\s/)
        channels.set(channelMatch[1], {
          type: widgetType ? widgetType[1] : "unknown",
          line: i + 1,
          channel: channelMatch[1],
        })
      }
    }

    return channels
  }

  interface ChannelRef {
    name: string
    line: number
  }

  function extractChngetChannels(instruments: string): ChannelRef[] {
    const channels: ChannelRef[] = []
    const lines = instruments.split("\n")

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.startsWith(";") || !line) continue

      // Match: kVar chnget "channelName"
      const match = line.match(/chnget\s+"([^"]+)"/)
      if (match) {
        channels.push({ name: match[1], line: i + 1 })
      }
    }

    return channels
  }

  function extractSmoothedChannels(instruments: string): Set<string> {
    const smoothed = new Set<string>()
    const lines = instruments.split("\n")

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.startsWith(";") || !line) continue

      // Match: kVar port kVar, time  or  kVar portk kVar, time
      const match = line.match(/(\w+)\s+(?:port|portk)\s+(\w+)/)
      if (match) {
        // Find which channel this variable corresponds to
        const varName = match[2]
        // Look backwards for the chnget that assigned to this variable
        for (let j = i - 1; j >= Math.max(0, i - 5); j--) {
          const prevLine = lines[j].trim()
          const chngetMatch = prevLine.match(new RegExp(`${varName}\\s+chnget\\s+"([^"]+)"`))
          if (chngetMatch) {
            smoothed.add(chngetMatch[1])
            break
          }
        }
      }
    }

    return smoothed
  }

  interface WidgetBounds {
    channel: string
    rect: [number, number, number, number] // x, y, w, h
  }

  function extractWidgetBounds(cabbage: string): WidgetBounds[] {
    const bounds: WidgetBounds[] = []
    const lines = cabbage.split("\n")

    for (const line of lines) {
      const trimmed = line.trim()
      if (trimmed.startsWith(";") || !trimmed) continue

      const channelMatch = trimmed.match(/channel\("([^"]+)"\)/)
      const boundsMatch = trimmed.match(/bounds\((\d+),\s*(\d+),\s*(\d+),\s*(\d+)\)/)

      if (channelMatch && boundsMatch) {
        bounds.push({
          channel: channelMatch[1],
          rect: [
            parseInt(boundsMatch[1]),
            parseInt(boundsMatch[2]),
            parseInt(boundsMatch[3]),
            parseInt(boundsMatch[4]),
          ],
        })
      }
    }

    return bounds
  }

  function boundsOverlap(a: [number, number, number, number], b: [number, number, number, number]): boolean {
    const [ax, ay, aw, ah] = a
    const [bx, by, bw, bh] = b
    return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
  }
}
