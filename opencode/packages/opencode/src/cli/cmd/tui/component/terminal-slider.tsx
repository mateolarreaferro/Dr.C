import { createSignal, createMemo } from "solid-js"
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
 * Renders: label  min [====|====] max  value unit
 *
 * Keyboard: left/right fine, shift+arrows coarse, Home/End min/max
 * Mouse: click to set position
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

  useKeyboard(
    (key) => {
      if (!isFocused()) return false

      if (key === "left") { adjustValue(-step()); return true }
      if (key === "right") { adjustValue(step()); return true }
      if (key === "S-left") { adjustValue(-coarseStep()); return true }
      if (key === "S-right") { adjustValue(coarseStep()); return true }
      if (key === "home") { props.onChange(props.min); return true }
      if (key === "end") { props.onChange(props.max); return true }

      return false
    },
  )

  const handleClick = (x: number) => {
    const effectiveLabelLen = Math.max(10, props.label.length) + 1
    const minLen = displayMin().length + 1
    const barStart = effectiveLabelLen + minLen
    const barEnd = barStart + barWidth() + 2
    if (x >= barStart && x <= barEnd) {
      const ratio = Math.max(0, Math.min(1, (x - barStart - 1) / barWidth()))
      const newVal = clamp(props.min + ratio * (props.max - props.min))
      props.onChange(newVal)
    }
    props.onFocus?.()
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
      onMouseOut={() => setHover(false)}
      onMouseUp={(evt) => handleClick(evt.x)}
    >
      <text
        fg={isFocused() ? theme.accent : theme.text}
        width={Math.max(10, props.label.length)}
        flexShrink={0}
        bold={isFocused()}
      >
        {props.label}
      </text>
      <text fg={theme.textMuted} flexShrink={0}>
        {displayMin()}
      </text>
      <text fg={isFocused() ? theme.accent : hover() ? theme.text : theme.textMuted}>
        {bar()}
      </text>
      <text fg={theme.textMuted} flexShrink={0}>
        {displayMax()}
      </text>
      <text fg={isFocused() ? theme.accent : theme.text} width={8} flexShrink={0} bold={isFocused()}>
        {" "}{displayValue()}
      </text>
      {props.unit ? <text fg={theme.textMuted}>{props.unit}</text> : null}
    </box>
  )
}
