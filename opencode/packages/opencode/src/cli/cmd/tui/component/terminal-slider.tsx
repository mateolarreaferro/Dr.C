import { createSignal, createMemo, Show } from "solid-js"
import { useTheme } from "../context/theme"
import { useKeyboard } from "@opentui/solid"

/** Format a number compactly for display */
function fmtNum(v: number): string {
  if (Number.isInteger(v)) return v.toString()
  if (Math.abs(v) >= 1000) return v.toFixed(0)
  if (Math.abs(v) >= 100) return v.toFixed(0)
  if (Math.abs(v) >= 10) return v.toFixed(1)
  if (Math.abs(v) >= 1) return v.toFixed(2)
  return v.toFixed(3)
}

/**
 * Text-mode slider for terminal UI.
 *
 * Renders: label  value  min [====|====] max  unit
 *
 * Keyboard:
 *   Left/Right   — fine step
 *   Shift+arrows — coarse step
 *   Home/End     — min/max
 *   Enter        — type an exact value (number input mode)
 *   0-9 / . / -  — start typing immediately
 * Mouse: click/drag to set position
 */
export function TerminalSlider(props: {
  label: string
  value: number
  min: number
  max: number
  step?: number
  coarseStep?: number
  unit?: string
  width?: number
  focused?: boolean
  onFocus?: () => void
  onBlur?: () => void
  onChange: (value: number) => void
}) {
  const { theme } = useTheme()
  const [hover, setHover] = createSignal(false)
  const [dragging, setDragging] = createSignal(false)

  // Number input mode
  const [inputMode, setInputMode] = createSignal(false)
  const [inputBuffer, setInputBuffer] = createSignal("")

  const isFocused = createMemo(() => props.focused ?? false)

  const step = createMemo(() => props.step ?? (props.max - props.min) / 100)
  const coarseStep = createMemo(() => props.coarseStep ?? step() * 10)
  const barWidth = createMemo(() => (props.width ?? 20) - 2) // minus brackets

  const normalizedPosition = createMemo(() => {
    const range = props.max - props.min
    if (range === 0) return 0.5
    return Math.max(0, Math.min(1, (props.value - props.min) / range))
  })

  const filledWidth = createMemo(() => Math.round(normalizedPosition() * barWidth()))
  const emptyWidth = createMemo(() => barWidth() - filledWidth())

  const displayValue = createMemo(() => fmtNum(props.value))
  const displayMin = createMemo(() => fmtNum(props.min))
  const displayMax = createMemo(() => fmtNum(props.max))

  const clamp = (val: number) => Math.max(props.min, Math.min(props.max, val))

  const adjustValue = (delta: number) => {
    const newVal = clamp(props.value + delta)
    props.onChange(newVal)
  }

  const enterInputMode = (initial?: string) => {
    setInputMode(true)
    setInputBuffer(initial ?? "")
  }

  const confirmInput = () => {
    const text = inputBuffer().trim()
    setInputMode(false)
    setInputBuffer("")
    if (text === "") return
    const parsed = parseFloat(text)
    if (!isNaN(parsed)) {
      props.onChange(clamp(parsed))
    }
  }

  const cancelInput = () => {
    setInputMode(false)
    setInputBuffer("")
  }

  useKeyboard((evt) => {
    if (!isFocused()) return

    // Number input mode: capture all keys for editing
    if (inputMode()) {
      if (evt.name === "return") {
        confirmInput()
        evt.preventDefault()
        return
      }
      if (evt.name === "escape") {
        cancelInput()
        evt.preventDefault()
        return
      }
      if (evt.name === "backspace") {
        setInputBuffer((b) => b.slice(0, -1))
        evt.preventDefault()
        return
      }
      // Allow typing digits, decimal point, minus
      if (/^[0-9.\-]$/.test(evt.name)) {
        setInputBuffer((b) => b + evt.name)
        evt.preventDefault()
        return
      }
      evt.preventDefault()
      return // consume all keys in input mode
    }

    // Normal slider mode — check shift variants first
    if (evt.shift && evt.name === "left") {
      adjustValue(-coarseStep())
      evt.preventDefault()
      return
    }
    if (evt.shift && evt.name === "right") {
      adjustValue(coarseStep())
      evt.preventDefault()
      return
    }
    if (evt.name === "left") {
      adjustValue(-step())
      evt.preventDefault()
      return
    }
    if (evt.name === "right") {
      adjustValue(step())
      evt.preventDefault()
      return
    }
    if (evt.name === "home") {
      props.onChange(props.min)
      evt.preventDefault()
      return
    }
    if (evt.name === "end") {
      props.onChange(props.max)
      evt.preventDefault()
      return
    }

    // Enter: open number input with current value pre-filled
    if (evt.name === "return") {
      enterInputMode(fmtNum(props.value))
      evt.preventDefault()
      return
    }

    // Typing a digit/dot/minus starts input mode immediately
    if (/^[0-9.\-]$/.test(evt.name)) {
      enterInputMode(evt.name)
      evt.preventDefault()
      return
    }
  })

  const handleMousePosition = (x: number) => {
    if (inputMode()) return // don't move slider while typing
    const effectiveLabelLen = Math.max(10, props.label.length) + 1
    const valueLen = 9 // value display width + gap
    const minLen = displayMin().length + 1
    const barStart = effectiveLabelLen + valueLen + minLen
    const barEnd = barStart + barWidth() + 2
    if (x >= barStart && x <= barEnd) {
      const ratio = Math.max(0, Math.min(1, (x - barStart - 1) / barWidth()))
      const newVal = clamp(props.min + ratio * (props.max - props.min))
      props.onChange(newVal)
    }
  }

  const handleMouseDown = (x: number) => {
    if (inputMode()) return
    setDragging(true)
    handleMousePosition(x)
    props.onFocus?.()
  }

  const handleMouseMove = (x: number) => {
    if (dragging()) {
      handleMousePosition(x)
    }
  }

  const handleMouseUp = (x: number) => {
    if (dragging()) {
      handleMousePosition(x)
      setDragging(false)
    }
  }

  const bar = createMemo(() => {
    const filled = "\u2588".repeat(filledWidth())
    const handle = isFocused() ? "\u2503" : "\u2502"
    const empty = "\u2500".repeat(Math.max(0, emptyWidth()))
    return `[${filled}${handle}${empty}]`
  })

  return (
    <box
      flexDirection="row"
      gap={1}
      onMouseOver={() => setHover(true)}
      onMouseOut={() => { setHover(false); setDragging(false) }}
      onMouseDown={(evt: any) => handleMouseDown(evt.x)}
      onMouseMove={(evt: any) => handleMouseMove(evt.x)}
      onMouseUp={(evt: any) => handleMouseUp(evt.x)}
    >
      <text
        fg={isFocused() ? theme.accent : theme.text}
        width={Math.max(10, props.label.length)}
        flexShrink={0}
        bold={isFocused()}
      >
        {props.label}
      </text>
      {/* Value display — shows input field when typing, otherwise current value */}
      <Show when={inputMode()} fallback={
        <text
          fg={isFocused() ? theme.accent : theme.text}
          width={8}
          flexShrink={0}
          bold={isFocused()}
        >
          {displayValue()}
        </text>
      }>
        <text
          fg={theme.accent}
          width={8}
          flexShrink={0}
          bold
        >
          {inputBuffer() + "\u2588"}
        </text>
      </Show>
      <text fg={theme.textMuted} flexShrink={0}>
        {displayMin()}
      </text>
      <text fg={inputMode() ? theme.textMuted : isFocused() ? theme.accent : hover() ? theme.text : theme.textMuted}>
        {bar()}
      </text>
      <text fg={theme.textMuted} flexShrink={0}>
        {displayMax()}
      </text>
      {props.unit ? <text fg={theme.textMuted}> {props.unit}</text> : null}
    </box>
  )
}
