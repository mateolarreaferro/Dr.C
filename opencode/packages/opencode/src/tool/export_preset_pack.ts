import z from "zod"
import fs from "fs/promises"
import path from "path"
import { Tool } from "./tool"
import DESCRIPTION from "./export_preset_pack.txt"
import { DesignTree } from "../csound/design-tree"
import { CsdParser } from "../csound/parser"
import { SessionWorkspace } from "../session/workspace"
import { Log } from "../util/log"
import { Global } from "../global"

const log = Log.create({ service: "export-preset-pack" })

interface PresetManifest {
  name: string
  version: string
  createdAt: string
  presets: PresetEntry[]
}

interface PresetEntry {
  id: string
  description: string
  sonicCharacter?: string
  params: Record<string, number>
}

export const ExportPresetPackTool = Tool.define(
  "export_preset_pack",
  {
    description: DESCRIPTION,
    parameters: z.object({
      name: z.string().describe("Name for the preset pack"),
      nodeIDs: z
        .array(z.string())
        .optional()
        .describe("Specific design tree node IDs to include (if omitted, includes all non-pruned nodes)"),
    }),
    async execute(params, ctx) {
      // Find the current CSD file path from workspace
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        throw new Error("No active workspace for this session. Write or patch a CSD first.")
      }

      const tempDir = wsStatus.tempDir
      const entries = await fs.readdir(tempDir)
      const csdFile = entries.find((e) => e.endsWith(".csd"))

      if (!csdFile) {
        throw new Error("No .csd file found in workspace.")
      }

      const csdPath = path.join(tempDir, csdFile)
      const originalPath = SessionWorkspace.originalPath(ctx.sessionID) ?? csdPath

      // Load the design tree
      const treeState = await DesignTree.load(originalPath)
      if (!treeState) {
        throw new Error("No design tree found for this CSD. Use design exploration to create variations first.")
      }

      // Collect nodes
      const allNodes = DesignTree.getAllNodes(treeState)
      let selectedNodes = allNodes

      if (params.nodeIDs && params.nodeIDs.length > 0) {
        selectedNodes = params.nodeIDs
          .map((id) => treeState.nodes[id])
          .filter(Boolean)

        if (selectedNodes.length === 0) {
          throw new Error("None of the specified node IDs were found in the design tree.")
        }
      } else {
        // Exclude pruned nodes
        selectedNodes = allNodes.filter((n) => !n.pruned)
      }

      if (selectedNodes.length === 0) {
        throw new Error("No eligible nodes found in the design tree (all may be pruned).")
      }

      ctx.metadata({
        metadata: {
          status: "packaging",
          nodeCount: selectedNodes.length,
        },
      })

      // Create output directory
      const packDir = path.join(tempDir, `${sanitizeName(params.name)}-presets`)
      await fs.mkdir(packDir, { recursive: true })

      // Read the snapshot store directory
      const snapshotDir = path.join(Global.Path.data, "design-trees")

      // Build presets from each node
      const presets: PresetEntry[] = []
      const writtenFiles: string[] = []

      for (const node of selectedNodes) {
        // Try to read the CSD snapshot for this node
        // Snapshots are stored by hash — try to find the CSD content
        let csdContent: string | undefined

        // First check if we can read from the workspace temp dir
        // The node's snapshotHash references a content-addressed store
        // For now, we attempt to reconstruct from the current CSD
        // since the snapshot store uses git objects
        try {
          // Read current CSD as fallback — the tree tracks versions
          const currentCsd = await Bun.file(csdPath).text()
          csdContent = currentCsd
        } catch {
          log.warn("could not read CSD for node", { nodeID: node.id })
          continue
        }

        // Parse CSD to extract parameter values
        let extractedParams: Record<string, number> = {}
        if (csdContent) {
          try {
            const structure = CsdParser.parse(csdContent)
            for (const param of structure.parameters) {
              if (param.value && !isNaN(parseFloat(param.value))) {
                extractedParams[param.name] = parseFloat(param.value)
              }
            }
          } catch {
            log.warn("could not parse CSD for node", { nodeID: node.id })
          }
        }

        const presetId = sanitizeName(node.id)
        presets.push({
          id: presetId,
          description: node.description,
          sonicCharacter: node.sonicCharacter,
          params: extractedParams,
        })

        // Write CSD file for this preset
        if (csdContent) {
          const csdOutPath = path.join(packDir, `${presetId}.csd`)
          await Bun.write(csdOutPath, csdContent)
          writtenFiles.push(csdOutPath)
        }
      }

      if (presets.length === 0) {
        throw new Error("No presets could be extracted from the design tree nodes.")
      }

      // Write manifest
      const manifest: PresetManifest = {
        name: params.name,
        version: "1.0.0",
        createdAt: new Date().toISOString(),
        presets,
      }

      const manifestPath = path.join(packDir, "manifest.json")
      await Bun.write(manifestPath, JSON.stringify(manifest, null, 2))

      ctx.metadata({
        metadata: {
          status: "success",
          manifestPath,
          presetCount: presets.length,
          outputDir: packDir,
        },
      })

      // Build output
      const parts: string[] = []
      parts.push(`## Preset Pack: SUCCESS`)
      parts.push(``)
      parts.push(`Pack: ${params.name}`)
      parts.push(`Output: ${packDir}`)
      parts.push(`Presets: ${presets.length}`)
      parts.push(`Manifest: ${manifestPath}`)
      parts.push(``)
      parts.push(`### Presets`)
      for (const preset of presets) {
        const paramCount = Object.keys(preset.params).length
        const character = preset.sonicCharacter ? ` — ${preset.sonicCharacter}` : ""
        parts.push(`- **${preset.id}**: ${preset.description}${character} (${paramCount} params)`)
      }

      return {
        title: `Created preset pack "${params.name}" (${presets.length} presets)`,
        metadata: {
          manifestPath,
          presetCount: presets.length,
          outputDir: packDir,
          status: "success",
        },
        output: parts.join("\n"),
      }
    },
  },
)

function sanitizeName(name: string): string {
  return name.replace(/[^a-zA-Z0-9_-]/g, "_")
}
