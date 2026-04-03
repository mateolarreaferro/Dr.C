import z from "zod"
import path from "path"
import fs from "fs/promises"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"
import { CsdParser } from "../csound/parser"
import { WavAnalyzer } from "../analysis/wav-analyzer"
import DESCRIPTION from "./edit_by_ear.txt"

const log = Log.create({ service: "tool.edit-by-ear" })

interface ScoreEvent {
  instrId: string
  startTime: number
  duration: number
  pfields: number[]
  line: string
}

function parseScoreEvents(csdContent: string): ScoreEvent[] {
  const structure = CsdParser.parse(csdContent)
  const scoreSection = structure.sections.find((s) => s.name === "CsScore")
  if (!scoreSection) return []

  const events: ScoreEvent[] = []
  for (const line of scoreSection.content.split("\n")) {
    const trimmed = line.trim()
    if (trimmed.startsWith(";") || !trimmed) continue
    const match = trimmed.match(/^i\s+(\S+)\s+(.+)/)
    if (!match) continue

    const instrId = match[1]
    const fields = match[2]
      .split(";")[0]
      .trim()
      .split(/\s+/)
      .map((s) => parseFloat(s))

    if (fields.length >= 2) {
      events.push({
        instrId,
        startTime: fields[0],
        duration: fields[1],
        pfields: fields.slice(2),
        line: trimmed,
      })
    }
  }

  return events
}

function findActiveEvents(events: ScoreEvent[], timestamp: number): ScoreEvent[] {
  return events.filter((e) => {
    const end = e.duration > 0 ? e.startTime + e.duration : e.startTime + 999
    return timestamp >= e.startTime && timestamp <= end
  })
}

export const EditByEarTool = Tool.define(
  "edit_by_ear",
  {
    description: DESCRIPTION,
    parameters: z.object({
      timestampSeconds: z.number().min(0).describe("Time position in seconds to analyze"),
      editIntent: z
        .string()
        .optional()
        .describe("What the user wants changed (e.g., 'make it less harsh', 'louder', 'remove this')"),
    }),
    async execute(params, ctx) {
      const { timestampSeconds, editIntent } = params

      // Find the current CSD in session workspace
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        throw new Error("No active workspace. Render a CSD first before using edit_by_ear.")
      }

      // Find CSD and WAV files in workspace
      const tempDir = wsStatus.tempDir
      let csdPath: string | undefined
      let wavPath: string | undefined

      try {
        const entries = await fs.readdir(tempDir)
        for (const entry of entries) {
          const ext = path.extname(entry).toLowerCase()
          if (ext === ".csd" && !csdPath) csdPath = path.join(tempDir, entry)
          if (ext === ".wav" && !wavPath) wavPath = path.join(tempDir, entry)
        }
      } catch {
        throw new Error(`Could not read workspace directory: ${tempDir}`)
      }

      if (!csdPath) throw new Error("No CSD file found in workspace. Write a CSD first.")
      if (!wavPath) throw new Error("No WAV file found in workspace. Render audio first.")

      // Parse the CSD
      const csdContent = await Bun.file(csdPath).text()
      const structure = CsdParser.parse(csdContent)
      const scoreEvents = parseScoreEvents(csdContent)

      // Find which events are active at the timestamp
      const activeEvents = findActiveEvents(scoreEvents, timestampSeconds)

      // Analyze WAV at the timestamp
      let rms = 0
      let brightness = 0
      let peak = 0
      try {
        const header = await WavAnalyzer.parseHeader(wavPath)
        if (timestampSeconds > header.duration) {
          throw new Error(
            `Timestamp ${timestampSeconds}s exceeds audio duration of ${header.duration.toFixed(1)}s`,
          )
        }
        rms = await WavAnalyzer.rmsAtTimestamp(wavPath, timestampSeconds)
        brightness = await WavAnalyzer.spectralCentroid(wavPath, timestampSeconds)
        const windowStart = Math.max(0, timestampSeconds - 0.05)
        const windowEnd = Math.min(header.duration, timestampSeconds + 0.05)
        peak = await WavAnalyzer.peakInRange(wavPath, windowStart, windowEnd)
      } catch (e) {
        log.warn("WAV analysis failed", { error: String(e) })
      }

      // Build analysis output
      const parts: string[] = []
      parts.push(`## Analysis at ${timestampSeconds.toFixed(2)}s`)
      parts.push("")

      // Audio metrics
      const rmsDb = rms > 0 ? (20 * Math.log10(rms)).toFixed(1) : "-inf"
      const peakDb = peak > 0 ? (20 * Math.log10(peak)).toFixed(1) : "-inf"
      parts.push(`### Audio Metrics`)
      parts.push(`- RMS amplitude: ${rmsDb} dB (linear: ${rms.toFixed(4)})`)
      parts.push(`- Peak amplitude: ${peakDb} dB (linear: ${peak.toFixed(4)})`)
      parts.push(`- Brightness (spectral centroid estimate): ${brightness.toFixed(0)} Hz`)
      parts.push("")

      // Active instruments/events
      parts.push(`### Active at this timestamp`)
      if (activeEvents.length === 0) {
        parts.push("No score events active at this timestamp — sound may come from f-table sustain or global processing.")
      } else {
        for (const event of activeEvents) {
          const instr = structure.instruments.find((i) => i.id === event.instrId)
          const instrDesc = instr?.description ? ` (${instr.description})` : ""
          parts.push(`- **instr ${event.instrId}**${instrDesc}`)
          parts.push(`  - Score: \`${event.line}\``)
          parts.push(`  - Active from ${event.startTime}s to ${(event.startTime + event.duration).toFixed(2)}s`)
          parts.push(`  - Position within event: ${(timestampSeconds - event.startTime).toFixed(2)}s into a ${event.duration}s note`)

          if (instr) {
            const kParams = instr.parameters.filter((p) => p.rate === "k" && p.value)
            if (kParams.length > 0) {
              parts.push(`  - k-rate parameters:`)
              for (const p of kParams) {
                parts.push(`    - ${p.name} = ${p.value}`)
              }
            }
          }
        }
      }
      parts.push("")

      // Suggest edit targets
      parts.push(`### Suggested Edit Targets`)
      if (editIntent) {
        parts.push(`User intent: "${editIntent}"`)
        parts.push("")
        const suggestions = suggestEdits(editIntent, activeEvents, structure, rms, brightness)
        for (const s of suggestions) {
          parts.push(`- ${s}`)
        }
      } else {
        parts.push("No edit intent specified. Provide `editIntent` for targeted suggestions.")
        parts.push("")
        parts.push("Possible areas to edit:")
        if (activeEvents.length > 0) {
          for (const event of activeEvents) {
            const instr = structure.instruments.find((i) => i.id === event.instrId)
            if (instr) {
              parts.push(`- Instrument ${event.instrId}: modify parameters, adjust envelope, change timbre`)
            }
            parts.push(`- Score event: adjust timing (start: ${event.startTime}s, dur: ${event.duration}s), pfield values`)
          }
        }
      }

      log.info("edit_by_ear analysis", {
        timestamp: timestampSeconds,
        activeEvents: activeEvents.length,
        rmsDb,
        brightness,
      })

      return {
        title: `Analysis at ${timestampSeconds.toFixed(2)}s`,
        output: parts.join("\n"),
        metadata: {
          timestampSeconds,
          activeInstruments: activeEvents.map((e) => e.instrId),
          rmsDb: parseFloat(rmsDb === "-inf" ? "-100" : rmsDb),
          brightness,
          csdPath,
          wavPath,
        },
      }
    },
  },
)

function suggestEdits(
  intent: string,
  activeEvents: ScoreEvent[],
  structure: CsdParser.CsdStructure,
  rms: number,
  brightness: number,
): string[] {
  const suggestions: string[] = []
  const lower = intent.toLowerCase()

  if (lower.includes("harsh") || lower.includes("bright") || lower.includes("sharp")) {
    suggestions.push("Lower the cutoff frequency of any low-pass filter (moogladder, lpf18, butterlp)")
    suggestions.push("Reduce high-frequency content by adding a gentle lpf18 or butterlp if none exists")
    if (brightness > 3000) {
      suggestions.push(`Current brightness is high (~${brightness.toFixed(0)} Hz) — filtering will have clear effect`)
    }
  }

  if (lower.includes("loud") || lower.includes("quiet") || lower.includes("volume")) {
    for (const event of activeEvents) {
      const instr = structure.instruments.find((i) => i.id === event.instrId)
      if (instr) {
        const ampParams = instr.parameters.filter(
          (p) => p.name.toLowerCase().includes("amp") || p.name.toLowerCase().includes("gain") || p.name.toLowerCase().includes("level"),
        )
        if (ampParams.length > 0) {
          suggestions.push(`Adjust amplitude parameter: ${ampParams.map((p) => `${p.name}=${p.value}`).join(", ")}`)
        }
      }
    }
    suggestions.push("Modify the amplitude envelope (madsr/linsegr) attack/sustain levels")
    suggestions.push("Scale the score event's amplitude pfield if applicable")
  }

  if (lower.includes("remove") || lower.includes("delete") || lower.includes("mute")) {
    for (const event of activeEvents) {
      suggestions.push(`Remove or comment out score event: \`${event.line}\``)
    }
    suggestions.push("Alternatively, set amplitude to 0 for a non-destructive mute")
  }

  if (lower.includes("movement") || lower.includes("vibrato") || lower.includes("modulation")) {
    suggestions.push("Add LFO modulation: `kMod lfo kDepth, kRate`")
    suggestions.push("Apply jitter/rspline for organic movement")
  }

  if (lower.includes("reverb") || lower.includes("space") || lower.includes("wet")) {
    suggestions.push("Add reverbsc or freeverb processing")
    suggestions.push("Increase existing reverb mix/feedback if already present")
  }

  if (suggestions.length === 0) {
    suggestions.push(`Intent "${intent}" — consider adjusting parameters of active instruments`)
    for (const event of activeEvents) {
      const instr = structure.instruments.find((i) => i.id === event.instrId)
      if (instr && instr.parameters.length > 0) {
        suggestions.push(`Tuneable params in instr ${event.instrId}: ${instr.parameters.map((p) => p.name).join(", ")}`)
      }
    }
  }

  return suggestions
}
