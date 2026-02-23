import { createSignal, createMemo, createEffect, For, Show, on, onCleanup } from "solid-js"
import { useTheme } from "../../context/theme"
import { useKeyboard } from "@opentui/solid"
import { CsdParser } from "@/csound/parser"
import { ParamWriter } from "@/csound/param-writer"
import { SessionWorkspace } from "@/session/workspace"
import { TerminalSlider } from "../../component/terminal-slider"

interface FlatParam {
  group: string
  label: string
  param: CsdParser.CsdParameter
  index: number
  range: [number, number]
  unit: string
}

/** Strip rate prefix (i/k/a/S) and capitalize: iFreq → Freq, kCutoff → Cutoff */
function cleanParamName(name: string): string {
  if (/^[ikaS][A-Z]/.test(name)) return name.slice(1)
  return name
}

/** Infer a sensible range from the parameter name and current value */
function inferRange(param: CsdParser.CsdParameter): [number, number] {
  // If the parser already set a real range (varying pfield, widget, etc.), use it
  if (param.range && param.range[0] !== param.range[1]) return param.range

  const val = parseFloat(param.value ?? "0")
  const name = param.name.toLowerCase()

  if (/freq/.test(name)) return [20, Math.max(val * 4, 2000)]
  if (/amp|gain|level|vol/.test(name)) return [0, 1]
  if (/pan/.test(name)) return [-1, 1]
  if (/decay|attack|release|sustain/.test(name)) return [0, Math.max(val * 4, 10)]
  if (/cutoff/.test(name)) return [20, 20000]
  if (/res/.test(name)) return [0, 1]
  if (/ratio/.test(name)) return [0, Math.max(val * 4, 20)]
  if (/depth|width|mix|feedback/.test(name)) return [0, 1]
  if (/rate/.test(name)) return [0, Math.max(val * 4, 20)]

  if (val === 0) return [0, 1]
  if (val > 0) return [0, val * 4]
  return [val * 4, 0]
}

/** Infer unit label from parameter name */
function inferUnit(name: string): string {
  const n = name.toLowerCase()
  if (/freq|cutoff/.test(n)) return "Hz"
  if (/time|decay|attack|release|sustain|del/.test(n)) return "s"
  if (/amp|gain|level|vol|depth|mix|feedback|width/.test(n)) return ""
  if (/pan/.test(n)) return ""
  if (/rate/.test(n)) return "Hz"
  return ""
}

export function ParamBottomPanel(props: {
  filePath: string | undefined
  sessionID?: string
  height?: number
  visible: boolean
  panelFocused?: boolean
  onPanelFocus?: () => void
  onPanelBlur?: () => void
  availableWidth?: number
  onParamChange?: () => void
}) {
  const { theme } = useTheme()
  const [structure, setStructure] = createSignal<CsdParser.CsdStructure | null>(null)
  const [focusIndex, setFocusIndex] = createSignal(0)

  // Resolve file path through workspace when active
  const resolvedFilePath = createMemo(() => {
    const fp = props.filePath
    if (!fp || !props.sessionID) return fp
    return SessionWorkspace.resolve(props.sessionID, fp)
  })

  // Parse CSD
  const parseFile = async (fp: string) => {
    try {
      const content = await Bun.file(fp).text()
      setStructure(CsdParser.parse(content))
    } catch {
      setStructure(null)
    }
  }

  createEffect(
    on(
      () => resolvedFilePath(),
      (fp) => {
        if (fp) parseFile(fp)
        else setStructure(null)
      },
    ),
  )

  // Poll for file changes
  createEffect(() => {
    const fp = resolvedFilePath()
    if (!fp) return
    const interval = setInterval(() => parseFile(fp), 3000)
    onCleanup(() => clearInterval(interval))
  })

  // Flatten all params into a single list with pre-computed labels and ranges
  const flatParams = createMemo((): FlatParam[] => {
    const s = structure()
    if (!s) return []

    const result: FlatParam[] = []
    let idx = 0
    const multipleInstruments = s.instruments.length > 1

    // Global macros first
    const globalParams = s.parameters.filter(
      (p) => p.source === "define" && p.value !== undefined,
    )
    for (const p of globalParams) {
      result.push({
        group: "global",
        label: p.name,
        param: p,
        index: idx++,
        range: inferRange(p),
        unit: inferUnit(p.name),
      })
    }

    // Then by instrument
    const seen = new Set(globalParams.map((p) => p.name))
    for (const instr of s.instruments) {
      const tuneableParams = instr.parameters.filter(
        (p) => p.value !== undefined
          && !seen.has(p.name)
          && !isNaN(parseFloat(p.value!))
          && !(p as any).pfieldVaries,
      )
      for (const p of tuneableParams) {
        const clean = cleanParamName(p.name)
        const label = multipleInstruments ? `${instr.id}:${clean}` : clean
        result.push({
          group: `instr ${instr.id}`,
          label,
          param: p,
          index: idx++,
          range: inferRange(p),
          unit: inferUnit(p.name),
        })
        seen.add(p.name)
      }
    }

    return result
  })

  // Tab/Shift-Tab to cycle focus, Escape to blur panel
  useKeyboard((key) => {
    if (!props.visible || flatParams().length === 0) return false
    if (!props.panelFocused) return false

    if (key === "escape") {
      props.onPanelBlur?.()
      return true
    }
    if (key === "tab") {
      setFocusIndex((prev) => (prev + 1) % flatParams().length)
      return true
    }
    if (key === "S-tab") {
      setFocusIndex((prev) => (prev - 1 + flatParams().length) % flatParams().length)
      return true
    }

    return false
  })

  const handleChange = async (param: CsdParser.CsdParameter, value: number) => {
    const fp = resolvedFilePath()
    if (!fp) return

    if (param.source === "pfield" && (param as any).pfieldNum) {
      await ParamWriter.updateScorePfield(fp, param.instrument!, (param as any).pfieldNum, value)
    } else {
      await ParamWriter.updateParameter(fp, param.name, value)
    }
    // Re-parse immediately to update slider display
    parseFile(fp)
    props.onParamChange?.()
  }

  // Responsive slider bar width: use available terminal width minus space for labels/values
  const sliderWidth = createMemo(() => Math.max(20, (props.availableWidth ?? 60) - 30))

  // Dynamic height
  const maxHeight = createMemo(() => props.height ?? 14)
  const panelHeight = createMemo(() => {
    const paramCount = flatParams().length
    const needed = paramCount + 2
    return Math.max(4, Math.min(needed, maxHeight()))
  })

  return (
    <Show when={props.visible && props.filePath && flatParams().length > 0}>
      <box
        borderColor={props.panelFocused ? theme.accent : theme.border}
        border={["top"]}
        flexShrink={0}
        height={panelHeight()}
        backgroundColor={theme.backgroundPanel}
      >
        <box flexDirection="row" paddingLeft={1} paddingRight={1} backgroundColor={theme.backgroundElement} flexShrink={0}>
          <text fg={props.panelFocused ? theme.accent : theme.text} bold>
            Parameters
          </text>
          <text fg={theme.textMuted}>
            {" "}({flatParams().length})
          </text>
          <Show when={props.panelFocused}>
            <text fg={theme.accent} bold> [editing]</text>
          </Show>
          <text fg={theme.textMuted}>
            {"  "}{props.panelFocused ? "←→ adjust | Tab next | Esc done" : "click to edit"}
          </text>
        </box>
        <scrollbox flexGrow={1}>
          <box paddingLeft={1} paddingRight={1} onMouseDown={() => props.onPanelFocus?.()}>
            <For each={flatParams()}>
              {(item) => {
                const numValue = createMemo(() => parseFloat(item.param.value ?? "0"))
                const focused = createMemo(() => !!(props.panelFocused && focusIndex() === item.index))

                return (
                  <Show when={!isNaN(numValue())}>
                    <TerminalSlider
                      label={item.label}
                      value={numValue()}
                      min={item.range[0]}
                      max={item.range[1]}
                      unit={item.unit}
                      width={sliderWidth()}
                      focused={focused()}
                      onFocus={() => {
                        setFocusIndex(item.index)
                        if (!props.panelFocused) props.onPanelFocus?.()
                      }}
                      onChange={(v) => handleChange(item.param, v)}
                    />
                  </Show>
                )
              }}
            </For>
          </box>
        </scrollbox>
      </box>
    </Show>
  )
}
