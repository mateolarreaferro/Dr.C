import { createMemo, For, Show } from "solid-js"
import { useTheme } from "../context/theme"
import type { SignalFlow } from "@/csound/signal-flow"

const CATEGORY_LABELS: Record<SignalFlow.OpcodeCategory, string> = {
  source: "SRC",
  filter: "FLT",
  effect: "FX",
  output: "OUT",
  envelope: "ENV",
  modulator: "MOD",
  control: "CTL",
  other: "---",
}

export function SignalFlowDiagram(props: {
  levels: SignalFlow.FlowNode[][]
  edges: SignalFlow.FlowEdge[]
  width: number
}) {
  const { theme } = useTheme()

  const categoryColor = (cat: SignalFlow.OpcodeCategory) => {
    switch (cat) {
      case "source": return theme.success        // green
      case "filter": return theme.warning         // yellow
      case "effect": return theme.accent          // cyan
      case "output": return theme.text            // white
      case "envelope": return theme.textMuted     // dim
      case "modulator": return theme.error        // red/magenta
      default: return theme.textMuted
    }
  }

  const diagram = createMemo(() => {
    const levels = props.levels
    if (levels.length === 0) return []

    const lines: Array<{ text: string; colors: Array<{ start: number; end: number; fg: string }> }> = []
    const maxWidth = Math.max(props.width - 4, 40)

    for (let lvl = 0; lvl < levels.length; lvl++) {
      const nodes = levels[lvl]

      // Node boxes for this level
      const nodeTexts: string[] = []
      const nodeColors: Array<{ start: number; end: number; fg: string }> = []

      let offset = 0
      for (let n = 0; n < nodes.length; n++) {
        const node = nodes[n]
        const tag = CATEGORY_LABELS[node.category]
        const label = `[${tag}] ${node.opcode}`
        const padded = n < nodes.length - 1 ? label + "   " : label

        nodeColors.push({
          start: offset,
          end: offset + label.length,
          fg: categoryColor(node.category),
        })

        nodeTexts.push(padded)
        offset += padded.length
      }

      const nodeLineText = nodeTexts.join("")
      lines.push({ text: nodeLineText.slice(0, maxWidth), colors: nodeColors })

      // Connection lines between levels
      if (lvl < levels.length - 1) {
        // Find edges from this level to next level
        const currentNodeIds = new Set(nodes.map(n => n.id))
        const nextNodes = levels[lvl + 1]
        const nextNodeIds = new Set(nextNodes.map(n => n.id))

        const relevantEdges = props.edges.filter(
          e => currentNodeIds.has(e.from) && nextNodeIds.has(e.to)
        )

        if (relevantEdges.length > 0) {
          // Show variable names on connection
          const vars = relevantEdges.map(e => e.variable).slice(0, 3)
          const connLine = `  ${vars.length > 0 ? "\u2502 " + vars.join(", ") : "\u2502"}`
          lines.push({
            text: connLine,
            colors: [{ start: 2, end: 3, fg: theme.textMuted }],
          })
          lines.push({
            text: "  \u25BE",
            colors: [{ start: 2, end: 3, fg: theme.textMuted }],
          })
        } else {
          lines.push({ text: "  \u2502", colors: [{ start: 2, end: 3, fg: theme.textMuted }] })
          lines.push({ text: "  \u25BE", colors: [{ start: 2, end: 3, fg: theme.textMuted }] })
        }
      }
    }

    return lines
  })

  return (
    <box flexDirection="column">
      <Show when={diagram().length > 0} fallback={
        <text fg={theme.textMuted}>No signal flow detected</text>
      }>
        <For each={diagram()}>
          {(line) => (
            <text fg={theme.text} wrapMode="none">
              {line.text}
            </text>
          )}
        </For>
      </Show>
      <box marginTop={1}>
        <text fg={theme.textMuted}>
          <span style={{ fg: theme.success }}>SRC</span>=source{" "}
          <span style={{ fg: theme.warning }}>FLT</span>=filter{" "}
          <span style={{ fg: theme.accent }}>FX</span>=effect{" "}
          <span style={{ fg: theme.text }}>OUT</span>=output{" "}
          <span style={{ fg: theme.textMuted }}>ENV</span>=envelope{" "}
          <span style={{ fg: theme.error }}>MOD</span>=modulator
        </text>
      </box>
    </box>
  )
}
