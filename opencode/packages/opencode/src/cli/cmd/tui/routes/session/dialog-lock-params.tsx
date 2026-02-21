import { createSignal, createMemo, For, Show } from "solid-js"
import { useTheme } from "../../context/theme"
import { useKeyboard } from "@opentui/solid"
import { CsdParser } from "@/csound/parser"

export function DialogLockParams(props: {
  parameters: CsdParser.CsdParameter[]
  lockedParams: Set<string>
  onSave: (locked: Set<string>) => void
  onClose: () => void
}) {
  const { theme } = useTheme()
  const [selected, setSelected] = createSignal(new Set(props.lockedParams))
  const [focusIndex, setFocusIndex] = createSignal(0)

  const params = createMemo(() =>
    props.parameters.filter((p) => p.value !== undefined),
  )

  const toggle = (name: string) => {
    const next = new Set(selected())
    if (next.has(name)) {
      next.delete(name)
    } else {
      next.add(name)
    }
    setSelected(next)
  }

  useKeyboard((key) => {
    if (key === "up" || key === "k") {
      setFocusIndex((i) => Math.max(0, i - 1))
    } else if (key === "down" || key === "j") {
      setFocusIndex((i) => Math.min(params().length - 1, i + 1))
    } else if (key === " " || key === "return") {
      const p = params()[focusIndex()]
      if (p) toggle(paramKey(p))
    } else if (key === "escape" || key === "q") {
      props.onClose()
    } else if (key === "s") {
      props.onSave(selected())
    }
  })

  return (
    <box flexDirection="column" padding={1}>
      <text fg={theme.text} bold>Lock Parameters</text>
      <text fg={theme.textMuted}>Space to toggle, S to save, Esc to cancel</text>
      <box flexDirection="column" paddingTop={1}>
        <For each={params()}>
          {(param, index) => {
            const key = paramKey(param)
            const isLocked = createMemo(() => selected().has(key))
            const isFocused = createMemo(() => focusIndex() === index())

            return (
              <text
                fg={isFocused() ? theme.accent : theme.text}
                bold={isFocused()}
              >
                {isLocked() ? "[x]" : "[ ]"}{" "}
                {param.name}
                <Show when={param.instrument}>
                  <span style={{ fg: theme.textMuted }}> (instr {param.instrument})</span>
                </Show>
                <span style={{ fg: theme.textMuted }}> = {param.value}</span>
              </text>
            )
          }}
        </For>
      </box>
      <Show when={params().length === 0}>
        <text fg={theme.textMuted}>No parameters with values found</text>
      </Show>
    </box>
  )
}

function paramKey(param: CsdParser.CsdParameter): string {
  return param.instrument ? `${param.instrument}:${param.name}` : param.name
}

export { paramKey }
