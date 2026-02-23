#!/usr/bin/env bun
/**
 * Build knowledge graph from all tiers.
 *
 * Auto-generates a graph connecting opcodes <-> techniques <-> examples <-> chapters
 * from the other tier bundles (opcode cards, CSD examples, prose chunks).
 *
 * Edge types:
 *   example --uses--> opcode
 *   example --demonstrates--> technique
 *   opcode --alternative_to--> opcode
 *   chapter --explains--> opcode/technique
 *   technique --requires--> concept
 *
 * Usage:
 *   bun run scripts/build-knowledge-graph.ts
 */

import fs from "fs/promises"
import path from "path"
import type {
  GraphNode,
  GraphEdge,
  KnowledgeGraphData,
  CoreBundle,
  OpcodeCard,
  CsdExample,
} from "../src/retrieval/schema"

const ROOT = path.resolve(import.meta.dir, "..")
const RESOURCE_DIR = path.join(ROOT, "resources", "knowledge")

interface Chunk {
  id: string
  source: string
  section: string
  subsection: string
  content: string
  tokens: number
  tags: string[]
}

async function loadOpcodeCards(): Promise<OpcodeCard[]> {
  try {
    const data = await fs.readFile(path.join(RESOURCE_DIR, "opcode-cards.json"), "utf-8")
    return JSON.parse(data)
  } catch {
    console.log("  No opcode-cards.json found")
    return []
  }
}

async function loadExamples(): Promise<CsdExample[]> {
  try {
    const data = await fs.readFile(path.join(RESOURCE_DIR, "bundle-examples.json"), "utf-8")
    const bundle = JSON.parse(data)
    return bundle.examples
  } catch {
    console.log("  No bundle-examples.json found")
    return []
  }
}

async function loadProseChunks(): Promise<Chunk[]> {
  try {
    const data = await fs.readFile(path.join(RESOURCE_DIR, "bundle.json"), "utf-8")
    const bundle = JSON.parse(data)
    return bundle.chunks
  } catch {
    console.log("  No bundle.json found")
    return []
  }
}

function buildGraph(
  opcodeCards: OpcodeCard[],
  examples: CsdExample[],
  proseChunks: Chunk[],
): KnowledgeGraphData {
  const nodes: GraphNode[] = []
  const edges: GraphEdge[] = []
  const nodeIds = new Set<string>()

  function addNode(id: string, type: GraphNode["type"], label: string) {
    if (nodeIds.has(id)) return
    nodeIds.add(id)
    nodes.push({ id, type, label })
  }

  function addEdge(from: string, to: string, relation: GraphEdge["relation"], weight: number) {
    // Avoid duplicate edges
    edges.push({ from, to, relation, weight })
  }

  // --- Add opcode nodes ---
  console.log("  Adding opcode nodes...")
  for (const card of opcodeCards) {
    const nodeId = `opcode:${card.name}`
    addNode(nodeId, "opcode", card.name)
  }

  // --- Add technique nodes (from unique technique names across examples) ---
  console.log("  Adding technique nodes...")
  const allTechniques = new Set<string>()
  for (const ex of examples) {
    for (const tech of ex.techniques) {
      allTechniques.add(tech)
    }
  }
  for (const tech of allTechniques) {
    const nodeId = `technique:${tech.toLowerCase().replace(/\s+/g, "-")}`
    addNode(nodeId, "technique", tech)
  }

  // --- Add example nodes ---
  console.log("  Adding example nodes...")
  for (const ex of examples) {
    const nodeId = `example:${ex.id}`
    addNode(nodeId, "example", ex.title || ex.filename)
  }

  // --- Add chapter nodes (from unique prose sections) ---
  console.log("  Adding chapter nodes...")
  const uniqueSections = new Set<string>()
  for (const chunk of proseChunks) {
    if (chunk.section && !uniqueSections.has(chunk.section)) {
      uniqueSections.add(chunk.section)
      const nodeId = `chapter:${chunk.section.toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 60)}`
      addNode(nodeId, "chapter", chunk.section)
    }
  }

  // --- Add edges ---

  // 1. example --uses--> opcode
  console.log("  Adding example-uses-opcode edges...")
  for (const ex of examples) {
    const exNodeId = `example:${ex.id}`
    for (const opcode of ex.opcodes) {
      const opcodeNodeId = `opcode:${opcode}`
      if (nodeIds.has(opcodeNodeId)) {
        // Weight based on how central the opcode is to the example
        const weight = ex.opcodes.length > 0 ? 1 / Math.sqrt(ex.opcodes.length) : 0.5
        addEdge(exNodeId, opcodeNodeId, "uses", Math.round(weight * 100) / 100)
      }
    }
  }

  // 2. example --demonstrates--> technique
  console.log("  Adding example-demonstrates-technique edges...")
  for (const ex of examples) {
    const exNodeId = `example:${ex.id}`
    for (let i = 0; i < ex.techniques.length; i++) {
      const techNodeId = `technique:${ex.techniques[i].toLowerCase().replace(/\s+/g, "-")}`
      if (nodeIds.has(techNodeId)) {
        // Primary technique gets higher weight
        const weight = i === 0 ? 1.0 : 0.5
        addEdge(exNodeId, techNodeId, "demonstrates", weight)
      }
    }
  }

  // 3. opcode --alternative_to--> opcode (from seeAlso)
  console.log("  Adding opcode-alternative_to-opcode edges...")
  for (const card of opcodeCards) {
    const fromNodeId = `opcode:${card.name}`
    for (const seeAlso of card.seeAlso) {
      const toNodeId = `opcode:${seeAlso}`
      if (nodeIds.has(toNodeId)) {
        addEdge(fromNodeId, toNodeId, "alternative_to", 0.8)
      }
    }
  }

  // 4. chapter --explains--> opcode/technique (from prose chunk tags)
  console.log("  Adding chapter-explains edges...")
  const chapterOpcodes = new Map<string, Set<string>>() // chapter -> Set<opcode>
  const chapterTechniques = new Map<string, Set<string>>()

  for (const chunk of proseChunks) {
    const chapterNodeId = `chapter:${chunk.section.toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 60)}`
    if (!nodeIds.has(chapterNodeId)) continue

    for (const tag of chunk.tags) {
      const tagLower = tag.toLowerCase()

      // Check if tag is an opcode
      const opcodeNodeId = `opcode:${tagLower}`
      if (nodeIds.has(opcodeNodeId)) {
        if (!chapterOpcodes.has(chapterNodeId)) chapterOpcodes.set(chapterNodeId, new Set())
        chapterOpcodes.get(chapterNodeId)!.add(opcodeNodeId)
      }

      // Check if tag matches a technique
      for (const tech of allTechniques) {
        if (tagLower.includes(tech.toLowerCase()) || tech.toLowerCase().includes(tagLower)) {
          const techNodeId = `technique:${tech.toLowerCase().replace(/\s+/g, "-")}`
          if (nodeIds.has(techNodeId)) {
            if (!chapterTechniques.has(chapterNodeId)) chapterTechniques.set(chapterNodeId, new Set())
            chapterTechniques.get(chapterNodeId)!.add(techNodeId)
          }
        }
      }
    }
  }

  for (const [chapterNode, opcodes] of chapterOpcodes) {
    for (const opcodeNode of opcodes) {
      addEdge(chapterNode, opcodeNode, "explains", 0.7)
    }
  }

  for (const [chapterNode, techniques] of chapterTechniques) {
    for (const techNode of techniques) {
      addEdge(chapterNode, techNode, "explains", 0.8)
    }
  }

  // 5. opcode exampleIDs links (from opcode cards)
  for (const card of opcodeCards) {
    const opcodeNodeId = `opcode:${card.name}`
    for (const exId of card.exampleIDs) {
      const exNodeId = `example:${exId}`
      if (nodeIds.has(exNodeId)) {
        addEdge(exNodeId, opcodeNodeId, "uses", 0.9)
      }
    }
  }

  return { nodes, edges }
}

async function main() {
  console.log("=== DrC Knowledge Graph Builder ===\n")

  // Load all tier data
  console.log("Loading tier data...")
  const opcodeCards = await loadOpcodeCards()
  const examples = await loadExamples()
  const proseChunks = await loadProseChunks()

  console.log(`  Opcode cards: ${opcodeCards.length}`)
  console.log(`  CSD examples: ${examples.length}`)
  console.log(`  Prose chunks: ${proseChunks.length}`)

  // Build graph
  console.log("\nBuilding knowledge graph...")
  const graph = buildGraph(opcodeCards, examples, proseChunks)

  console.log(`  Nodes: ${graph.nodes.length}`)
  console.log(`  Edges: ${graph.edges.length}`)

  // Node type distribution
  const typeCounts = new Map<string, number>()
  for (const node of graph.nodes) {
    typeCounts.set(node.type, (typeCounts.get(node.type) ?? 0) + 1)
  }
  console.log(`  Node types:`)
  for (const [type, count] of typeCounts) {
    console.log(`    ${type}: ${count}`)
  }

  // Edge relation distribution
  const relCounts = new Map<string, number>()
  for (const edge of graph.edges) {
    relCounts.set(edge.relation, (relCounts.get(edge.relation) ?? 0) + 1)
  }
  console.log(`  Edge relations:`)
  for (const [rel, count] of relCounts) {
    console.log(`    ${rel}: ${count}`)
  }

  // Build core bundle
  const coreBundle: CoreBundle = {
    version: `graph-${Date.now().toString(36)}`,
    createdAt: Date.now(),
    opcodeCards,
    graph,
    stats: {
      totalOpcodes: opcodeCards.length,
      totalExamples: examples.length,
      totalProseChunks: proseChunks.length,
      totalGraphNodes: graph.nodes.length,
      totalGraphEdges: graph.edges.length,
    },
  }

  // Write bundle-core.json
  const outputPath = path.join(RESOURCE_DIR, "bundle-core.json")
  await fs.mkdir(RESOURCE_DIR, { recursive: true })
  await fs.writeFile(outputPath, JSON.stringify(coreBundle))

  const outputSize = (await fs.stat(outputPath)).size
  console.log(`\nOutput: ${outputPath}`)
  console.log(`  Size: ${(outputSize / 1024).toFixed(0)} KB`)
}

main().catch((e) => {
  console.error("Build failed:", e)
  process.exit(1)
})
