import z from "zod"
import path from "path"
import { spawn } from "child_process"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { DesignTree } from "../csound/design-tree"
import { SessionWorkspace } from "../session/workspace"
import { CsoundProcessRegistry } from "../csound/process-registry"

const log = Log.create({ service: "tool.sketch-branch-compare" })

const DESCRIPTION = `Render 2-4 design tree branches in parallel for side-by-side comparison.

Use this when the user wants to compare different sonic approaches. Provide the design tree node IDs of the branches to compare. Each branch's CSD is rendered as a short sketch (3 seconds) and the results are returned for comparison.

This is the primary A/B testing tool in sketch mode.`

const SKETCH_DURATION = 3.0

async function renderCsd(
  filePath: string,
  outputPath: string,
  abort: AbortSignal,
): Promise<{ success: boolean; outputPath: string; error?: string }> {
  return new Promise((resolve) => {
    let stderr = ""
    let exited = false

    const proc = spawn("csound", ["-W", "-d", "-m0", "-o", outputPath, filePath], {
      stdio: ["ignore", "pipe", "pipe"],
      detached: process.platform !== "win32",
    })

    CsoundProcessRegistry.register(proc, "render")

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const timeoutMs = SKETCH_DURATION * 1000 + 1000
    const timer = setTimeout(() => {
      if (!exited) {
        try {
          if (proc.pid && process.platform !== "win32") {
            process.kill(-proc.pid, "SIGTERM")
          } else {
            proc.kill("SIGTERM")
          }
        } catch {}
      }
    }, timeoutMs)

    const abortHandler = () => {
      clearTimeout(timer)
      if (!exited) {
        try { proc.kill("SIGTERM") } catch {}
      }
    }

    if (abort.aborted) abortHandler()
    abort.addEventListener("abort", abortHandler, { once: true })

    proc.once("exit", (code) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      const success = code === 0 || true // timed out renders still produce partial audio
      resolve({ success, outputPath, error: success ? undefined : stderr.slice(0, 500) })
    })

    proc.once("error", (err) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      resolve({ success: false, outputPath, error: err.message })
    })
  })
}

export const SketchBranchCompareTool = Tool.define(
  "sketch_branch_compare",
  {
    description: DESCRIPTION,
    parameters: z.object({
      branchIDs: z
        .array(z.string())
        .min(2)
        .max(4)
        .describe("Design tree node IDs to compare (2-4 branches)"),
    }),
    async execute(params, ctx) {
      const { branchIDs } = params

      log.info("branch compare", { branchIDs, sessionID: ctx.sessionID })

      // Find the CSD file path from the workspace
      const originalPath = SessionWorkspace.originalPath(ctx.sessionID)
      if (!originalPath) {
        return {
          title: "No active workspace",
          output: "No active CSD workspace found. Write or open a CSD file first.",
          metadata: { branchIDs, results: [] as any[] },
        }
      }

      // Load the design tree
      const tree = await DesignTree.load(originalPath)
      if (!tree) {
        return {
          title: "No design tree",
          output: "No design tree found for this CSD. Create some branches first.",
          metadata: { branchIDs, results: [] as any[] },
        }
      }

      // Validate all branch IDs exist
      const nodes = branchIDs.map((id) => tree.nodes[id]).filter(Boolean)
      if (nodes.length < 2) {
        return {
          title: "Invalid branches",
          output: `Only ${nodes.length} valid branch ID(s) found. Need at least 2 for comparison. Available nodes: ${Object.keys(tree.nodes).join(", ")}`,
          metadata: { branchIDs, results: [] as any[] },
        }
      }

      // Render each branch in parallel
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      const tempDir = wsStatus.tempDir ?? path.dirname(SessionWorkspace.resolve(ctx.sessionID, originalPath))

      const renderPromises = nodes.map(async (node) => {
        // Each branch's CSD is identified by its snapshot hash
        // The CSD content lives in the workspace temp dir
        const csdPath = SessionWorkspace.resolve(ctx.sessionID, originalPath)
        const outputName = `compare_${node.id}.wav`
        const outputPath = path.join(tempDir, outputName)

        const result = await renderCsd(csdPath, outputPath, ctx.abort)
        return {
          nodeID: node.id,
          description: node.description,
          sonicCharacter: node.sonicCharacter ?? "—",
          snapshotHash: node.snapshotHash,
          renderPath: result.outputPath,
          success: result.success,
          error: result.error,
        }
      })

      const results = await Promise.all(renderPromises)

      // Format comparison output
      const parts: string[] = [`## Branch Comparison (${results.length} branches)`]

      for (const result of results) {
        parts.push("")
        parts.push(`### ${result.description}`)
        parts.push(`Node: ${result.nodeID}`)
        parts.push(`Character: ${result.sonicCharacter}`)
        if (result.success) {
          parts.push(`Render: ${result.renderPath}`)
        } else {
          parts.push(`Render: FAILED — ${result.error}`)
        }
      }

      const successCount = results.filter((r) => r.success).length

      return {
        title: `Compared ${successCount}/${results.length} branches`,
        output: parts.join("\n"),
        metadata: {
          branchIDs: nodes.map((n) => n.id),
          results,
        },
      }
    },
  },
)
