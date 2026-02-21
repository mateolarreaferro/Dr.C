import fs from "fs/promises"
import path from "path"
import crypto from "crypto"
import { Log } from "../util/log"
import { Global } from "../global"
import { BusEvent } from "../bus/bus-event"
import { Bus } from "../bus"
import z from "zod"

const log = Log.create({ service: "design-tree" })

function generateNodeID(): string {
  const timestamp = Date.now().toString(36)
  const random = crypto.randomBytes(6).toString("hex")
  return `dtn_${timestamp}_${random}`
}

export namespace DesignTree {
  const TREE_DIR = path.join(Global.Path.data, "design-trees")

  // --- Events ---

  export const Event = {
    NodeAdded: BusEvent.define(
      "design-tree.node.added",
      z.object({
        csdFilePath: z.string(),
        nodeID: z.string(),
        parentNodeID: z.string().optional(),
      }),
    ),
    NodeSelected: BusEvent.define(
      "design-tree.node.selected",
      z.object({
        csdFilePath: z.string(),
        nodeID: z.string(),
        snapshotHash: z.string(),
      }),
    ),
    TreeUpdated: BusEvent.define(
      "design-tree.updated",
      z.object({
        csdFilePath: z.string(),
      }),
    ),
  }

  // --- Types ---

  export interface DesignNode {
    id: string
    sessionID?: string
    snapshotHash: string
    parentNodeID?: string
    description: string
    sonicCharacter?: string
    csdFilePath: string
    timestamp: number
    selected: boolean
    alternatives: string[]
    metadata: Record<string, any>
    branchName?: string
    pruned?: boolean
  }

  export interface DesignTreeState {
    nodes: Record<string, DesignNode>
    rootNodeID: string
    currentNodeID: string
    csdFilePath: string
  }

  // --- Persistence ---

  async function ensureDir() {
    await fs.mkdir(TREE_DIR, { recursive: true })
  }

  function treePath(csdFilePath: string): string {
    const encoded = Buffer.from(csdFilePath).toString("base64url")
    return path.join(TREE_DIR, `${encoded}.json`)
  }

  export async function save(state: DesignTreeState): Promise<void> {
    await ensureDir()
    const filePath = treePath(state.csdFilePath)
    await Bun.write(filePath, JSON.stringify(state, null, 2))
    log.info("tree saved", { csdFilePath: state.csdFilePath, nodes: Object.keys(state.nodes).length })
  }

  export async function load(csdFilePath: string): Promise<DesignTreeState | null> {
    try {
      const filePath = treePath(csdFilePath)
      const file = Bun.file(filePath)
      if (!(await file.exists())) return null
      const data = await file.json()
      return data as DesignTreeState
    } catch {
      return null
    }
  }

  // --- Operations ---

  export function create(csdFilePath: string, snapshotHash: string, description: string = "Initial CSD"): DesignTreeState {
    const rootID = generateNodeID()

    const rootNode: DesignNode = {
      id: rootID,
      snapshotHash,
      description,
      csdFilePath,
      timestamp: Date.now(),
      selected: true,
      alternatives: [],
      metadata: {},
    }

    const state: DesignTreeState = {
      nodes: { [rootID]: rootNode },
      rootNodeID: rootID,
      currentNodeID: rootID,
      csdFilePath,
    }

    log.info("tree created", { csdFilePath, rootID })
    return state
  }

  export function addNode(
    state: DesignTreeState,
    input: {
      snapshotHash: string
      parentNodeID?: string
      description: string
      sonicCharacter?: string
      sessionID?: string
      metadata?: Record<string, any>
    },
  ): { state: DesignTreeState; nodeID: string } {
    const parentID = input.parentNodeID ?? state.currentNodeID
    const nodeID = generateNodeID()

    const node: DesignNode = {
      id: nodeID,
      sessionID: input.sessionID,
      snapshotHash: input.snapshotHash,
      parentNodeID: parentID,
      description: input.description,
      sonicCharacter: input.sonicCharacter,
      csdFilePath: state.csdFilePath,
      timestamp: Date.now(),
      selected: false,
      alternatives: [],
      metadata: input.metadata ?? {},
    }

    // Add to parent's alternatives list
    const parent = state.nodes[parentID]
    if (parent) {
      parent.alternatives.push(nodeID)
    }

    state.nodes[nodeID] = node
    log.info("node added", { nodeID, parentID, description: input.description })

    try {
      Bus.publish(Event.NodeAdded, {
        csdFilePath: state.csdFilePath,
        nodeID,
        parentNodeID: parentID,
      })
    } catch {
      // Bus not available in TUI context — safe to skip
    }

    return { state, nodeID }
  }

  export function selectNode(state: DesignTreeState, nodeID: string): DesignTreeState {
    const node = state.nodes[nodeID]
    if (!node) {
      log.warn("node not found for selection", { nodeID })
      return state
    }

    // Deselect current
    const current = state.nodes[state.currentNodeID]
    if (current) current.selected = false

    // Select new
    node.selected = true
    state.currentNodeID = nodeID

    log.info("node selected", { nodeID, description: node.description })

    try {
      Bus.publish(Event.NodeSelected, {
        csdFilePath: state.csdFilePath,
        nodeID,
        snapshotHash: node.snapshotHash,
      })
    } catch {
      // Bus not available in TUI context — safe to skip
    }

    return state
  }

  export function getPath(state: DesignTreeState, nodeID?: string): DesignNode[] {
    const targetID = nodeID ?? state.currentNodeID
    const path: DesignNode[] = []
    let current = state.nodes[targetID]

    while (current) {
      path.unshift(current)
      if (!current.parentNodeID) break
      current = state.nodes[current.parentNodeID]
    }

    return path
  }

  export function getChildren(state: DesignTreeState, nodeID: string): DesignNode[] {
    const node = state.nodes[nodeID]
    if (!node) return []
    return node.alternatives.map((id) => state.nodes[id]).filter(Boolean)
  }

  export function getSiblings(state: DesignTreeState, nodeID: string): DesignNode[] {
    const node = state.nodes[nodeID]
    if (!node || !node.parentNodeID) return []
    const parent = state.nodes[node.parentNodeID]
    if (!parent) return []
    return parent.alternatives.map((id) => state.nodes[id]).filter(Boolean).filter((n) => n.id !== nodeID)
  }

  export function getCurrentNode(state: DesignTreeState): DesignNode | undefined {
    return state.nodes[state.currentNodeID]
  }

  export function getNodeCount(state: DesignTreeState): number {
    return Object.keys(state.nodes).length
  }

  export function getAllNodes(state: DesignTreeState): DesignNode[] {
    return Object.values(state.nodes).sort((a, b) => a.timestamp - b.timestamp)
  }

  // --- Branch operations ---

  export function renameBranch(state: DesignTreeState, nodeID: string, name: string): DesignTreeState {
    const node = state.nodes[nodeID]
    if (!node) {
      log.warn("node not found for rename", { nodeID })
      return state
    }
    node.branchName = name
    log.info("branch renamed", { nodeID, name })
    return state
  }

  export function pruneNode(state: DesignTreeState, nodeID: string): DesignTreeState {
    const node = state.nodes[nodeID]
    if (!node) return state
    if (nodeID === state.rootNodeID) return state // can't prune root
    if (nodeID === state.currentNodeID) return state // can't prune current

    node.pruned = true
    // Also prune descendants
    const descendants = getDescendants(state, nodeID)
    for (const desc of descendants) {
      desc.pruned = true
    }

    log.info("branch pruned", { nodeID, descendants: descendants.length })
    return state
  }

  export function unpruneNode(state: DesignTreeState, nodeID: string): DesignTreeState {
    const node = state.nodes[nodeID]
    if (!node) return state

    node.pruned = false
    // Also unprune descendants
    const descendants = getDescendants(state, nodeID)
    for (const desc of descendants) {
      desc.pruned = false
    }

    log.info("branch unpruned", { nodeID })
    return state
  }

  export function getDescendants(state: DesignTreeState, nodeID: string): DesignNode[] {
    const result: DesignNode[] = []
    const queue = [...(state.nodes[nodeID]?.alternatives ?? [])]

    while (queue.length > 0) {
      const id = queue.shift()!
      const node = state.nodes[id]
      if (!node) continue
      result.push(node)
      queue.push(...node.alternatives)
    }

    return result
  }

  export interface BranchInfo {
    leaf: DesignNode
    path: DesignNode[]
    name: string
  }

  export function getBranches(state: DesignTreeState): BranchInfo[] {
    // Find all leaf nodes (no children) and trace paths to root
    const leaves = Object.values(state.nodes).filter(
      (n) => n.alternatives.length === 0 && !n.pruned,
    )

    return leaves.map((leaf) => ({
      leaf,
      path: getPath(state, leaf.id),
      name: leaf.branchName ?? leaf.description,
    }))
  }

  export interface BranchDiff {
    commonAncestor: DesignNode
    onlyA: DesignNode[]
    onlyB: DesignNode[]
  }

  export function compareBranches(
    state: DesignTreeState,
    nodeA: string,
    nodeB: string,
  ): BranchDiff | null {
    const pathA = getPath(state, nodeA)
    const pathB = getPath(state, nodeB)

    // Find common ancestor
    let commonIdx = 0
    while (
      commonIdx < pathA.length &&
      commonIdx < pathB.length &&
      pathA[commonIdx].id === pathB[commonIdx].id
    ) {
      commonIdx++
    }

    if (commonIdx === 0) return null

    return {
      commonAncestor: pathA[commonIdx - 1],
      onlyA: pathA.slice(commonIdx),
      onlyB: pathB.slice(commonIdx),
    }
  }

  /**
   * Check if a descendant of the given node already has the same snapshot hash.
   * Used to prevent duplicate branch creation in autoPopulate.
   */
  export function findDescendantByHash(
    state: DesignTreeState,
    nodeID: string,
    snapshotHash: string,
  ): string | undefined {
    const descendants = getDescendants(state, nodeID)
    return descendants.find((n) => n.snapshotHash === snapshotHash)?.id
  }

  /**
   * Delete an existing tree for a CSD file (used to reset on new session).
   */
  export async function deleteTree(csdFilePath: string): Promise<void> {
    try {
      const filePath = treePath(csdFilePath)
      await fs.rm(filePath, { force: true })
      log.info("tree deleted", { csdFilePath })
    } catch {
      // File may not exist
    }
  }

  // --- Tree listing ---

  export async function listTrees(): Promise<{ csdFilePath: string; nodeCount: number; lastModified: number }[]> {
    await ensureDir()
    const entries = await fs.readdir(TREE_DIR)
    const trees: { csdFilePath: string; nodeCount: number; lastModified: number }[] = []

    for (const entry of entries) {
      if (!entry.endsWith(".json")) continue
      try {
        const data = await Bun.file(path.join(TREE_DIR, entry)).json()
        const state = data as DesignTreeState
        const nodes = Object.values(state.nodes)
        const lastModified = Math.max(...nodes.map((n) => n.timestamp))
        trees.push({
          csdFilePath: state.csdFilePath,
          nodeCount: nodes.length,
          lastModified,
        })
      } catch {
        // Skip corrupted files
      }
    }

    return trees.sort((a, b) => b.lastModified - a.lastModified)
  }
}
