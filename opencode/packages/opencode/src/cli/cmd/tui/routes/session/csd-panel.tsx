import { createSignal, createMemo, createEffect, Show, For, on, onCleanup } from "solid-js"
import { useTheme } from "../../context/theme"
import { useSync } from "@tui/context/sync"
import { useKV } from "../../context/kv"
import { useToast } from "../../ui/toast"
import { CsdParser } from "@/csound/parser"
import { spawn } from "child_process"
import path from "path"
import crypto from "crypto"
import fs from "fs/promises"
import { SessionWorkspace } from "@/session/workspace"
import { WavReader } from "@/util/wav-reader"
import { WaveformDisplay } from "../../component/waveform-display"
import { CsoundProcessRegistry } from "@/csound/process-registry"
import { SignalFlow } from "@/csound/signal-flow"
import { SignalFlowDiagram } from "../../component/signal-flow-diagram"
import { generateCsoundHTML } from "@/tool/csound_export_html_template"
import { ExternalApps } from "@/util/external-apps"
import { CsdSnapshot } from "@/validation/snapshot"
import { computeCsdChanges } from "../../component/csd-change-summary"
import { Global } from "@/global"

// ---------------------------------------------------------------------------
// Version history types & helpers
// ---------------------------------------------------------------------------

interface CsdVersion {
  id: string
  description: string
  snapshotHash: string
  timestamp: number
  changeSummary?: string
  csdBasename: string       // which file this version belongs to
  resolvedPath?: string     // workspace-resolved path for restore
}

interface VersionHistory {
  sessionID: string
  versions: CsdVersion[]
  currentVersionId: string
}

const HISTORY_DIR = path.join(Global.Path.data, "version-history")

function generateVersionID(): string {
  return `v_${Date.now().toString(36)}_${crypto.randomBytes(4).toString("hex")}`
}

function historyPath(sessionID: string): string {
  return path.join(HISTORY_DIR, `${Buffer.from(sessionID).toString("base64url")}.json`)
}

async function loadHistory(sessionID: string): Promise<VersionHistory | null> {
  try {
    const fp = historyPath(sessionID)
    const file = Bun.file(fp)
    if (!(await file.exists())) return null
    return (await file.json()) as VersionHistory
  } catch {
    return null
  }
}

async function saveHistory(history: VersionHistory): Promise<void> {
  await fs.mkdir(HISTORY_DIR, { recursive: true })
  const fp = historyPath(history.sessionID)
  await Bun.write(fp, JSON.stringify(history, null, 2))
}

function contentHashFn(c: string): string {
  return crypto.createHash("sha256").update(c).digest("hex").slice(0, 16)
}

function embedPromptInCsd(content: string, prompt: string): string {
  const cleaned = content.replace(/; Prompt:.*(?:\n;         .*)*\n?/, "")
  const words = prompt.replace(/\n/g, " ").split(/\s+/).filter(Boolean)
  const lines: string[] = []
  let current = ""
  for (const word of words) {
    if (current.length + word.length + 1 > 76) {
      lines.push(current)
      current = word
    } else {
      current = current ? current + " " + word : word
    }
  }
  if (current) lines.push(current)
  if (lines.length === 0) return cleaned
  const block = lines
    .map((l, i) => (i === 0 ? `; Prompt: ${l}` : `;         ${l}`))
    .join("\n")
  return cleaned.replace(
    "<CsoundSynthesizer>\n",
    `<CsoundSynthesizer>\n${block}\n`,
  )
}

// ---------------------------------------------------------------------------
// Version History Panel — standalone component for the left column
// ---------------------------------------------------------------------------

export function VersionHistoryPanel(props: {
  csdFilePath: string | undefined
  sessionID: string
  onVersionSelect?: () => void
}) {
  const { theme } = useTheme()
  const sync = useSync()

  const [history, setHistory] = createSignal<VersionHistory | null>(null)
  const [lastContentHash, setLastContentHash] = createSignal<string | undefined>()
  const [lastTrackedBasename, setLastTrackedBasename] = createSignal<string | undefined>()
  const [lastVersionUserCount, setLastVersionUserCount] = createSignal<number>(0)
  const [lastVersionId, setLastVersionId] = createSignal<string | undefined>()

  const messages = createMemo(() => sync.data.message[props.sessionID] ?? [])
  const userMsgCount = createMemo(() => messages().filter((m: any) => m.role === "user").length)

  const resolvedCsdPath = createMemo(() => {
    const fp = props.csdFilePath
    if (!fp) return undefined
    return SessionWorkspace.resolve(props.sessionID, fp)
  })

  const latestUserText = createMemo(() => {
    const msgs = messages()
    for (let i = msgs.length - 1; i >= 0; i--) {
      const msg = msgs[i]
      if ((msg as any).role !== "user") continue
      const parts = sync.data.part[msg.id] ?? []
      for (const part of parts) {
        if (part.type === "text" && !part.synthetic && (part as any).text?.trim()) {
          const text = (part as any).text.trim()
          return text.length > 40 ? text.slice(0, 37) + "..." : text
        }
      }
    }
    return undefined
  })

  const autoPopulate = async () => {
    const fp = props.csdFilePath
    const rfp = resolvedCsdPath()
    if (!fp || !rfp) return

    const basename = path.basename(fp)
    let fileContent: string
    try {
      fileContent = await Bun.file(rfp).text()
    } catch {
      return
    }

    const hash = contentHashFn(fileContent)
    const fileChanged = basename !== lastTrackedBasename()
    if (hash === lastContentHash() && !fileChanged) return
    setLastContentHash(hash)
    setLastTrackedBasename(basename)

    let snapHash: string
    try {
      snapHash = await CsdSnapshot.capture(rfp, props.sessionID)
    } catch {
      snapHash = hash
    }

    // Load session-scoped history
    let h = await loadHistory(props.sessionID)
    if (!h) {
      const id = generateVersionID()
      h = {
        sessionID: props.sessionID,
        versions: [{ id, description: "Initial CSD", snapshotHash: snapHash, timestamp: Date.now(), csdBasename: basename, resolvedPath: rfp }],
        currentVersionId: id,
      }
      setLastVersionId(id)
      setLastVersionUserCount(userMsgCount())
      await saveHistory(h)
      setHistory(h)
      return
    }

    const latest = h.versions[h.versions.length - 1]

    // If file changed to a different CSD, always create a new version
    if (fileChanged && latest && latest.csdBasename !== basename) {
      const id = generateVersionID()
      const description = latestUserText() ?? basename.replace(".csd", "")
      h.versions.push({ id, description, snapshotHash: snapHash, timestamp: Date.now(), csdBasename: basename, resolvedPath: rfp })
      h.currentVersionId = id
      setLastVersionId(id)
      setLastVersionUserCount(userMsgCount())
      await saveHistory(h)
      setHistory({ ...h })
      return
    }

    if (latest && latest.snapshotHash === snapHash) {
      h.currentVersionId = latest.id
      await saveHistory(h)
      setHistory({ ...h })
      return
    }

    let changeSummary = ""
    try {
      if (latest && latest.csdBasename === basename) {
        const prevContent = await CsdSnapshot.getContent(rfp, latest.snapshotHash)
        const changes = computeCsdChanges(prevContent, fileContent)
        changeSummary = changes.slice(0, 3).map((c) => c.detail).join(", ")
      }
    } catch {}

    const description = latestUserText() ?? `Version ${h.versions.length + 1}`
    const currentUserCount = userMsgCount()
    const prevVersionId = lastVersionId()

    // Same user prompt round + same file — update in place
    if (prevVersionId && currentUserCount === lastVersionUserCount()) {
      const existing = h.versions.find((v) => v.id === prevVersionId)
      if (existing && existing.csdBasename === basename) {
        existing.snapshotHash = snapHash
        existing.timestamp = Date.now()
        existing.resolvedPath = rfp
        if (changeSummary) existing.changeSummary = changeSummary
        h.currentVersionId = existing.id
        await saveHistory(h)
        setHistory({ ...h })
        return
      }
    }

    const id = generateVersionID()
    h.versions.push({ id, description, snapshotHash: snapHash, timestamp: Date.now(), changeSummary, csdBasename: basename, resolvedPath: rfp })
    h.currentVersionId = id
    setLastVersionId(id)
    setLastVersionUserCount(currentUserCount)
    await saveHistory(h)
    setHistory({ ...h })
  }

  // Load session history on mount
  createEffect(() => {
    loadHistory(props.sessionID).then((h) => setHistory(h))
  })

  // Re-poll when file path or messages change
  createEffect(() => {
    if (!props.csdFilePath) return
    // Trigger immediate check
    autoPopulate()
    const interval = setInterval(autoPopulate, 2000)
    onCleanup(() => clearInterval(interval))
  })

  const handleSelect = async (versionId: string) => {
    const h = history()
    if (!h) return
    const version = h.versions.find((v) => v.id === versionId)
    if (!version) return

    // Resolve the path for this version's file
    const rfp = version.resolvedPath ?? (version.csdBasename ? SessionWorkspace.resolve(props.sessionID, version.csdBasename) : undefined) ?? resolvedCsdPath() ?? props.csdFilePath
    if (!rfp) return

    try {
      await CsdSnapshot.restore(rfp, version.snapshotHash, props.sessionID)
    } catch {}

    h.currentVersionId = versionId
    await saveHistory(h)
    setHistory({ ...h })
    try {
      const restored = await Bun.file(rfp).text()
      setLastContentHash(contentHashFn(restored))
    } catch {}

    props.onVersionSelect?.()
  }

  const relativeTime = (timestamp: number) => {
    const diff = Date.now() - timestamp
    if (diff < 60000) return "now"
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m`
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}h`
    return `${Math.floor(diff / 86400000)}d`
  }

  const versions = createMemo(() => history()?.versions ?? [])

  return (
    <box
      flexDirection="column"
      flexGrow={1}
      maxHeight={10}
      backgroundColor={theme.backgroundPanel}
      paddingLeft={2}
      paddingRight={2}
    >
      <box
        flexShrink={0}
        flexDirection="row"
        justifyContent="space-between"
        borderColor={theme.border}
        border={["top"]}
        paddingTop={1}
      >
        <text fg={theme.text}><b>History</b></text>
        <text fg={theme.textMuted}>{versions().length} versions</text>
      </box>

      <Show
        when={versions().length > 0}
        fallback={
          <box flexGrow={1} paddingTop={1}>
            <text fg={theme.textMuted} wrapMode="word">
              Waiting for first CSD...
            </text>
          </box>
        }
      >
        <scrollbox flexGrow={1}>
          <For each={versions()}>
            {(version) => {
              const [hover, setHover] = createSignal(false)
              const isCurrent = createMemo(() => history()?.currentVersionId === version.id)
              const markerColor = createMemo(() => isCurrent() ? theme.accent : theme.text)
              const labelColor = createMemo(() => {
                if (isCurrent()) return theme.accent
                if (hover()) return theme.text
                return theme.textMuted
              })
              const bg = createMemo(() => {
                if (isCurrent() || hover()) return theme.backgroundElement
                return undefined
              })
              const truncDesc = createMemo(() => {
                const desc = version.description
                return desc.length > 30 ? desc.slice(0, 27) + "..." : desc
              })

              return (
                <box
                  flexDirection="column"
                  onMouseOver={() => setHover(true)}
                  onMouseOut={() => setHover(false)}
                  onMouseUp={() => handleSelect(version.id)}
                  backgroundColor={bg()}
                >
                  <box flexDirection="row" justifyContent="space-between">
                    <box flexDirection="row" flexShrink={1}>
                      <text fg={markerColor()}>
                        {isCurrent() ? "\u25C6 " : "\u25C7 "}
                      </text>
                      <text fg={labelColor()} wrapMode="none">
                        {truncDesc()}
                      </text>
                    </box>
                    <text fg={theme.textMuted} flexShrink={0}>
                      {" "}{relativeTime(version.timestamp)}
                    </text>
                  </box>
                  <Show when={version.changeSummary}>
                    <text fg={theme.textMuted} wrapMode="none">
                      {"  "}{version.changeSummary!.length > 34 ? version.changeSummary!.slice(0, 31) + "..." : version.changeSummary}
                    </text>
                  </Show>
                </box>
              )
            }}
          </For>
        </scrollbox>
      </Show>
    </box>
  )
}

// ---------------------------------------------------------------------------
// CSD Panel — right column
// ---------------------------------------------------------------------------

export function CsdPanel(props: { filePath: string | undefined; width: number; sessionID?: string; refreshTrigger?: () => number; renderTrigger?: () => number }) {
  const { theme } = useTheme()
  const kv = useKV()
  const sync = useSync()

  const [content, setContent] = createSignal("")
  const [compileStatus, setCompileStatus] = createSignal<"unknown" | "ok" | "error">("unknown")
  const [paramPanelVisible, setParamPanelVisible] = kv.signal("param_panel_visible", true)
  const [flowVisible, setFlowVisible] = kv.signal("signal_flow_visible", true)
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
    const msgs = sync.data.message[sid] ?? []
    for (let i = msgs.length - 1; i >= 0; i--) {
      const msg = msgs[i]
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
    const msgs = sync.data.message[sid] ?? []
    for (let i = msgs.length - 1; i >= 0; i--) {
      const msg = msgs[i]
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
    const sid = props.sessionID
    if (sid) {
      const msgs = sync.data.message[sid] ?? []
      msgs.length // reactive dependency
    }
    if (props.refreshTrigger) props.refreshTrigger()
    loadContent(fp)
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

  // Signal flow analysis for all instruments
  const signalFlowData = createMemo(() => {
    const s = structure()
    const c = content()
    if (!s || !c) return []
    const allLines = c.split("\n")
    return s.instruments.map((instr) => {
      const body = allLines.slice(instr.startLine, instr.endLine - 1).join("\n")
      const graph = SignalFlow.analyze(body, instr.id)
      const levels = SignalFlow.topologicalLevels(graph)
      return { instrId: instr.id, graph, levels }
    }).filter((d) => d.graph.nodes.length > 0)
  })

  const lines = createMemo(() => content().split("\n"))
  const instrumentCount = createMemo(() => structure()?.instruments.length ?? 0)
  const paramCount = createMemo(() => {
    const s = structure()
    if (!s) return 0
    return s.parameters.filter(p => p.value !== undefined && !isNaN(parseFloat(p.value!)) && !(p as any).pfieldVaries).length
  })

  const displayPath = createMemo(() => {
    const fp = props.filePath
    if (!fp) return ""
    if (path.isAbsolute(fp)) {
      const rel = path.relative(process.cwd(), fp)
      return rel.startsWith("..") ? path.basename(fp) : rel
    }
    return fp
  })

  // Waveform state
  const [wavInfo, setWavInfo] = createSignal<WavReader.WavInfo | null>(null)

  createEffect(() => {
    const fp = resolvedFilePath()
    if (!fp) {
      setWavInfo(null)
      return
    }
    const wavPath = fp.replace(".csd", ".wav")
    const sid = props.sessionID
    if (sid) {
      const msgs = sync.data.message[sid] ?? []
      msgs.length // reactive dep
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
  const [saveHover, setSaveHover] = createSignal(false)
  const [webHover, setWebHover] = createSignal(false)
  const [cabbageHover, setCabbageHover] = createSignal(false)
  const toast = useToast()

  // Extract first user message text as prompt
  const userPrompt = createMemo(() => {
    const sid = props.sessionID
    if (!sid) return ""
    const msgs = sync.data.message[sid] ?? []
    const firstUser = msgs.find((m: any) => m.role === "user")
    if (!firstUser) return ""
    const parts = sync.data.part[firstUser.id] ?? []
    return parts.reduce((acc: string, p: any) => {
      if (p.type === "text" && !p.synthetic && !p.ignored) acc += p.text
      return acc
    }, "")
  })

  const handleSave = async () => {
    const fp = resolvedFilePath()
    const sid = props.sessionID
    if (!fp || !sid) return
    try {
      let text = await Bun.file(fp).text()
      const prompt = userPrompt()
      if (prompt) {
        text = embedPromptInCsd(text, prompt)
        await Bun.write(fp, text)
      }
      const saved = await SessionWorkspace.save(sid)
      toast.show({ variant: "success", title: "Saved", message: `Saved ${saved.length} file(s) to project` })
      loadContent(fp)
    } catch (err) {
      toast.show({ variant: "error", title: "Save failed", message: err instanceof Error ? err.message : "Unknown error" })
    }
  }

  const handleExportWeb = async () => {
    const fp = resolvedFilePath()
    if (!fp) return
    try {
      const csd = await Bun.file(fp).text()
      const title = path.basename(fp, ".csd")
      const html = generateCsoundHTML(csd, title)
      const htmlPath = fp.replace(".csd", ".html")
      await Bun.write(htmlPath, html)
      spawn("open", [htmlPath], { detached: true, stdio: "ignore" }).unref()
      toast.show({ variant: "success", title: "Exported", message: `Opened ${path.basename(htmlPath)} in browser` })
    } catch (err) {
      toast.show({ variant: "error", title: "Export failed", message: err instanceof Error ? err.message : "Unknown error" })
    }
  }

  const handleOpenCabbage = async () => {
    const fp = resolvedFilePath()
    if (!fp) return
    const appPath = await ExternalApps.findCabbage()
    if (!appPath) {
      toast.show({ variant: "error", title: "Cabbage not found", message: "Install Cabbage to /Applications" })
      return
    }
    ExternalApps.openInApp(appPath, fp)
    toast.show({ variant: "success", title: "Cabbage", message: `Opened in Cabbage` })
  }

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
    const playProc = spawn(player, [audioPath], { stdio: "ignore", detached: process.platform !== "win32" })
    playProc.unref()
    CsoundProcessRegistry.register(playProc, "playback")
    playProc.once("exit", () => setPlaying(false))
    playProc.once("error", () => setPlaying(false))
    const timer = setTimeout(() => {
      try { playProc.kill("SIGTERM") } catch {}
    }, 30000)
    playProc.once("exit", () => clearTimeout(timer))
  }

  const handleStop = () => {
    CsoundProcessRegistry.stopAll()
    setPlaying(false)
    setRenderState("idle")
    setRenderStartTime(null)
  }

  const handlePlay = async () => {
    const fp = resolvedFilePath()
    if (!fp || playing()) return
    setPlaying(true)
    const outputPath = fp.replace(".csd", ".wav")
    try {
      const wavFile = Bun.file(outputPath)
      if (await wavFile.exists()) {
        playAudio(outputPath)
        return
      }
    } catch {}
    try {
      const proc = spawn("csound", ["-W", "-d", "-m0", "-o", outputPath, fp], {
        stdio: ["ignore", "pipe", "pipe"],
        detached: process.platform !== "win32",
      })
      CsoundProcessRegistry.register(proc, "render")
      proc.once("exit", (code) => {
        if (code === 0 || code === null) playAudio(outputPath)
        else setPlaying(false)
      })
      proc.once("error", () => setPlaying(false))
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

  // Debounced auto-render
  const RENDER_DEBOUNCE_MS = 600
  let renderDebounceTimer: ReturnType<typeof setTimeout> | null = null
  createEffect(() => {
    if (!props.renderTrigger) return
    const trigger = props.renderTrigger()
    if (trigger === 0) return
    if (renderDebounceTimer) clearTimeout(renderDebounceTimer)
    renderDebounceTimer = setTimeout(() => {
      const fp = resolvedFilePath()
      if (!fp || renderState() === "rendering") return
      const outputPath = fp.replace(".csd", ".wav")
      setRenderState("rendering")
      setRenderStartTime(Date.now())
      CsoundProcessRegistry.stopAll()
      setPlaying(false)
      const proc = spawn("csound", ["-W", "-d", "-m0", "-o", outputPath, fp], {
        stdio: ["ignore", "pipe", "pipe"],
        detached: process.platform !== "win32",
      })
      CsoundProcessRegistry.register(proc, "render")
      proc.once("exit", () => {
        setRenderState("idle")
        setRenderStartTime(null)
        loadContent(fp)
        const loadWav = async () => {
          const info = await WavReader.read(outputPath, Math.max(20, props.width - 16))
          setWavInfo(info)
        }
        loadWav()
      })
      proc.once("error", () => {
        setRenderState("idle")
        setRenderStartTime(null)
      })
      const timer = setTimeout(() => {
        try {
          if (proc.pid && process.platform !== "win32") process.kill(-proc.pid, "SIGTERM")
          else proc.kill("SIGTERM")
        } catch {}
      }, 15000)
      proc.once("exit", () => clearTimeout(timer))
    }, RENDER_DEBOUNCE_MS)
  })

  onCleanup(() => {
    if (renderDebounceTimer) clearTimeout(renderDebounceTimer)
  })

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
          <box flexDirection="row" flexShrink={0} gap={1}>
            <Show when={props.sessionID && (SessionWorkspace.status(props.sessionID!).unsavedChanges || userPrompt())}>
              <text
                fg={saveHover() ? theme.accent : theme.textMuted}
                onMouseOver={() => setSaveHover(true)}
                onMouseOut={() => setSaveHover(false)}
                onMouseUp={handleSave}
                flexShrink={0}
              >
                {"\u2193 save"}
              </text>
            </Show>
            <text
              fg={webHover() ? theme.accent : theme.textMuted}
              onMouseOver={() => setWebHover(true)}
              onMouseOut={() => setWebHover(false)}
              onMouseUp={handleExportWeb}
              flexShrink={0}
            >
              {"\u29C9 web"}
            </text>
            <text
              fg={cabbageHover() ? theme.accent : theme.textMuted}
              onMouseOver={() => setCabbageHover(true)}
              onMouseOut={() => setCabbageHover(false)}
              onMouseUp={handleOpenCabbage}
              flexShrink={0}
            >
              {"\u25A3 cabbage"}
            </text>
            <Show when={renderState() === "rendering" || playing()} fallback={
              <text
                fg={playHover() ? theme.accent : theme.textMuted}
                onMouseOver={() => setPlayHover(true)}
                onMouseOut={() => setPlayHover(false)}
                onMouseUp={handlePlay}
                flexShrink={0}
              >
                {"\u25B6 play"}
              </text>
            }>
              <text
                fg={playHover() ? theme.error : theme.warning}
                onMouseOver={() => setPlayHover(true)}
                onMouseOut={() => setPlayHover(false)}
                onMouseUp={handleStop}
                flexShrink={0}
              >
                {renderState() === "rendering"
                  ? `\u25A0 stop (${renderElapsed()}s)`
                  : "\u25A0 stop"}
              </text>
            </Show>
          </box>
        </box>

        {/* Code view */}
        <scrollbox flexGrow={4}>
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

        {/* Waveform + Signal Flow — combined bottom section */}
        <Show when={wavInfo() || (flowVisible() && signalFlowData().length > 0)}>
          <box
            flexGrow={1}
            paddingLeft={1}
            paddingRight={1}
            borderColor={theme.border}
            border={["top"]}
          >
            <scrollbox flexGrow={1}>
              <Show when={wavInfo()}>
                <WaveformDisplay
                  peaks={wavInfo()!.peaks}
                  duration={wavInfo()!.duration}
                  peakDb={wavInfo()!.peakDb}
                  width={props.width - 2}
                />
              </Show>
              <Show when={flowVisible() && signalFlowData().length > 0}>
                <text fg={theme.textMuted} bold>Signal Flow</text>
                <For each={signalFlowData()}>
                  {(data) => (
                    <box flexDirection="column">
                      <Show when={signalFlowData().length > 1}>
                        <text fg={theme.accent} wrapMode="none">instr {data.instrId}</text>
                      </Show>
                      <SignalFlowDiagram
                        levels={data.levels}
                        edges={data.graph.edges}
                        width={props.width - 4}
                      />
                    </box>
                  )}
                </For>
              </Show>
            </scrollbox>
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
            onMouseDown={() => setFlowVisible((prev) => !prev)}
          >
            flow {flowVisible() ? "\u25BC" : "\u25B6"}
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
