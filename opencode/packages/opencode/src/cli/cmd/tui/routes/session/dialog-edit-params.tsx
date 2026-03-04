import { createSignal, createMemo, createEffect, For, Show, onCleanup } from "solid-js"
import { useTheme } from "../../context/theme"
import { useKeyboard } from "@opentui/solid"
import { CsdParser } from "@/csound/parser"
import { ParamWriter } from "@/csound/param-writer"
import { SessionWorkspace } from "@/session/workspace"
import { buildFlatParams, type FlatParam } from "./param-helpers"

export function DialogEditParams(props: {
  filePath: string
  sessionID: string
  onParamChange?: () => void
  onClose: () => void
}) {
  const { theme } = useTheme()
  const [structure, setStructure] = createSignal<CsdParser.CsdStructure | null>(null)
  const [focusIndex, setFocusIndex] = createSignal(0)
  const [inputMode, setInputMode] = createSignal(false)
  const [inputBuffer, setInputBuffer] = createSignal("")

  const resolvedFilePath = createMemo(() => {
    return SessionWorkspace.resolve(props.sessionID, props.filePath)
  })

  const parseFile = async () => {
    const fp = resolvedFilePath()
    if (!fp) return
    try {
      const content = await Bun.file(fp).text()
      setStructure(CsdParser.parse(content))
    } catch {
      setStructure(null)
    }
  }

  // Initial parse
  parseFile()

  // Poll for external changes
  const interval = setInterval(parseFile, 3000)
  onCleanup(() => clearInterval(interval))

  const flatParams = createMemo((): FlatParam[] => {
    const s = structure()
    if (!s) return []
    return buildFlatParams(s)
  })

  // Clamp focus index when param count changes
  createEffect(() => {
    const len = flatParams().length
    if (len > 0 && focusIndex() >= len) {
      setFocusIndex(len - 1)
    }
  })

  const handleValueChange = async (param: CsdParser.CsdParameter, value: number) => {
    const fp = resolvedFilePath()
    if (!fp) return

    if (param.source === "pfield" && (param as any).pfieldNum) {
      await ParamWriter.updateScorePfield(fp, param.instrument!, (param as any).pfieldNum, value)
    } else {
      await ParamWriter.updateParameter(fp, param.name, value)
    }
    await parseFile()
    props.onParamChange?.()
  }

  const adjustValue = (item: FlatParam, delta: number) => {
    const currentVal = parseFloat(item.param.value ?? "0")
    if (isNaN(currentVal)) return
    const [min, max] = item.range
    const range = max - min
    const step = range * delta
    const newVal = Math.max(min, Math.min(max, currentVal + step))
    handleValueChange(item.param, newVal)
  }

  const commitInput = (item: FlatParam) => {
    const val = parseFloat(inputBuffer())
    if (!isNaN(val)) {
      const [min, max] = item.range
      const clamped = Math.max(min, Math.min(max, val))
      handleValueChange(item.param, clamped)
    }
    setInputMode(false)
    setInputBuffer("")
  }

  useKeyboard((evt) => {
    const params = flatParams()
    if (params.length === 0) return

    const current = params[focusIndex()]

    // Input mode handling
    if (inputMode()) {
      if (evt.name === "return") {
        if (current) commitInput(current)
        evt.preventDefault()
        return
      }
      if (evt.name === "escape") {
        setInputMode(false)
        setInputBuffer("")
        evt.preventDefault()
        evt.stopPropagation()
        return
      }
      if (evt.name === "backspace") {
        setInputBuffer((b) => b.slice(0, -1))
        evt.preventDefault()
        return
      }
      // Accept digits, dot, minus
      const ch = evt.char ?? ""
      if (/^[\d.\-]$/.test(ch)) {
        setInputBuffer((b) => b + ch)
        evt.preventDefault()
        return
      }
      evt.preventDefault()
      return
    }

    // Navigation
    if (evt.name === "up" || evt.name === "k") {
      setFocusIndex((i) => Math.max(0, i - 1))
      evt.preventDefault()
      return
    }
    if (evt.name === "down" || evt.name === "j") {
      setFocusIndex((i) => Math.min(params.length - 1, i + 1))
      evt.preventDefault()
      return
    }

    // Fine adjustment (1% of range)
    if (evt.name === "left") {
      if (current) adjustValue(current, evt.shift ? -0.1 : -0.01)
      evt.preventDefault()
      return
    }
    if (evt.name === "right") {
      if (current) adjustValue(current, evt.shift ? 0.1 : 0.01)
      evt.preventDefault()
      return
    }

    // Home/End: jump to min/max
    if (evt.name === "home") {
      if (current) handleValueChange(current.param, current.range[0])
      evt.preventDefault()
      return
    }
    if (evt.name === "end") {
      if (current) handleValueChange(current.param, current.range[1])
      evt.preventDefault()
      return
    }

    // Enter number input mode
    if (evt.name === "return") {
      setInputMode(true)
      setInputBuffer("")
      evt.preventDefault()
      return
    }
    const ch = evt.char ?? ""
    if (/^[\d.\-]$/.test(ch)) {
      setInputMode(true)
      setInputBuffer(ch)
      evt.preventDefault()
      return
    }
  })

  const formatValue = (val: string | undefined, range: [number, number]): string => {
    const num = parseFloat(val ?? "0")
    if (isNaN(num)) return val ?? "0"
    const rangeSize = range[1] - range[0]
    if (rangeSize >= 1000) return num.toFixed(1)
    if (rangeSize >= 10) return num.toFixed(2)
    return num.toFixed(3)
  }

  const formatRange = (range: [number, number]): string => {
    const fmt = (n: number) => {
      if (Number.isInteger(n)) return String(n)
      return n.toFixed(1)
    }
    return `[${fmt(range[0])}..${fmt(range[1])}]`
  }

  return (
    <box flexDirection="column" padding={1}>
      <text fg={theme.text} bold>
        Edit Parameters ({flatParams().length})
      </text>
      <text fg={theme.textMuted}>
        {"\u2191\u2193"} navigate | {"\u2190\u2192"} adjust | 0-9 type | Esc close
      </text>
      <box flexDirection="column" paddingTop={1}>
        <For each={flatParams()}>
          {(item) => {
            const isFocused = createMemo(() => focusIndex() === item.index)
            const numVal = parseFloat(item.param.value ?? "0")

            return (
              <Show when={!isNaN(numVal)}>
                <text
                  fg={isFocused() ? theme.accent : theme.text}
                  bold={isFocused()}
                >
                  {isFocused() ? "\u25C6 " : "  "}
                  <span style={{ bold: true }}>{item.label.padEnd(14)}</span>
                  <Show
                    when={isFocused() && inputMode()}
                    fallback={
                      <span>{formatValue(item.param.value, item.range).padStart(10)}</span>
                    }
                  >
                    <span style={{ fg: theme.accent, bold: true }}>
                      {(inputBuffer() + "\u2588").padStart(10)}
                    </span>
                  </Show>
                  <span style={{ fg: theme.textMuted }}>
                    {"  "}{formatRange(item.range)}
                  </span>
                  <Show when={item.unit}>
                    <span style={{ fg: theme.textMuted }}> {item.unit}</span>
                  </Show>
                </text>
              </Show>
            )
          }}
        </For>
      </box>
      <Show when={flatParams().length === 0}>
        <text fg={theme.textMuted}>No tuneable parameters found</text>
      </Show>
    </box>
  )
}
