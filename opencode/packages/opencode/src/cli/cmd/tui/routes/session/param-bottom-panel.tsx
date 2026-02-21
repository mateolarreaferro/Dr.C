import { createSignal, createMemo, createEffect, For, Show, on, onCleanup } from "solid-js"
import { createStore } from "solid-js/store"
import { useTheme } from "../../context/theme"
import { useKeyboard } from "@opentui/solid"
import { CsdParser } from "@/csound/parser"
import { ParamWriter } from "@/csound/param-writer"
import { TerminalSlider } from "../../component/terminal-slider"

interface FlatParam {
  group: string
  param: CsdParser.CsdParameter
  index: number // global index for focus tracking
}

export function ParamBottomPanel(props: {
  filePath: string | undefined
  height?: number
  visible: boolean
}) {
  const { theme } = useTheme()
  const [structure, setStructure] = createSignal<CsdParser.CsdStructure | null>(null)
  const [focusIndex, setFocusIndex] = createSignal(0)

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
      () => props.filePath,
      (fp) => {
        if (fp) parseFile(fp)
        else setStructure(null)
      },
    ),
  )

  // Poll for file changes
  createEffect(() => {
    const fp = props.filePath
    if (!fp) return
    const interval = setInterval(() => parseFile(fp), 3000)
    onCleanup(() => clearInterval(interval))
  })

  // Flatten all params into a single list for focus navigation
  const flatParams = createMemo((): FlatParam[] => {
    const s = structure()
    if (!s) return []

    const result: FlatParam[] = []
    let idx = 0

    // Global macros first
    const globalParams = s.parameters.filter(
      (p) => p.source === "define" && p.value !== undefined,
    )
    for (const p of globalParams) {
      result.push({ group: "globals", param: p, index: idx++ })
    }

    // Then by instrument
    const seen = new Set(globalParams.map((p) => p.name))
    for (const instr of s.instruments) {
      const tuneableParams = instr.parameters.filter(
        (p) => p.source !== "pfield" && p.value !== undefined && !seen.has(p.name),
      )
      for (const p of tuneableParams) {
        result.push({ group: `instr ${instr.id}`, param: p, index: idx++ })
        seen.add(p.name)
      }
    }

    return result
  })

  // Tab/Shift-Tab to cycle focus between sliders
  useKeyboard((key) => {
    if (!props.visible || flatParams().length === 0) return false

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
    if (!props.filePath) return
    await ParamWriter.updateParameter(props.filePath, param.name, value)
  }

  const getRange = (param: CsdParser.CsdParameter): [number, number] => {
    if (param.range) return param.range

    const val = parseFloat(param.value ?? "0")
    if (val === 0) return [0, 1]
    if (val > 0) return [0, val * 4]
    return [val * 4, 0]
  }

  const panelHeight = createMemo(() => props.height ?? 8)

  return (
    <Show when={props.visible && props.filePath && flatParams().length > 0}>
      <box
        borderColor={theme.border}
        border={["top"]}
        flexShrink={0}
        height={panelHeight()}
        backgroundColor={theme.backgroundPanel}
      >
        <box flexDirection="row" paddingLeft={1} paddingRight={1} backgroundColor={theme.backgroundElement}>
          <text fg={theme.text} bold>
            Parameters
          </text>
          <text fg={theme.textMuted}>
            {" "}({flatParams().length}) Tab/S-Tab to cycle, arrows to adjust
          </text>
        </box>
        <scrollbox flexGrow={1}>
          <box paddingLeft={1} paddingRight={1}>
            <For each={flatParams()}>
              {(item) => {
                const numValue = createMemo(() => parseFloat(item.param.value ?? "0"))
                const [min, max] = getRange(item.param)
                const focused = createMemo(() => focusIndex() === item.index)

                return (
                  <Show when={!isNaN(numValue())}>
                    <TerminalSlider
                      label={`${item.group}:${item.param.name}`}
                      value={numValue()}
                      min={min}
                      max={max}
                      width={40}
                      focused={focused()}
                      onFocus={() => setFocusIndex(item.index)}
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
