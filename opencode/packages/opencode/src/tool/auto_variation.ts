import z from "zod"
import path from "path"
import crypto from "crypto"
import fs from "fs/promises"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"
import { CsdParser } from "../csound/parser"
import { DesignTree } from "../csound/design-tree"
import DESCRIPTION from "./auto_variation.txt"

const log = Log.create({ service: "tool.auto-variation" })

type VariationRange = "subtle" | "moderate" | "wild"

function perturbValue(value: number, range: VariationRange, min: number, max: number): number {
  let factor: number
  switch (range) {
    case "subtle":
      factor = 0.1
      break
    case "moderate":
      factor = 0.3
      break
    case "wild":
      factor = 0.6
      break
  }

  // Random perturbation within the factor range
  const perturbation = (Math.random() * 2 - 1) * factor
  let newValue = value * (1 + perturbation)

  // For "wild", occasionally do larger jumps
  if (range === "wild" && Math.random() < 0.2) {
    newValue = min + Math.random() * (max - min)
  }

  return Math.max(min, Math.min(max, newValue))
}

// Infer reasonable ranges for parameters based on name
function inferRange(name: string, currentValue: number): [number, number] {
  const lower = name.toLowerCase()
  if (lower.includes("cutoff") || lower.includes("freq")) return [20, 12000]
  if (lower.includes("reson") || lower.includes("res")) return [0, 1]
  if (lower.includes("amp") || lower.includes("level") || lower.includes("gain")) return [0, 1]
  if (lower.includes("rate") || lower.includes("speed")) return [0.01, 20]
  if (lower.includes("depth") || lower.includes("amount")) return [0, 1]
  if (lower.includes("feedback") || lower.includes("fb")) return [0, 0.99]
  if (lower.includes("mix") || lower.includes("wet")) return [0, 1]
  if (lower.includes("attack") || lower.includes("att")) return [0.001, 2]
  if (lower.includes("decay") || lower.includes("dec")) return [0.01, 5]
  if (lower.includes("sustain") || lower.includes("sus")) return [0, 1]
  if (lower.includes("release") || lower.includes("rel")) return [0.01, 10]
  if (lower.includes("pan")) return [0, 1]
  if (lower.includes("ratio") || lower.includes("mult")) return [0.25, 8]

  // Default: allow 0 to 2x the current value (or at least 0-1)
  const maxDefault = Math.max(Math.abs(currentValue) * 2, 1)
  return [0, maxDefault]
}

export const AutoVariationTool = Tool.define(
  "auto_variation",
  {
    description: DESCRIPTION,
    parameters: z.object({
      count: z
        .number()
        .int()
        .min(1)
        .max(8)
        .default(3)
        .describe("Number of variations to generate (default 3, max 8)"),
      variationRange: z
        .enum(["subtle", "moderate", "wild"])
        .default("subtle")
        .describe("Perturbation range: subtle (+-10%), moderate (+-30%), wild (+-60%)"),
    }),
    async execute(params, ctx) {
      const count = params.count ?? 3
      const variationRange = params.variationRange ?? "subtle"

      // Find the current CSD in session workspace
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        throw new Error("No active workspace. Write a CSD first before using auto_variation.")
      }

      const tempDir = wsStatus.tempDir
      let csdPath: string | undefined

      try {
        const entries = await fs.readdir(tempDir)
        for (const entry of entries) {
          if (path.extname(entry).toLowerCase() === ".csd" && !entry.startsWith("variation-")) {
            csdPath = path.join(tempDir, entry)
            break
          }
        }
      } catch {
        throw new Error(`Could not read workspace directory: ${tempDir}`)
      }

      if (!csdPath) throw new Error("No CSD file found in workspace.")

      // Parse CSD
      const csdContent = await Bun.file(csdPath).text()
      const structure = CsdParser.parse(csdContent)

      // Find k-rate parameters with numeric values
      const kParams = structure.parameters
        .filter((p) => p.rate === "k" && p.value && !isNaN(parseFloat(p.value)))
        .map((p) => ({
          name: p.name,
          value: parseFloat(p.value!),
          range: p.range ?? inferRange(p.name, parseFloat(p.value!)),
          line: p.line,
        }))

      if (kParams.length === 0) {
        return {
          title: "No parameters to vary",
          output: "No k-rate parameters found in the CSD. Add k-rate variables to enable auto-variation.",
          metadata: { csdPath, variations: [] },
        }
      }

      // Load or create design tree
      const csdBaseName = path.basename(csdPath)
      const snapshotHash = crypto.createHash("md5").update(csdContent).digest("hex").slice(0, 12)
      let tree = await DesignTree.load(csdPath)
      if (!tree) {
        tree = DesignTree.create(csdPath, snapshotHash, `Original ${csdBaseName}`)
      }

      // Generate variations
      const variations: Array<{ path: string; changes: Array<{ param: string; from: number; to: number }> }> = []

      for (let i = 0; i < count; i++) {
        let varContent = csdContent
        const changes: Array<{ param: string; from: number; to: number }> = []

        for (const param of kParams) {
          const newValue = perturbValue(param.value, variationRange, param.range[0], param.range[1])
          const rounded = Math.round(newValue * 10000) / 10000

          if (Math.abs(rounded - param.value) > 0.0001) {
            // Replace the value in the CSD content
            // Match the parameter assignment pattern: kName = VALUE or kName init VALUE
            const assignPattern = new RegExp(
              `(${escapeRegex(param.name)}\\s*=\\s*)${escapeRegex(String(param.value))}`,
            )
            const initPattern = new RegExp(
              `(${escapeRegex(param.name)}\\s+init\\s+)${escapeRegex(String(param.value))}`,
            )

            if (assignPattern.test(varContent)) {
              varContent = varContent.replace(assignPattern, `$1${rounded}`)
              changes.push({ param: param.name, from: param.value, to: rounded })
            } else if (initPattern.test(varContent)) {
              varContent = varContent.replace(initPattern, `$1${rounded}`)
              changes.push({ param: param.name, from: param.value, to: rounded })
            }
          }
        }

        // Write variation file
        const varFileName = `variation-${i + 1}.csd`
        const varPath = path.join(tempDir, varFileName)
        await Bun.write(varPath, varContent)

        // Add to design tree
        const varHash = crypto.createHash("md5").update(varContent).digest("hex").slice(0, 12)
        const description = `Auto-variation ${i + 1} (${variationRange})`
        const result = DesignTree.addNode(tree, {
          snapshotHash: varHash,
          description,
          sonicCharacter: `${variationRange} perturbation of ${changes.length} parameters`,
          sessionID: ctx.sessionID,
          metadata: { variationRange, changes },
        })
        tree = result.state

        variations.push({ path: varPath, changes })
      }

      // Save design tree
      await DesignTree.save(tree)

      // Build output
      const parts: string[] = []
      parts.push(`## Auto-Variations: ${count} x ${variationRange}`)
      parts.push("")

      for (let i = 0; i < variations.length; i++) {
        const v = variations[i]
        parts.push(`### variation-${i + 1}.csd`)
        if (v.changes.length === 0) {
          parts.push("  No significant changes (all parameters stayed close to original)")
        } else {
          for (const c of v.changes) {
            const pct = ((c.to - c.from) / c.from * 100).toFixed(1)
            parts.push(`  - ${c.param}: ${c.from} -> ${c.to} (${parseFloat(pct) > 0 ? "+" : ""}${pct}%)`)
          }
        }
        parts.push("")
      }

      parts.push(`Files written to: ${tempDir}`)
      parts.push("Render any variation with csound_render to hear the difference.")

      log.info("auto_variation", {
        count,
        variationRange,
        paramCount: kParams.length,
        csdPath,
      })

      return {
        title: `${count} ${variationRange} variations created`,
        output: parts.join("\n"),
        metadata: {
          csdPath,
          variations: variations.map((v) => ({
            path: v.path,
            changeCount: v.changes.length,
          })),
        },
      }
    },
  },
)

function escapeRegex(str: string): string {
  return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
}
