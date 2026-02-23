/**
 * Multi-tier knowledge system type definitions.
 *
 * Tier 0: Opcode Cards — structured lookup, O(1) Map access
 * Tier 1: CSD Examples — CAG (Cache-Augmented Generation), tag filter + search
 * Tier 2: Prose Chunks — RAG (Retrieval-Augmented Generation), BM25 + vector
 * Tier 3: Knowledge Graph — relational traversal, adjacency lists
 */

export type Domain = "synthesis" | "effects" | "modulation" | "debugging" | "general"

// ---------------------------------------------------------------------------
// Tier 0: Opcode Reference Cards
// ---------------------------------------------------------------------------

export interface OpcodeParameter {
  name: string
  rate: "k" | "a" | "i" | "S"
  description: string
  defaultValue?: string
  range?: [number, number]
}

export interface OpcodeCard {
  name: string // "moogladder"
  category: string // "filter"
  syntax: string // "aout moogladder ain, kcf, kres"
  description: string // One sentence
  parameters: OpcodeParameter[]
  seeAlso: string[] // ["lpf18", "zdf_ladder"]
  domain: Domain // "effects"
  tags: string[] // ["filter", "lowpass", "resonant"]
  exampleIDs: string[] // Links to Tier 1
}

// ---------------------------------------------------------------------------
// Tier 1: CSD Example Index (CAG)
// ---------------------------------------------------------------------------

export interface CsdInstrumentMeta {
  id: string
  opcodes: string[]
  paramCount: number
  signalFlow?: string
}

export interface CsdExample {
  id: string // "horner-flute"
  source: string // "HornerBook"
  filename: string // "flute.csd"
  title: string // "Flute - Wavetable Synthesis"
  techniques: string[] // ["wavetable", "vibrato"]
  primaryTechnique: string // "wavetable"
  opcodes: string[] // ["oscili", "tone", "balance"]
  domain: Domain // "synthesis"
  complexity: "basic" | "intermediate" | "advanced"
  instruments: CsdInstrumentMeta[]
  description: string // LLM-generated sonic description
  pedagogicalValue: string // What concept this best teaches
  signalFlow: string // "FM osc -> LP filter -> reverb -> stereo out"
  sonicTags: string[] // ["warm", "evolving", "pad-like"]
  qualityScore: number // 0-1, from RLHF
}

// ---------------------------------------------------------------------------
// Tier 2: Prose Knowledge (enhanced existing Chunk)
// ---------------------------------------------------------------------------

export interface ProseChunk {
  id: string
  source: string
  section: string
  subsection: string
  content: string
  tokens: number
  tags: string[]
  sourceType: "book" | "manual" | "tutorial" | "custom"
  domain: Domain
  relatedOpcodes: string[]
  relatedExampleIDs: string[]
}

// ---------------------------------------------------------------------------
// Tier 3: Knowledge Graph
// ---------------------------------------------------------------------------

export type GraphNodeType = "opcode" | "technique" | "example" | "chapter"

export interface GraphNode {
  id: string
  type: GraphNodeType
  label: string
}

export type GraphRelation =
  | "uses"
  | "demonstrates"
  | "explains"
  | "alternative_to"
  | "requires"

export interface GraphEdge {
  from: string
  to: string
  relation: GraphRelation
  weight: number // 0-1
}

export interface KnowledgeGraphData {
  nodes: GraphNode[]
  edges: GraphEdge[]
}

// ---------------------------------------------------------------------------
// Query Router
// ---------------------------------------------------------------------------

export type QueryIntent =
  | "opcode_lookup"
  | "example_request"
  | "technique_explain"
  | "comparison"
  | "debug"
  | "design_explore"
  | "general"

export interface RouteResult {
  intent: QueryIntent
  tiers: number[] // Which tiers to query [0, 1, 2, 3]
  opcodeNames?: string[] // Detected opcode names for Tier 0
  tokenBudget: {
    opcodeCards: number
    csdExamples: number
    proseChunks: number
  }
}

// ---------------------------------------------------------------------------
// Bundle types
// ---------------------------------------------------------------------------

export interface CoreBundle {
  version: string
  createdAt: number
  opcodeCards: OpcodeCard[]
  graph: KnowledgeGraphData
  stats: {
    totalOpcodes: number
    totalExamples: number
    totalProseChunks: number
    totalGraphNodes: number
    totalGraphEdges: number
  }
}

export interface ProseBundle {
  version: string
  createdAt: number
  mode: "hybrid" | "bm25-only"
  dimensions: number
  chunks: ProseChunk[]
  oramaIndex: any
}

export interface ExamplesBundle {
  version: string
  createdAt: number
  mode: "hybrid" | "bm25-only"
  dimensions: number
  examples: CsdExample[]
  oramaIndex: any
}

export interface CsdContentBundle {
  version: string
  createdAt: number
  contents: Record<string, string> // exampleID -> full CSD text
}
