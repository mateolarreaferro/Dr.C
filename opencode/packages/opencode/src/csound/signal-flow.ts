/**
 * Signal flow analysis engine for Csound instruments.
 * Parses instrument bodies to extract opcode calls and build directed signal graphs.
 */
export namespace SignalFlow {
  export type OpcodeCategory = "source" | "filter" | "effect" | "output" | "envelope" | "modulator" | "control" | "other"

  export interface FlowNode {
    id: string
    opcode: string
    label: string
    rate: "a" | "k" | "i" | "S" | "?"
    outputVar: string
    inputVars: string[]
    line: number
    category: OpcodeCategory
  }

  export interface FlowEdge {
    from: string
    to: string
    variable: string
    rate: "a" | "k" | "i" | "?"
  }

  export interface FlowGraph {
    instrumentId: string
    nodes: FlowNode[]
    edges: FlowEdge[]
  }

  const SOURCES = new Set([
    "oscili", "oscils", "poscil", "poscil3", "vco2", "vco", "buzz", "gbuzz",
    "noise", "rand", "randi", "randh", "pinkish", "fractalnoise",
    "pluck", "wgbow", "wgflute", "wgclar", "wgbrass", "wgpluck2",
    "foscili", "foscil", "fm_voice",
    "diskin2", "diskin", "soundin", "mp3in",
    "inch", "in", "ins",
    "tablei", "table", "tab",
    "chnget",
  ])

  const FILTERS = new Set([
    "moogladder", "moogvcf", "moogvcf2", "lpf18",
    "butterlp", "butterhp", "butterbp", "butterbr",
    "statevar", "svfilter", "zdf_2pole", "zdf_1pole",
    "resonz", "reson", "areson", "bqrez",
    "pareq", "rbjeq", "eqfil",
    "tonex", "atonex", "tone", "atone",
    "comb", "alpass", "vclpf",
    "lpf", "hpf", "bpf",
  ])

  const EFFECTS = new Set([
    "reverbsc", "freeverb", "nreverb", "reverb", "reverb2",
    "delay", "delay1", "vdelay", "vdelay3", "delayr", "delayw", "deltap", "deltapi", "deltapn",
    "flanger", "chorus", "phaser1", "phaser2",
    "distort", "distort1", "clip", "powershape", "fold", "decimator",
    "compress", "compress2", "dam", "follow2",
    "pan2", "pan", "vbap",
    "temposcal",
  ])

  const CONTROLS = new Set([
    "chnget", "chnset",
  ])

  const OUTPUTS = new Set([
    "out", "outs", "outch", "outq",
    "chnset",
    "tablew", "tabw",
  ])

  const ENVELOPES = new Set([
    "madsr", "adsr", "mxadsr",
    "linseg", "linsegr", "expseg", "expsegr", "transeg",
    "linenr", "linen",
    "jspline", "rspline",
  ])

  const MODULATORS = new Set([
    "lfo", "oscili", // oscili at sub-audio is modulator
    "metro", "dust", "dust2", "gausstrig",
    "port", "portk",
    "limit", "scale",
    "phasor",
    "trigger", "changed", "changed2",
  ])

  function categorizeOpcode(opcode: string): OpcodeCategory {
    const lower = opcode.toLowerCase()
    if (OUTPUTS.has(lower)) return "output"
    if (SOURCES.has(lower)) return "source"
    if (FILTERS.has(lower)) return "filter"
    if (EFFECTS.has(lower)) return "effect"
    if (ENVELOPES.has(lower)) return "envelope"
    if (MODULATORS.has(lower)) return "modulator"
    if (CONTROLS.has(lower)) return "control"
    return "other"
  }

  function detectRate(varName: string): "a" | "k" | "i" | "S" | "?" {
    if (varName.startsWith("a")) return "a"
    if (varName.startsWith("k")) return "k"
    if (varName.startsWith("i")) return "i"
    if (varName.startsWith("S")) return "S"
    if (varName.startsWith("g")) {
      if (varName.length > 1) {
        if (varName[1] === "a") return "a"
        if (varName[1] === "k") return "k"
        if (varName[1] === "i") return "i"
        if (varName[1] === "S") return "S"
      }
    }
    return "?"
  }

  function extractVariableRefs(text: string): string[] {
    // Match Csound variable names: a/k/i/S/ga/gk/gi prefix followed by word chars
    const matches = text.match(/\b[akiS]\w+\b|\bg[akiS]\w+\b/g) || []
    return [...new Set(matches)]
  }

  /**
   * Analyze an instrument body and return a signal flow graph.
   */
  export function analyze(instrumentBody: string, instrId: string): FlowGraph {
    const lines = instrumentBody.split("\n")
    const nodes: FlowNode[] = []
    const outputVarToNodeId = new Map<string, string>()
    let nodeCounter = 0

    for (let i = 0; i < lines.length; i++) {
      const rawLine = lines[i]
      const line = rawLine.replace(/;.*$/, "").trim()
      if (!line || line.startsWith(";") || line.startsWith("#")) continue

      // Skip non-opcode lines (control flow, labels, etc.)
      if (/^(if|elseif|else|endif|while|od|until|goto|igoto|kgoto|tigoto|loop_lt|loop_gt|loop_le|loop_ge)\b/i.test(line)) continue
      if (line.endsWith(":")) continue

      let opcode: string | null = null
      let outputVar = ""
      let argsText = ""

      // Pattern 1: aOut = opcode(args) or aOut = opcode:rate(args)
      const funcMatch = line.match(/^([akiSg]\w+)\s*=\s*(\w+)(?::([akiS]))?\s*\((.*)$/)
      if (funcMatch) {
        outputVar = funcMatch[1]
        opcode = funcMatch[2]
        argsText = funcMatch[4].replace(/\)\s*$/, "")
      }

      // Pattern 2: aOut = expression (like aOut = vco2(...) + vco2(...))
      // Skip these complex expressions for now — they'd need sub-expression parsing

      // Pattern 3: aOut opcode args (traditional Csound syntax)
      if (!opcode) {
        const tradMatch = line.match(/^([akiSg]\w+)\s+(\w+)\s+(.*)$/)
        if (tradMatch) {
          outputVar = tradMatch[1]
          opcode = tradMatch[2]
          argsText = tradMatch[3]
        }
      }

      // Pattern 4: opcode args (no output, e.g., "out asig", "outs aL, aR", "chnset kval, 'name'", "delayw asig")
      if (!opcode) {
        const noOutMatch = line.match(/^(\w+)\s+(.+)$/)
        if (noOutMatch) {
          const lower = noOutMatch[1].toLowerCase()
          if (OUTPUTS.has(lower) || lower === "delayw" || lower === "clear") {
            opcode = noOutMatch[1]
            argsText = noOutMatch[2]
            outputVar = "_output"
          }
        }
      }

      // Pattern 5: simple assignment with expression — skip (not an opcode call)
      if (!opcode) continue

      // Skip common non-opcode keywords (but allow chnget — it's a signal source)
      if (/^(instr|endin|opcode|endop|prints|printks|print|printf|sprintf|turnoff|turnoff2|schedule|event|scoreline_i|init|chnexport|cggoto|timout|ftgen|seed|clear)$/i.test(opcode)) continue

      const category = categorizeOpcode(opcode)
      if (category === "other") {
        // Only include known opcodes to keep graph clean
        continue
      }

      const id = `n${nodeCounter++}`
      const inputVars = extractVariableRefs(argsText).filter(v => v !== outputVar)

      const rate = outputVar === "_output" ? "?" as const : detectRate(outputVar)

      nodes.push({
        id,
        opcode,
        label: outputVar === "_output" ? opcode : `${outputVar} = ${opcode}`,
        rate,
        outputVar,
        inputVars,
        line: i + 1,
        category,
      })

      if (outputVar !== "_output") {
        outputVarToNodeId.set(outputVar, id)
      }
    }

    // Build edges from variable dependencies
    const edges: FlowEdge[] = []
    for (const node of nodes) {
      for (const inputVar of node.inputVars) {
        const sourceNodeId = outputVarToNodeId.get(inputVar)
        if (sourceNodeId && sourceNodeId !== node.id) {
          edges.push({
            from: sourceNodeId,
            to: node.id,
            variable: inputVar,
            rate: detectRate(inputVar),
          })
        }
      }
    }

    return { instrumentId: instrId, nodes, edges }
  }

  /**
   * Topological sort of nodes for level assignment.
   * Returns nodes grouped by level (0 = sources with no inputs).
   */
  export function topologicalLevels(graph: FlowGraph): FlowNode[][] {
    if (graph.nodes.length === 0) return []

    const inDegree = new Map<string, number>()
    const adjacency = new Map<string, string[]>()

    for (const node of graph.nodes) {
      inDegree.set(node.id, 0)
      adjacency.set(node.id, [])
    }

    for (const edge of graph.edges) {
      inDegree.set(edge.to, (inDegree.get(edge.to) || 0) + 1)
      adjacency.get(edge.from)?.push(edge.to)
    }

    const levels: FlowNode[][] = []
    const nodeMap = new Map(graph.nodes.map(n => [n.id, n]))
    const visited = new Set<string>()

    let queue = graph.nodes.filter(n => (inDegree.get(n.id) || 0) === 0).map(n => n.id)

    while (queue.length > 0) {
      const level: FlowNode[] = []
      const nextQueue: string[] = []

      for (const id of queue) {
        if (visited.has(id)) continue
        visited.add(id)
        const node = nodeMap.get(id)
        if (node) level.push(node)

        for (const next of (adjacency.get(id) || [])) {
          const deg = (inDegree.get(next) || 1) - 1
          inDegree.set(next, deg)
          if (deg === 0 && !visited.has(next)) {
            nextQueue.push(next)
          }
        }
      }

      if (level.length > 0) levels.push(level)
      queue = nextQueue
    }

    // Add any remaining unvisited nodes (cycles or isolated) to last level
    const remaining = graph.nodes.filter(n => !visited.has(n.id))
    if (remaining.length > 0) levels.push(remaining)

    return levels
  }

  /**
   * Find a node by opcode name.
   */
  export function nodeByOpcode(
    graph: FlowGraph,
    opcode: string,
  ): FlowNode | undefined {
    return graph.nodes.find(
      (n) => n.opcode.toLowerCase() === opcode.toLowerCase(),
    )
  }

  /**
   * Suggest possible connections based on rate compatibility and category.
   */
  export function suggestConnections(
    graph: FlowGraph,
    nodeId: string,
  ): Array<{ targetId: string; reason: string }> {
    const node = graph.nodes.find((n) => n.id === nodeId)
    if (!node) return []

    const existingTargets = new Set(
      graph.edges.filter((e) => e.from === nodeId).map((e) => e.to),
    )

    return graph.nodes
      .filter((n) => n.id !== nodeId && !existingTargets.has(n.id))
      .filter((n) => {
        // Rate compatibility: a-rate can feed a-rate or output, k-rate can feed k-rate
        if (
          node.rate === "a" &&
          (n.rate === "a" || n.category === "output")
        )
          return true
        if (node.rate === "k" && n.rate === "k") return true
        if (
          node.rate === "k" &&
          n.inputVars.some((v) => v.startsWith("k"))
        )
          return true
        return false
      })
      .map((n) => ({
        targetId: n.id,
        reason: `${node.rate}-rate ${node.category} → ${n.rate}-rate ${n.category}`,
      }))
  }

  /**
   * Format a graph for inclusion in an agent prompt.
   */
  export function formatForPrompt(graph: FlowGraph): string {
    const levels = topologicalLevels(graph)
    const lines: string[] = [`Signal flow for instr ${graph.instrumentId}:`]

    for (let i = 0; i < levels.length; i++) {
      lines.push(`  Level ${i}:`)
      for (const node of levels[i]) {
        const inputs = graph.edges
          .filter((e) => e.to === node.id)
          .map((e) => e.variable)
          .join(", ")
        lines.push(
          `    ${node.label}${inputs ? ` ← [${inputs}]` : ""}`,
        )
      }
    }

    return lines.join("\n")
  }
}
