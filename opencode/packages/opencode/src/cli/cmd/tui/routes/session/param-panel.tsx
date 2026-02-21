import { createSignal, createMemo, createEffect, For, Show, on, onCleanup } from "solid-js"
import { createStore } from "solid-js/store"
import { useTheme } from "../../context/theme"
import { CsdParser } from "@/csound/parser"
import { ParamWriter } from "@/csound/param-writer"
import { TerminalSlider } from "../../component/terminal-slider"

interface GroupedParams {
  instrumentId: string
  instrumentDescription?: string
  params: CsdParser.CsdParameter[]
}

export function ParamPanel(props: {
  filePath: string | undefined
  width: number
}) {
  const { theme } = useTheme()
  const [structure, setStructure] = createSignal<CsdParser.CsdStructure | null>(null)
  const [collapsed, setCollapsed] = createStore<Record<string, boolean>>({})

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

  // Poll for file changes (Bus events are server-side only, not available in TUI)
  createEffect(() => {
    const fp = props.filePath
    if (!fp) return
    const interval = setInterval(() => parseFile(fp), 3000)
    onCleanup(() => clearInterval(interval))
  })

  // Group parameters by instrument
  const groups = createMemo((): GroupedParams[] => {
    const s = structure()
    if (!s) return []

    const result: GroupedParams[] = []
    const seen = new Set<string>()

    for (const instr of s.instruments) {
      // Filter to only tuneable parameters (skip pfield references)
      const tuneableParams = instr.parameters.filter(
        (p) => p.source !== "pfield" && p.value !== undefined,
      )

      if (tuneableParams.length > 0) {
        result.push({
          instrumentId: instr.id,
          instrumentDescription: instr.description,
          params: tuneableParams,
        })
        for (const p of tuneableParams) seen.add(p.name)
      }
    }

    // Add top-level params (macros that weren't in instruments)
    const globalParams = s.parameters.filter(
      (p) => !seen.has(p.name) && p.source === "define" && p.value !== undefined,
    )
    if (globalParams.length > 0) {
      result.unshift({
        instrumentId: "globals",
        instrumentDescription: "Global Macros",
        params: globalParams,
      })
    }

    return result
  })

  const handleChange = async (param: CsdParser.CsdParameter, value: number) => {
    if (!props.filePath) return
    await ParamWriter.updateParameter(props.filePath, param.name, value)
  }

  const getRange = (param: CsdParser.CsdParameter): [number, number] => {
    if (param.range) return param.range

    // Infer range from value
    const val = parseFloat(param.value ?? "0")
    if (val === 0) return [0, 1]
    if (val > 0) return [0, val * 4]
    return [val * 4, 0]
  }

  return (
    <Show when={props.filePath && groups().length > 0}>
      <box
        flexDirection="column"
        paddingLeft={1}
        paddingRight={1}
        backgroundColor={theme.backgroundPanel}
        width={props.width}
      >
        <text fg={theme.text}>
          <b>Parameters</b>
        </text>
        <For each={groups()}>
          {(group) => (
            <box flexDirection="column">
              <box
                flexDirection="row"
                gap={1}
                onMouseDown={() => setCollapsed(group.instrumentId, !collapsed[group.instrumentId])}
              >
                <text fg={theme.text}>
                  {collapsed[group.instrumentId] ? "\u25B6" : "\u25BC"}
                </text>
                <text fg={theme.text}>
                  <b>instr {group.instrumentId}</b>
                  <Show when={group.instrumentDescription}>
                    <span style={{ fg: theme.textMuted }}> {group.instrumentDescription}</span>
                  </Show>
                </text>
              </box>
              <Show when={!collapsed[group.instrumentId]}>
                <For each={group.params}>
                  {(param) => {
                    const numValue = createMemo(() => parseFloat(param.value ?? "0"))
                    const [min, max] = getRange(param)

                    return (
                      <Show when={!isNaN(numValue())}>
                        <TerminalSlider
                          label={param.name}
                          value={numValue()}
                          min={min}
                          max={max}
                          width={Math.max(16, props.width - 20)}
                          onChange={(v) => handleChange(param, v)}
                        />
                      </Show>
                    )
                  }}
                </For>
              </Show>
            </box>
          )}
        </For>
      </box>
    </Show>
  )
}
