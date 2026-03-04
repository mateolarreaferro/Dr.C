import { createSignal, createMemo, For, Show } from "solid-js"
import { useTheme } from "../../context/theme"
import { useKeyboard, useTerminalDimensions } from "@opentui/solid"
import { CsdParser } from "@/csound/parser"
import { SignalFlow } from "@/csound/signal-flow"
import { SignalFlowDiagram } from "../../component/signal-flow-diagram"

export function DialogSignalFlow(props: {
  csdContent: string
  onClose: () => void
}) {
  const { theme } = useTheme()
  const dimensions = useTerminalDimensions()

  const structure = createMemo(() => CsdParser.parse(props.csdContent))
  const instruments = createMemo(() => structure().instruments)

  const [selectedIndex, setSelectedIndex] = createSignal(0)

  const selectedInstr = createMemo(() => instruments()[selectedIndex()])

  const graph = createMemo(() => {
    const instr = selectedInstr()
    if (!instr) return null
    // Extract body: lines between instr and endin
    const lines = props.csdContent.split("\n")
    const body = lines.slice(instr.startLine, instr.endLine - 1).join("\n")
    return SignalFlow.analyze(body, instr.id)
  })

  const levels = createMemo(() => {
    const g = graph()
    if (!g) return []
    return SignalFlow.topologicalLevels(g)
  })

  useKeyboard((evt) => {
    if (evt.name === "tab") {
      setSelectedIndex((i) => (i + 1) % Math.max(1, instruments().length))
      evt.preventDefault()
    } else if (evt.name === "escape" || evt.name === "q") {
      props.onClose()
      evt.preventDefault()
    }
  })

  return (
    <box flexDirection="column" padding={1}>
      <text fg={theme.text} bold>Signal Flow Diagram</text>
      <text fg={theme.textMuted}>Tab to switch instruments, Esc to close</text>

      <Show when={instruments().length > 0} fallback={
        <text fg={theme.textMuted} marginTop={1}>No instruments found in CSD</text>
      }>
        <box flexDirection="row" marginTop={1} gap={1}>
          <For each={instruments()}>
            {(instr, index) => (
              <text
                fg={selectedIndex() === index() ? theme.accent : theme.textMuted}
                bold={selectedIndex() === index()}
              >
                {selectedIndex() === index() ? "\u25B8 " : "  "}
                instr {instr.id}
              </text>
            )}
          </For>
        </box>

        <box marginTop={1} flexDirection="column">
          <Show when={graph() && graph()!.nodes.length > 0} fallback={
            <text fg={theme.textMuted}>No signal flow detected in instr {selectedInstr()?.id}</text>
          }>
            <SignalFlowDiagram
              levels={levels()}
              edges={graph()!.edges}
              width={Math.min(dimensions().width - 8, 100)}
            />
            <text fg={theme.textMuted} marginTop={1}>
              {graph()!.nodes.length} node(s), {graph()!.edges.length} connection(s)
            </text>
          </Show>
        </box>
      </Show>
    </box>
  )
}
