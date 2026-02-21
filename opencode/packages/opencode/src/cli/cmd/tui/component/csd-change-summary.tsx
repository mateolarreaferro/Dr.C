import { createMemo, For, Show } from "solid-js"
import { useTheme } from "../context/theme"
import { CsdParser } from "@/csound/parser"

export interface CsdChange {
  type: "add_instrument" | "modify_instrument" | "add_opcode" | "remove_opcode" | "change_param" | "add_table" | "remove_table"
  instrument?: string
  detail: string
}

/**
 * Parse the semantic diff between old and new CSD content.
 */
export function computeCsdChanges(oldContent: string, newContent: string): CsdChange[] {
  const changes: CsdChange[] = []

  let oldStructure: CsdParser.CsdStructure | null = null
  let newStructure: CsdParser.CsdStructure | null = null

  try {
    oldStructure = CsdParser.parse(oldContent)
  } catch { /* empty */ }
  try {
    newStructure = CsdParser.parse(newContent)
  } catch { /* empty */ }

  if (!oldStructure || !newStructure) return changes

  // Compare instruments
  const oldInstrIDs = new Set(oldStructure.instruments.map((i) => i.id))
  const newInstrIDs = new Set(newStructure.instruments.map((i) => i.id))

  for (const id of newInstrIDs) {
    if (!oldInstrIDs.has(id)) {
      const instr = newStructure.instruments.find((i) => i.id === id)
      const desc = instr?.description ? ` (${instr.description})` : ""
      changes.push({ type: "add_instrument", instrument: id, detail: `+instr ${id}${desc}` })
    }
  }

  // Compare opcodes within shared instruments
  for (const newInstr of newStructure.instruments) {
    const oldInstr = oldStructure.instruments.find((i) => i.id === newInstr.id)
    if (!oldInstr) continue

    // Extract opcodes from instrument body via content comparison
    const oldOpcodes = extractOpcodes(oldContent, oldInstr)
    const newOpcodes = extractOpcodes(newContent, newInstr)

    for (const op of newOpcodes) {
      if (!oldOpcodes.has(op)) {
        changes.push({ type: "add_opcode", instrument: newInstr.id, detail: `instr ${newInstr.id}: +${op}` })
      }
    }
    for (const op of oldOpcodes) {
      if (!newOpcodes.has(op)) {
        changes.push({ type: "remove_opcode", instrument: newInstr.id, detail: `instr ${newInstr.id}: -${op}` })
      }
    }
  }

  // Compare parameters
  for (const newParam of newStructure.parameters) {
    const oldParam = oldStructure.parameters.find(
      (p) => p.name === newParam.name && p.instrument === newParam.instrument,
    )
    if (oldParam && oldParam.value !== newParam.value) {
      const instrLabel = newParam.instrument ? `instr ${newParam.instrument}: ` : ""
      changes.push({
        type: "change_param",
        instrument: newParam.instrument,
        detail: `${instrLabel}${newParam.name} ${oldParam.value} -> ${newParam.value}`,
      })
    }
  }

  // Compare function tables (macros with gi prefix or ftgen references)
  const oldTables = extractTables(oldContent)
  const newTables = extractTables(newContent)

  for (const t of newTables) {
    if (!oldTables.has(t)) {
      changes.push({ type: "add_table", detail: `+${t}` })
    }
  }
  for (const t of oldTables) {
    if (!newTables.has(t)) {
      changes.push({ type: "remove_table", detail: `-${t}` })
    }
  }

  return changes
}

const OPCODE_PATTERN =
  /\b(oscili?|poscil|vco2|moogladder|lpf18|zdf_2pole|zdf_ladder|butterlp|butterhp|butterbp|butterbs|reverbsc|reverb2?|freeverb|nreverb|delay|delayr|delayw|deltap[i3]?|flanger|chorus|phaser[12]|distort|tanh|powershape|clip|wrap|fold|loscil[3]?|diskin2?|foscili?|buzz|gbuzz|grain3?|partikkel|fog|fof2?|wgpluck2?|wgbow|wgflute|wgclar|repluck|pluck|noise|pinker?|linen|adsr|madsr|mxadsr|envlpx|linseg|expseg|transeg|cosseg|loopseg|jspline|rspline|port|portk|tonek|atonek|tonex|atone|reson|resonx?|areson|bqrez|svfilter|statevar|mode|compress2?|dam|follow2?|rms|balance2?|pan2|pan|vbap[48]?|hrtfstat|hrtfmove2?|pvs\w+|lfo|phasor|metro|schedule|schedkwhen|ftgen)\b/gi

function extractOpcodes(content: string, instr: CsdParser.CsdInstrument): Set<string> {
  const lines = content.split("\n").slice(instr.startLine - 1, instr.endLine)
  const body = lines.join("\n")
  const matches = body.match(OPCODE_PATTERN) ?? []
  return new Set(matches.map((m) => m.toLowerCase()))
}

function extractTables(content: string): Set<string> {
  const tables = new Set<string>()
  // Match giTableName ftgen ... or giTableName = ftgen(...)
  const ftgenPattern = /\b(gi\w+)\s+(?:ftgen|=\s*ftgen)/g
  let match
  while ((match = ftgenPattern.exec(content)) !== null) {
    tables.add(match[1])
  }
  // Match GEN routines in score: f N 0 size GEN#
  const genPattern = /^f\s+\d+\s+\d+\s+\d+\s+(GEN\d+)/gm
  while ((match = genPattern.exec(content)) !== null) {
    tables.add(match[1])
  }
  return tables
}

/**
 * Render a compact structured summary of CSD changes.
 */
export function CsdChangeSummary(props: { changes: CsdChange[] }) {
  const { theme } = useTheme()

  const iconFor = (type: CsdChange["type"]) => {
    switch (type) {
      case "add_instrument":
      case "add_opcode":
      case "add_table":
        return { char: "+", color: theme.success }
      case "remove_opcode":
      case "remove_table":
        return { char: "-", color: theme.error }
      case "change_param":
        return { char: "~", color: theme.warning }
      case "modify_instrument":
        return { char: "~", color: theme.accent }
    }
  }

  return (
    <Show when={props.changes.length > 0}>
      <box flexDirection="column" paddingLeft={2}>
        <For each={props.changes.slice(0, 8)}>
          {(change) => {
            const icon = iconFor(change.type)
            return (
              <text>
                <span style={{ fg: icon.color, bold: true }}>{icon.char}</span>{" "}
                <span style={{ fg: theme.text }}>{change.detail}</span>
              </text>
            )
          }}
        </For>
        <Show when={props.changes.length > 8}>
          <text fg={theme.textMuted}>...and {props.changes.length - 8} more changes</text>
        </Show>
      </box>
    </Show>
  )
}
