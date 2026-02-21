import { createMemo, createSignal, onMount } from "solid-js"
import { DialogSelect, type DialogSelectOption } from "@tui/ui/dialog-select"
import { useDialog } from "../../ui/dialog"
import { DesignTree } from "@/csound/design-tree"
import { CsdSnapshot } from "@/validation/snapshot"
import { Locale } from "@/util/locale"

export function DialogDesignTree(props: {
  csdFilePath: string
  sessionID?: string
  onSelectNode?: (nodeID: string) => void
}) {
  const dialog = useDialog()
  const [treeState, setTreeState] = createSignal<DesignTree.DesignTreeState | null>(null)

  onMount(async () => {
    dialog.setSize("large")
    const state = await DesignTree.load(props.csdFilePath)
    setTreeState(state)
  })

  const options = createMemo((): DialogSelectOption<string>[] => {
    const state = treeState()
    if (!state) return []

    const allNodes = DesignTree.getAllNodes(state)
    const pathNodeIDs = new Set(DesignTree.getPath(state).map((n) => n.id))

    return allNodes.map((node) => {
      const isCurrent = node.id === state.currentNodeID
      const isOnPath = pathNodeIDs.has(node.id)
      const depth = DesignTree.getPath(state, node.id).length - 1
      const indent = "  ".repeat(depth)

      const marker = isCurrent ? " [current]" : isOnPath ? " *" : ""
      const character = node.sonicCharacter ? ` — ${node.sonicCharacter}` : ""

      return {
        title: `${indent}${node.description}${marker}`,
        value: node.id,
        footer: [
          Locale.todayTimeOrDateTime(node.timestamp),
          node.snapshotHash?.slice(0, 8),
          character,
        ]
          .filter(Boolean)
          .join(" | "),
        onSelect: async () => {
          const st = treeState()
          if (!st) return

          try {
            await CsdSnapshot.restore(props.csdFilePath, node.snapshotHash, props.sessionID)
          } catch {
            // Snapshot may not exist
          }

          DesignTree.selectNode(st, node.id)
          await DesignTree.save(st)
          props.onSelectNode?.(node.id)
          dialog.clear()
        },
      }
    })
  })

  return <DialogSelect title="Browse Design Tree" options={options()} />
}
