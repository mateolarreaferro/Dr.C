import { createMemo } from "solid-js"
import { useTheme } from "../context/theme"

const BLOCK_CHARS = " \u2581\u2582\u2583\u2584\u2585\u2586\u2587\u2588"

export function WaveformDisplay(props: {
  peaks: number[]
  duration: number
  peakDb: number
  width?: number
}) {
  const { theme } = useTheme()

  const waveform = createMemo(() => {
    const peaks = props.peaks
    if (peaks.length === 0) return ""

    // Normalize peaks to [0, 1] relative to max
    const maxPeak = Math.max(...peaks, 0.001)
    return peaks
      .map((p) => {
        const normalized = p / maxPeak
        const idx = Math.round(normalized * (BLOCK_CHARS.length - 1))
        return BLOCK_CHARS[idx]
      })
      .join("")
  })

  const color = createMemo(() => {
    const db = props.peakDb
    if (db > -1) return theme.error      // clipping
    if (db > -3) return theme.warning     // hot
    return theme.success                   // normal
  })

  const durationLabel = createMemo(() => {
    const d = props.duration
    if (d < 1) return `${(d * 1000).toFixed(0)}ms`
    return `${d.toFixed(1)}s`
  })

  const dbLabel = createMemo(() => {
    const db = props.peakDb
    if (db <= -100) return "-inf dB"
    return `${db.toFixed(1)}dB`
  })

  return (
    <box flexDirection="row" flexShrink={0}>
      <text fg={theme.textMuted} flexShrink={0}>
        {durationLabel()}{" "}
      </text>
      <text fg={color()} flexGrow={1} wrapMode="none">
        {waveform()}
      </text>
      <text fg={theme.textMuted} flexShrink={0}>
        {" "}{dbLabel()}
      </text>
    </box>
  )
}
