import { createSignal, createMemo, createEffect, Show, For, on, onCleanup } from "solid-js"
import { useTheme } from "../../context/theme"
import { useSync } from "@tui/context/sync"
import { useKV } from "../../context/kv"
import { CsdParser } from "@/csound/parser"
import { ParamPanel } from "./param-panel"
import { spawn } from "child_process"
import path from "path"
import { SessionWorkspace } from "@/session/workspace"
import { WavReader } from "@/util/wav-reader"
import { WaveformDisplay } from "../../component/waveform-display"

export function CsdPanel(props: { filePath: string | undefined; width: number; sessionID?: string; refreshTrigger?: () => number }) {
  const { theme } = useTheme()
  const kv = useKV()
  const sync = useSync()

  const [content, setContent] = createSignal("")
  const [compileStatus, setCompileStatus] = createSignal<"unknown" | "ok" | "error">("unknown")
  const [snapshotHash, setSnapshotHash] = createSignal<string | undefined>()
  const [lastModifiedSection, setLastModifiedSection] = createSignal<string | undefined>()
  const [paramPanelVisible, setParamPanelVisible] = kv.signal("param_panel_visible", true)
  const [renderState, setRenderState] = createSignal<"idle" | "rendering">("idle")
  const [renderElapsed, setRenderElapsed] = createSignal(0)
  const [renderStartTime, setRenderStartTime] = createSignal<number | null>(null)

  // Resolve file path through workspace (reads workspace copy when active)
  const resolvedFilePath = createMemo(() => {
    const fp = props.filePath
    if (!fp || !props.sessionID) return fp
    return SessionWorkspace.resolve(props.sessionID, fp)
  })

  // Track render progress
  createEffect(() => {
    const sid = props.sessionID
    if (!sid) return
    const messages = sync.data.message[sid] ?? []
    for (let i = messages.length - 1; i >= 0; i--) {
      const msg = messages[i]
      const parts = sync.data.part[msg.id] ?? []
      for (const part of parts) {
        if (part.type === "tool" && part.tool === "csound_render") {
          if (part.state.status === "running") {
            if (renderState() !== "rendering") {
              setRenderState("rendering")
              setRenderStartTime(Date.now())
            }
            return
          }
          if (part.state.status === "completed") {
            setRenderState("idle")
            setRenderStartTime(null)
            return
          }
        }
      }
    }
    setRenderState("idle")
  })

  // Elapsed time counter during render
  createEffect(() => {
    if (renderState() === "rendering") {
      const interval = setInterval(() => {
        const start = renderStartTime()
        if (start) setRenderElapsed(Math.floor((Date.now() - start) / 1000))
      }, 500)
      onCleanup(() => clearInterval(interval))
    } else {
      setRenderElapsed(0)
    }
  })

  // Track compile status from tool calls
  createEffect(() => {
    const sid = props.sessionID
    if (!sid) return
    const messages = sync.data.message[sid] ?? []
    for (let i = messages.length - 1; i >= 0; i--) {
      const msg = messages[i]
      const parts = sync.data.part[msg.id] ?? []
      for (const part of parts) {
        if (part.type === "tool" && part.tool === "csound_compile" && part.state.status === "completed") {
          const metadata = (part.state as any).metadata
          if (metadata?.exitCode === 0) {
            setCompileStatus("ok")
          } else if (metadata?.exitCode !== undefined) {
            setCompileStatus("error")
          }
          return
        }
      }
    }
  })

  // Load CSD content
  const loadContent = async (fp: string) => {
    try {
      const text = await Bun.file(fp).text()
      setContent(text)
    } catch {
      setContent("")
    }
  }

  // Reload when filePath changes, new messages arrive, or refreshTrigger fires
  createEffect(() => {
    const fp = resolvedFilePath()
    if (!fp) {
      setContent("")
      return
    }
    // Track message count changes to detect file modifications by tools
    const sid = props.sessionID
    if (sid) {
      const messages = sync.data.message[sid] ?? []
      messages.length // reactive dependency
    }
    // React to external refresh trigger (e.g. tree navigation)
    if (props.refreshTrigger) props.refreshTrigger()
    loadContent(fp)
    // Poll for external file changes (Bus events are server-side only)
    const interval = setInterval(() => loadContent(fp), 3000)
    onCleanup(() => clearInterval(interval))
  })

  // Parse structure
  const structure = createMemo(() => {
    const c = content()
    if (!c) return null
    try {
      return CsdParser.parse(c)
    } catch {
      return null
    }
  })

  const lines = createMemo(() => content().split("\n"))
  const instrumentCount = createMemo(() => structure()?.instruments.length ?? 0)
  const paramCount = createMemo(() => structure()?.parameters.length ?? 0)

  const displayPath = createMemo(() => {
    const fp = props.filePath
    if (!fp) return ""
    if (path.isAbsolute(fp)) return path.relative(process.cwd(), fp) || path.basename(fp)
    return fp
  })

  const shortHash = createMemo(() => {
    const h = snapshotHash()
    return h ? h.slice(0, 8) : ""
  })

  // Waveform state
  const [wavInfo, setWavInfo] = createSignal<WavReader.WavInfo | null>(null)

  // Load WAV waveform when file exists or changes
  createEffect(() => {
    const fp = resolvedFilePath()
    if (!fp) {
      setWavInfo(null)
      return
    }
    const wavPath = fp.replace(".csd", ".wav")
    // React to message count changes (re-read after render)
    const sid = props.sessionID
    if (sid) {
      const messages = sync.data.message[sid] ?? []
      messages.length // reactive dep
    }
    if (props.refreshTrigger) props.refreshTrigger()

    const loadWav = async () => {
      const info = await WavReader.read(wavPath, Math.max(20, props.width - 16))
      setWavInfo(info)
    }
    loadWav()
  })

  const [playing, setPlaying] = createSignal(false)
  const [playHover, setPlayHover] = createSignal(false)

  const statusIcon = createMemo(() => {
    switch (compileStatus()) {
      case "ok":
        return { char: "\u2713", color: theme.success }
      case "error":
        return { char: "\u2717", color: theme.error }
      default:
        return { char: "\u2022", color: theme.textMuted }
    }
  })

  const playAudio = (audioPath: string) => {
    const player = process.platform === "darwin" ? "afplay" : "aplay"
    const playProc = spawn(player, [audioPath], { stdio: "ignore", detached: true })
    playProc.unref()
    playProc.once("exit", () => setPlaying(false))
    playProc.once("error", () => setPlaying(false))
    // Safety timeout for playback
    const timer = setTimeout(() => {
      try { playProc.kill("SIGTERM") } catch {}
    }, 30000)
    playProc.once("exit", () => clearTimeout(timer))
  }

  const handlePlay = async () => {
    const fp = resolvedFilePath()
    if (!fp || playing()) return
    setPlaying(true)

    const outputPath = fp.replace(".csd", ".wav")

    // If WAV already exists, just play it directly
    try {
      const wavFile = Bun.file(outputPath)
      if (await wavFile.exists()) {
        playAudio(outputPath)
        return
      }
    } catch {}

    // Otherwise render first, then play
    try {
      const proc = spawn("csound", ["-W", "-d", "-m0", "-o", outputPath, fp], {
        stdio: ["ignore", "pipe", "pipe"],
        detached: process.platform !== "win32",
      })

      proc.once("exit", (code) => {
        if (code === 0 || code === null) {
          playAudio(outputPath)
        } else {
          setPlaying(false)
        }
      })

      proc.once("error", () => setPlaying(false))

      // Timeout safety for render
      const timer = setTimeout(() => {
        try {
          if (proc.pid && process.platform !== "win32") process.kill(-proc.pid, "SIGTERM")
          else proc.kill("SIGTERM")
        } catch {}
      }, 15000)
      proc.once("exit", () => clearTimeout(timer))
    } catch {
      setPlaying(false)
    }
  }

  return (
    <Show when={props.filePath}>
      <box
        width={props.width}
        flexDirection="column"
        height="100%"
        backgroundColor={theme.backgroundPanel}
      >
        {/* Header */}
        <box
          flexShrink={0}
          paddingLeft={1}
          paddingRight={1}
          flexDirection="row"
          justifyContent="space-between"
          backgroundColor={theme.backgroundElement}
        >
          <text fg={theme.text} wrapMode="none">
            <span style={{ fg: statusIcon().color }}>{statusIcon().char}</span>{" "}
            {displayPath()}
            <Show when={props.sessionID && SessionWorkspace.status(props.sessionID).unsavedChanges}>
              <span style={{ fg: theme.warning, bold: true }}> DRAFT</span>
            </Show>
          </text>
          <text
            fg={playHover() ? (playing() ? theme.error : theme.accent) : (renderState() === "rendering" ? theme.warning : theme.textMuted)}
            onMouseOver={() => setPlayHover(true)}
            onMouseOut={() => setPlayHover(false)}
            onMouseUp={handlePlay}
            flexShrink={0}
          >
            {renderState() === "rendering"
              ? `\u25A0 rendering ${renderElapsed()}s`
              : playing()
                ? "\u25A0 playing..."
                : "\u25B6 play"}
          </text>
        </box>

        {/* Code view */}
        <scrollbox flexGrow={1}>
          <box paddingLeft={1} paddingRight={1}>
            <For each={lines()}>
              {(line, index) => {
                const lineNum = index() + 1
                const isSectionTag = createMemo(() =>
                  /^<\/?(?:CsoundSynthesizer|CsOptions|CsInstruments|CsScore|Cabbage)>/.test(line.trim()),
                )
                const isComment = createMemo(() => line.trim().startsWith(";"))
                const isGlobal = createMemo(() => /^(?:sr|ksmps|nchnls|0dbfs)\s*=/.test(line.trim()))
                const isInstrBoundary = createMemo(() => /^(?:instr|endin)\b/.test(line.trim()))

                const fg = createMemo(() => {
                  if (isSectionTag()) return theme.primary
                  if (isComment()) return theme.textMuted
                  if (isGlobal()) return theme.warning
                  if (isInstrBoundary()) return theme.accent
                  return theme.text
                })

                return (
                  <box flexDirection="row">
                    <text fg={theme.textMuted} width={4} flexShrink={0}>
                      {String(lineNum).padStart(3, " ")}
                    </text>
                    <text fg={fg()} wrapMode="none">
                      {line || " "}
                    </text>
                  </box>
                )
              }}
            </For>
          </box>
        </scrollbox>

        {/* Waveform */}
        <Show when={wavInfo()}>
          <box flexShrink={0} paddingLeft={1} paddingRight={1}>
            <WaveformDisplay
              peaks={wavInfo()!.peaks}
              duration={wavInfo()!.duration}
              peakDb={wavInfo()!.peakDb}
              width={props.width - 2}
            />
          </box>
        </Show>

        {/* Footer */}
        <box
          flexShrink={0}
          paddingLeft={1}
          paddingRight={1}
          flexDirection="row"
          justifyContent="space-between"
          backgroundColor={theme.backgroundElement}
        >
          <text fg={theme.textMuted}>
            {instrumentCount()} instr
          </text>
          <text
            fg={theme.textMuted}
            onMouseDown={() => setParamPanelVisible((prev) => !prev)}
          >
            {paramCount()} params {paramPanelVisible() ? "\u25BC" : "\u25B6"}
          </text>
          <text fg={theme.textMuted}>
            {lines().length} lines
          </text>
        </box>
      </box>
    </Show>
  )
}

export function CsdPanelBorder() {
  const { theme } = useTheme()
  return (
    <box width={1} height="100%" backgroundColor={theme.background}>
      <text fg={theme.border}>{"\u2502".repeat(200)}</text>
    </box>
  )
}
