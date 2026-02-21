import { createMemo, createSignal, createEffect, For, Show, on, onCleanup } from "solid-js"
import { useTheme } from "../../context/theme"
import { useSync } from "@tui/context/sync"
import { DesignTree } from "@/csound/design-tree"
import { CsdSnapshot } from "@/validation/snapshot"
import { Installation } from "@/installation"
import { useDirectory } from "../../context/directory"
import { SessionWorkspace } from "@/session/workspace"
import type { AssistantMessage } from "@drc/sdk/v2"
import crypto from "crypto"
import path from "path"
import { RetrievalEngine } from "@/retrieval/engine"

export function DesignTreePanel(props: {
  csdFilePath: string | undefined
  sessionID: string
  onNodeSelect?: () => void
}) {
  const { theme } = useTheme()
  const sync = useSync()
  const directory = useDirectory()
  const [treeState, setTreeState] = createSignal<DesignTree.DesignTreeState | null>(null)
  const [focusedNodeID, setFocusedNodeID] = createSignal<string | undefined>()
  const [lastContentHash, setLastContentHash] = createSignal<string | undefined>()

  // --- Session info ---

  const session = createMemo(() => sync.session.get(props.sessionID))
  const messages = createMemo(() => sync.data.message[props.sessionID] ?? [])

  const cost = createMemo(() => {
    const total = messages().reduce((sum, x) => sum + (x.role === "assistant" ? x.cost : 0), 0)
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(total)
  })

  const context = createMemo(() => {
    const last = messages().findLast((x) => x.role === "assistant" && x.tokens.output > 0) as AssistantMessage
    if (!last) return undefined
    const total =
      last.tokens.input + last.tokens.output + last.tokens.reasoning + last.tokens.cache.read + last.tokens.cache.write
    const model = sync.data.provider.find((x) => x.id === last.providerID)?.models[last.modelID]
    return {
      tokens: total.toLocaleString(),
      percentage: model?.limit.context ? Math.round((total / model.limit.context) * 100) : undefined,
    }
  })

  const displayFile = createMemo(() => {
    const fp = props.csdFilePath
    if (!fp) return ""
    return path.basename(fp)
  })

  // --- Derive latest user request for node descriptions ---

  const latestUserText = createMemo(() => {
    const msgs = messages()
    for (let i = msgs.length - 1; i >= 0; i--) {
      const msg = msgs[i]
      if (msg.role !== "user") continue
      const parts = sync.data.part[msg.id] ?? []
      for (const part of parts) {
        if (part.type === "text" && !part.synthetic && part.text?.trim()) {
          const text = part.text.trim()
          return text.length > 60 ? text.slice(0, 57) + "..." : text
        }
      }
    }
    return undefined
  })

  // --- Tree loading + auto-population ---

  // Resolve file path through workspace (reads workspace copy when active)
  const resolvedCsdPath = createMemo(() => {
    const fp = props.csdFilePath
    if (!fp) return undefined
    return SessionWorkspace.resolve(props.sessionID, fp)
  })

  // Track whether we've already reset the tree for this session+file combo
  const resetSessions = new Set<string>()

  function contentHash(content: string): string {
    return crypto.createHash("sha256").update(content).digest("hex").slice(0, 16)
  }

  const loadTree = async () => {
    const fp = props.csdFilePath
    if (!fp) {
      setTreeState(null)
      return
    }

    // Fresh tree per session: delete old tree on first load for this session+file
    const resetKey = `${props.sessionID}:${fp}`
    if (!resetSessions.has(resetKey)) {
      resetSessions.add(resetKey)
      await DesignTree.deleteTree(fp)
      setTreeState(null)
      return
    }

    const state = await DesignTree.load(fp)
    setTreeState(state)
  }

  const autoPopulate = async () => {
    const fp = props.csdFilePath
    const rfp = resolvedCsdPath()
    if (!fp || !rfp) return

    let content: string
    try {
      content = await Bun.file(rfp).text()
    } catch {
      return
    }

    const hash = contentHash(content)
    const prevHash = lastContentHash()

    // Skip if content hasn't changed since last check
    if (hash === prevHash) return
    setLastContentHash(hash)

    // Skip the very first check (initial load)
    if (prevHash === undefined) {
      // On initial load, always create a fresh tree for this session
      let snapshotHash: string
      try {
        snapshotHash = await CsdSnapshot.capture(fp, props.sessionID)
      } catch {
        snapshotHash = hash
      }
      const tree = DesignTree.create(fp, snapshotHash, "Initial CSD")
      await DesignTree.save(tree)
      setTreeState(tree)
      return
    }

    // Content changed — create a new node
    let snapshotHash: string
    try {
      snapshotHash = await CsdSnapshot.capture(fp, props.sessionID)
    } catch {
      snapshotHash = hash
    }

    let tree = await DesignTree.load(fp)
    if (!tree) {
      tree = DesignTree.create(fp, snapshotHash, "Initial CSD")
    }

    // Don't create duplicate nodes for the same snapshot
    const existingNode = Object.values(tree.nodes).find((n) => n.snapshotHash === snapshotHash)
    if (existingNode) {
      DesignTree.selectNode(tree, existingNode.id)
      await DesignTree.save(tree)
      setTreeState({ ...tree })
      return
    }

    // Also check if a descendant of current node already has this hash
    const descendantID = DesignTree.findDescendantByHash(tree, tree.currentNodeID, snapshotHash)
    if (descendantID) {
      DesignTree.selectNode(tree, descendantID)
      await DesignTree.save(tree)
      setTreeState({ ...tree })
      return
    }

    const description = latestUserText() ?? `Change ${Object.keys(tree.nodes).length}`

    const { state: updatedTree, nodeID } = DesignTree.addNode(tree, {
      snapshotHash,
      description,
      sessionID: props.sessionID,
      metadata: {},
    })

    DesignTree.selectNode(updatedTree, nodeID)
    await DesignTree.save(updatedTree)
    setTreeState({ ...updatedTree })
  }

  createEffect(on(() => props.csdFilePath, () => {
    setLastContentHash(undefined)
    loadTree()
  }))

  // Poll for changes and auto-populate
  createEffect(() => {
    if (!props.csdFilePath) return
    const interval = setInterval(autoPopulate, 2000)
    onCleanup(() => clearInterval(interval))
  })

  // --- Flat tree lines ---

  interface TreeLine {
    node: DesignTree.DesignNode
    depth: number
    prefix: string
    connector: string
    isCurrent: boolean
    isOnPath: boolean
    childCount: number
  }

  const treeLines = createMemo((): TreeLine[] => {
    const state = treeState()
    if (!state) return []

    const pathNodeIDs = new Set(DesignTree.getPath(state).map((n) => n.id))
    const lines: TreeLine[] = []

    function walk(nodeID: string, depth: number, parentPrefixes: string[], isLast: boolean) {
      const node = state!.nodes[nodeID]
      if (!node) return

      // Skip pruned nodes unless showPruned is enabled
      if (node.pruned && !showPruned()) return

      const prefix = depth > 0 ? parentPrefixes.join("") : ""
      const connector = depth > 0 ? (isLast ? "\u2514\u2500" : "\u251C\u2500") : ""

      const children = node.alternatives
        .map((id) => state!.nodes[id])
        .filter(Boolean)
        .filter((n) => !n.pruned || showPruned())
        .sort((a, b) => a.timestamp - b.timestamp)

      lines.push({
        node,
        depth,
        prefix,
        connector,
        isCurrent: nodeID === state!.currentNodeID,
        isOnPath: pathNodeIDs.has(nodeID),
        childCount: children.length,
      })

      for (let i = 0; i < children.length; i++) {
        const childIsLast = i === children.length - 1
        const nextPrefixes =
          depth > 0 ? [...parentPrefixes, isLast ? "  " : "\u2502 "] : []
        walk(children[i].id, depth + 1, nextPrefixes, childIsLast)
      }
    }

    walk(state.rootNodeID, 0, [], true)
    return lines
  })

  // --- Selection ---

  const handleSelect = async (nodeID: string) => {
    const state = treeState()
    if (!state || !props.csdFilePath) return

    const node = state.nodes[nodeID]
    if (!node) return

    try {
      await CsdSnapshot.restore(props.csdFilePath, node.snapshotHash, props.sessionID)
    } catch {
      // Snapshot may not exist yet
    }

    DesignTree.selectNode(state, nodeID)
    await DesignTree.save(state)
    setTreeState({ ...state })

    // Notify parent to refresh CSD panel immediately
    props.onNodeSelect?.()
  }

  // --- Focused node ---

  const focusedLine = createMemo(() => {
    const id = focusedNodeID()
    if (!id) return undefined
    return treeLines().find((l) => l.node.id === id)
  })

  // --- Helpers ---

  const relativeTime = (timestamp: number) => {
    const diff = Date.now() - timestamp
    if (diff < 60000) return "now"
    if (diff < 3600000) return `${Math.floor(diff / 60000)}m`
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}h`
    return `${Math.floor(diff / 86400000)}d`
  }

  const nodeCount = createMemo(() => {
    const state = treeState()
    return state ? Object.keys(state.nodes).length : 0
  })

  const [showPruned, setShowPruned] = createSignal(false)

  const [retrievalStatus, setRetrievalStatus] = createSignal("")
  createEffect(() => {
    const check = () => {
      const status = RetrievalEngine.status()
      if (status.ready) {
        const modeLabel = status.mode === "hybrid" ? "hybrid" : "BM25"
        setRetrievalStatus(`${status.chunkCount} chunks | ${modeLabel}`)
      } else {
        setRetrievalStatus("indexing...")
      }
    }
    check()
    const interval = setInterval(check, 5000)
    onCleanup(() => clearInterval(interval))
  })

  return (
    <box
      flexDirection="column"
      height="100%"
      width={42}
      backgroundColor={theme.backgroundPanel}
      paddingTop={1}
      paddingBottom={1}
      paddingLeft={2}
      paddingRight={2}
    >
      {/* Session header */}
      <box flexShrink={0} paddingBottom={1}>
        <text fg={theme.text} wrapMode="none">
          <b>{session()?.title ?? "Session"}</b>
        </text>
        <box flexDirection="row" justifyContent="space-between">
          <text fg={theme.textMuted}>
            {context()?.tokens ?? "0"} tokens
            <Show when={context()?.percentage}>
              {" \u00B7 "}{context()!.percentage}%
            </Show>
          </text>
          <text fg={theme.textMuted}>{cost()}</text>
        </box>
        <Show when={displayFile()}>
          <text fg={theme.accent} wrapMode="none">{displayFile()}</text>
        </Show>
      </box>

      {/* Tree header */}
      <box
        flexShrink={0}
        borderColor={theme.border}
        border={["top"]}
        paddingTop={1}
        paddingBottom={1}
      >
        <box flexDirection="row" justifyContent="space-between">
          <text fg={theme.text}>
            <b>Design Tree</b>
          </text>
          <text fg={theme.textMuted}>{nodeCount()} nodes</text>
        </box>
      </box>

      {/* Tree body */}
      <Show
        when={treeLines().length > 0}
        fallback={
          <box flexGrow={1} paddingTop={1}>
            <text fg={theme.textMuted} wrapMode="word">
              Waiting for first change...
            </text>
            <text fg={theme.textMuted} wrapMode="word" paddingTop={1}>
              Each CSD modification auto-creates a node.
              Click any node to restore that version.
            </text>
          </box>
        }
      >
        <scrollbox flexGrow={1}>
          <For each={treeLines()}>
            {(line) => {
              const [hover, setHover] = createSignal(false)
              const isFocused = createMemo(() => focusedNodeID() === line.node.id)

              const isPruned = createMemo(() => !!line.node.pruned)
              const marker = createMemo(() =>
                line.isCurrent ? "\u25C6" : line.isOnPath ? "\u25CF" : "\u25CB",
              )
              const markerColor = createMemo(() => {
                if (isPruned()) return theme.textMuted
                if (line.isCurrent) return theme.accent
                if (line.isOnPath) return theme.accent
                // Inactive branches: visible but distinct (NOT textMuted)
                return theme.text
              })
              const labelColor = createMemo(() => {
                if (isPruned()) return theme.textMuted
                if (isFocused() || hover()) return theme.text
                if (line.isCurrent) return theme.accent
                if (line.isOnPath) return theme.accent
                // Inactive branches: secondary color (visible)
                return theme.text
              })
              const bg = createMemo(() => {
                if (isFocused() || hover()) return theme.backgroundElement
                return undefined
              })

              return (
                <box
                  flexDirection="row"
                  justifyContent="space-between"
                  onMouseOver={() => {
                    setHover(true)
                    setFocusedNodeID(line.node.id)
                  }}
                  onMouseOut={() => setHover(false)}
                  onMouseUp={() => handleSelect(line.node.id)}
                  backgroundColor={bg()}
                >
                  <box flexDirection="row" flexShrink={1}>
                    <text fg={theme.textMuted}>{line.prefix}{line.connector}</text>
                    <text fg={markerColor()}>{marker()} </text>
                    <text fg={labelColor()} wrapMode="none">
                      <Show when={line.node.branchName}>
                        <span style={{ fg: theme.accent, bold: true }}>[{line.node.branchName}] </span>
                      </Show>
                      {line.node.description}
                    </text>
                  </box>
                  <text fg={theme.textMuted} flexShrink={0}>
                    {" "}{relativeTime(line.node.timestamp)}
                  </text>
                </box>
              )
            }}
          </For>
        </scrollbox>
      </Show>

      {/* Focused node detail */}
      <Show when={focusedLine()}>
        {(line) => (
          <box
            flexShrink={0}
            paddingTop={1}
            borderColor={theme.border}
            border={["top"]}
          >
            <text fg={theme.text} wrapMode="word">
              <b>{line().node.description}</b>
            </text>
            <Show when={line().node.sonicCharacter}>
              <text fg={theme.textMuted} wrapMode="word">
                {line().node.sonicCharacter}
              </text>
            </Show>
            <box flexDirection="row" gap={2} paddingTop={1}>
              <text fg={theme.textMuted}>
                {line().childCount} {line().childCount === 1 ? "branch" : "branches"}
              </text>
              <Show when={line().isCurrent}>
                <text fg={theme.accent}><b>current</b></text>
              </Show>
              <Show when={!line().isCurrent}>
                <text fg={theme.textMuted}>click to restore</text>
              </Show>
            </box>
          </box>
        )}
      </Show>

      {/* Footer */}
      <box flexShrink={0} paddingTop={1} borderColor={theme.border} border={["top"]}>
        <text>
          <span style={{ fg: theme.textMuted }}>{directory().split("/").slice(0, -1).join("/")}/</span>
          <span style={{ fg: theme.text }}>{directory().split("/").at(-1)}</span>
        </text>
        <text fg={theme.textMuted}>
          <span style={{ fg: theme.success }}>{"\u2022"}</span> <b>dr</b>
          <span style={{ fg: theme.text }}><b>C</b></span>{" "}
          <span>{Installation.VERSION}</span>
        </text>
        <Show when={retrievalStatus()}>
          <text fg={theme.textMuted}>{retrievalStatus()}</text>
        </Show>
      </box>
    </box>
  )
}
