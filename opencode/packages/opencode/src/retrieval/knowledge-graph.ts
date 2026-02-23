/**
 * Tier 3: Knowledge Graph — lightweight in-memory adjacency graph.
 *
 * Connects opcodes <-> techniques <-> examples <-> chapters.
 * Adjacency list traversal for relational queries (<10ms).
 */

import type { GraphNode, GraphEdge, GraphRelation, GraphNodeType, KnowledgeGraphData, CoreBundle } from "./schema"
import { Log } from "../util/log"

export namespace KnowledgeGraph {
  const log = Log.create({ service: "retrieval.knowledge-graph" })

  // Adjacency lists: nodeID -> list of (targetID, relation, weight)
  interface AdjEntry {
    target: string
    relation: GraphRelation
    weight: number
  }

  let nodes: Map<string, GraphNode> = new Map()
  let outEdges: Map<string, AdjEntry[]> = new Map()
  let inEdges: Map<string, AdjEntry[]> = new Map()
  // Type index: nodeType -> nodeIDs
  let typeIndex: Map<GraphNodeType, string[]> = new Map()
  let ready = false

  /**
   * Load graph from a core bundle.
   */
  export function loadFromBundle(bundle: CoreBundle): void {
    loadFromData(bundle.graph)
  }

  /**
   * Load graph from raw data.
   */
  export function loadFromData(data: KnowledgeGraphData): void {
    nodes = new Map()
    outEdges = new Map()
    inEdges = new Map()
    typeIndex = new Map()

    for (const node of data.nodes) {
      nodes.set(node.id, node)

      if (!typeIndex.has(node.type)) typeIndex.set(node.type, [])
      typeIndex.get(node.type)!.push(node.id)
    }

    for (const edge of data.edges) {
      // Out-edges
      if (!outEdges.has(edge.from)) outEdges.set(edge.from, [])
      outEdges.get(edge.from)!.push({
        target: edge.to,
        relation: edge.relation,
        weight: edge.weight,
      })

      // In-edges (reverse)
      if (!inEdges.has(edge.to)) inEdges.set(edge.to, [])
      inEdges.get(edge.to)!.push({
        target: edge.from,
        relation: edge.relation,
        weight: edge.weight,
      })
    }

    ready = true
    log.info("knowledge graph loaded", {
      nodes: nodes.size,
      edges: data.edges.length,
    })
  }

  /**
   * Get a node by ID.
   */
  export function getNode(id: string): GraphNode | undefined {
    return nodes.get(id)
  }

  /**
   * Get all neighbors of a node (outgoing edges).
   */
  export function neighbors(
    nodeID: string,
    opts?: { relation?: GraphRelation; type?: GraphNodeType },
  ): Array<{ node: GraphNode; relation: GraphRelation; weight: number }> {
    const edges = outEdges.get(nodeID) ?? []
    const results: Array<{ node: GraphNode; relation: GraphRelation; weight: number }> = []

    for (const edge of edges) {
      if (opts?.relation && edge.relation !== opts.relation) continue
      const node = nodes.get(edge.target)
      if (!node) continue
      if (opts?.type && node.type !== opts.type) continue
      results.push({ node, relation: edge.relation, weight: edge.weight })
    }

    // Sort by weight descending
    results.sort((a, b) => b.weight - a.weight)
    return results
  }

  /**
   * Get all nodes pointing TO this node (incoming edges).
   */
  export function referrers(
    nodeID: string,
    opts?: { relation?: GraphRelation; type?: GraphNodeType },
  ): Array<{ node: GraphNode; relation: GraphRelation; weight: number }> {
    const edges = inEdges.get(nodeID) ?? []
    const results: Array<{ node: GraphNode; relation: GraphRelation; weight: number }> = []

    for (const edge of edges) {
      if (opts?.relation && edge.relation !== opts.relation) continue
      const node = nodes.get(edge.target)
      if (!node) continue
      if (opts?.type && node.type !== opts.type) continue
      results.push({ node, relation: edge.relation, weight: edge.weight })
    }

    results.sort((a, b) => b.weight - a.weight)
    return results
  }

  /**
   * Find related opcodes for an opcode node (via alternative_to edges).
   */
  export function relatedOpcodes(opcodeID: string, limit = 5): GraphNode[] {
    const alts = neighbors(opcodeID, { relation: "alternative_to", type: "opcode" })
    return alts.slice(0, limit).map((a) => a.node)
  }

  /**
   * Find examples that demonstrate a technique.
   */
  export function examplesForTechnique(techniqueID: string, limit = 5): GraphNode[] {
    // Examples point TO technique with "demonstrates"
    const demos = referrers(techniqueID, { relation: "demonstrates", type: "example" })
    return demos.slice(0, limit).map((d) => d.node)
  }

  /**
   * Find examples that use an opcode.
   */
  export function examplesForOpcode(opcodeID: string, limit = 5): GraphNode[] {
    // Examples point TO opcode with "uses"
    const users = referrers(opcodeID, { relation: "uses", type: "example" })
    return users.slice(0, limit).map((u) => u.node)
  }

  /**
   * Find chapters that explain an opcode or technique.
   */
  export function chaptersFor(nodeID: string, limit = 3): GraphNode[] {
    // Chapters point TO opcode/technique with "explains"
    const explainers = referrers(nodeID, { relation: "explains", type: "chapter" })
    return explainers.slice(0, limit).map((e) => e.node)
  }

  /**
   * Find techniques that an opcode is used in.
   * Traverses: opcode <- (uses) - example - (demonstrates) -> technique
   */
  export function techniquesForOpcode(opcodeID: string, limit = 5): GraphNode[] {
    // Get examples that use this opcode
    const examples = referrers(opcodeID, { relation: "uses", type: "example" })
    const techSet = new Map<string, { node: GraphNode; score: number }>()

    for (const ex of examples) {
      // Get techniques this example demonstrates
      const techs = neighbors(ex.node.id, { relation: "demonstrates", type: "technique" })
      for (const tech of techs) {
        const existing = techSet.get(tech.node.id)
        const score = ex.weight * tech.weight
        if (!existing || existing.score < score) {
          techSet.set(tech.node.id, { node: tech.node, score })
        }
      }
    }

    return [...techSet.values()]
      .sort((a, b) => b.score - a.score)
      .slice(0, limit)
      .map((t) => t.node)
  }

  /**
   * Get all nodes of a given type.
   */
  export function nodesOfType(type: GraphNodeType): GraphNode[] {
    const ids = typeIndex.get(type) ?? []
    return ids.map((id) => nodes.get(id)!).filter(Boolean)
  }

  /**
   * Two-hop traversal: find nodes reachable in exactly 2 hops.
   * Useful for "what's related to X through Y" queries.
   */
  export function twoHopNeighbors(
    startID: string,
    opts?: { throughType?: GraphNodeType; endType?: GraphNodeType; limit?: number },
  ): Array<{ node: GraphNode; score: number; path: string[] }> {
    const limit = opts?.limit ?? 10
    const results = new Map<string, { node: GraphNode; score: number; path: string[] }>()

    const firstHop = neighbors(startID)
    for (const hop1 of firstHop) {
      if (opts?.throughType && hop1.node.type !== opts.throughType) continue

      const secondHop = neighbors(hop1.node.id)
      for (const hop2 of secondHop) {
        if (hop2.node.id === startID) continue // No loops
        if (opts?.endType && hop2.node.type !== opts.endType) continue

        const score = hop1.weight * hop2.weight
        const existing = results.get(hop2.node.id)
        if (!existing || existing.score < score) {
          results.set(hop2.node.id, {
            node: hop2.node,
            score,
            path: [startID, hop1.node.id, hop2.node.id],
          })
        }
      }
    }

    return [...results.values()]
      .sort((a, b) => b.score - a.score)
      .slice(0, limit)
  }

  export function isReady(): boolean {
    return ready
  }

  export function nodeCount(): number {
    return nodes.size
  }

  export function edgeCount(): number {
    let count = 0
    for (const edges of outEdges.values()) count += edges.length
    return count
  }

  /**
   * Export graph data for serialization.
   */
  export function toData(): KnowledgeGraphData {
    const allNodes = [...nodes.values()]
    const allEdges: GraphEdge[] = []

    for (const [from, edges] of outEdges) {
      for (const edge of edges) {
        allEdges.push({
          from,
          to: edge.target,
          relation: edge.relation,
          weight: edge.weight,
        })
      }
    }

    return { nodes: allNodes, edges: allEdges }
  }
}
