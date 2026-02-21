import z from "zod"
import * as path from "path"
import { Tool } from "./tool"
import { File } from "../file"
import { FileWatcher } from "../file/watcher"
import { Bus } from "../bus"
import { FileTime } from "../file/time"
import { Instance } from "../project/instance"
import { createTwoFilesPatch } from "diff"
import DESCRIPTION from "./apply_csd_patch.txt"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"
import { CsdParser } from "../csound/parser"

const log = Log.create({ service: "apply-csd-patch" })

const VALID_SECTIONS = ["<Cabbage>", "<CsoundSynthesizer>", "<CsOptions>", "<CsInstruments>", "<CsScore>"]
const SECTION_PAIRS: Record<string, string> = {
  "<Cabbage>": "</Cabbage>",
  "<CsoundSynthesizer>": "</CsoundSynthesizer>",
  "<CsOptions>": "</CsOptions>",
  "<CsInstruments>": "</CsInstruments>",
  "<CsScore>": "</CsScore>",
}

export const ApplyCsdPatchTool = Tool.define(
  "apply_csd_patch",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file to patch"),
      patch: z.string().describe("The unified diff patch content to apply"),
      targetSection: z
        .enum(["Cabbage", "CsInstruments", "CsScore", "CsOptions"])
        .optional()
        .describe("Which CSD section this patch targets (for validation)"),
    }),
    async execute(params, ctx) {
      const rawPath = path.isAbsolute(params.filePath)
        ? params.filePath
        : path.join(Instance.directory, params.filePath)

      // Resolve through workspace if active (redirects to temp dir)
      const filePath = SessionWorkspace.resolve(ctx.sessionID, rawPath)

      if (!filePath.endsWith(".csd")) {
        throw new Error(`Expected a .csd file, got: ${filePath}`)
      }

      const file = Bun.file(filePath)
      if (!(await file.exists())) {
        throw new Error(`File not found: ${filePath}`)
      }

      let diff = ""
      let contentNew = ""
      let contentOld = ""

      await FileTime.withLock(filePath, async () => {
        await FileTime.assert(ctx.sessionID, filePath)

        contentOld = await file.text()

        // Validate the CSD structure
        validateCsdStructure(contentOld)

        // Apply the patch
        contentNew = applyPatch(contentOld, params.patch)

        // Validate the result still has valid CSD structure
        validateCsdStructure(contentNew)

        // Validate target section if specified
        if (params.targetSection) {
          const sectionTag = `<${params.targetSection}>`
          if (!contentNew.includes(sectionTag)) {
            throw new Error(`Target section ${sectionTag} not found in patched result`)
          }
        }

        diff = createTwoFilesPatch(filePath, filePath, contentOld, contentNew)

        await ctx.ask({
          permission: "edit",
          patterns: [path.relative(Instance.worktree, filePath)],
          always: ["*"],
          metadata: {
            filepath: filePath,
            diff,
          },
        })

        await Bun.write(filePath, contentNew)

        await Bus.publish(File.Event.Edited, { file: filePath })
        await Bus.publish(FileWatcher.Event.Updated, {
          file: filePath,
          event: "change",
        })
        FileTime.read(ctx.sessionID, filePath)

        // Mark workspace dirty after successful patch
        await SessionWorkspace.markDirty(ctx.sessionID)
      })

      // Check for locked parameter violations
      let lockedWarning = ""
      const locked = CsdParser.getLockedParams(ctx.sessionID)
      if (locked.size > 0) {
        try {
          const oldStructure = CsdParser.parse(contentOld)
          const newStructure = CsdParser.parse(contentNew)
          const violations: string[] = []
          for (const key of locked) {
            const [instrId, paramName] = key.includes(":") ? key.split(":", 2) : [undefined, key]
            const oldParam = oldStructure.parameters.find(
              (p) => p.name === paramName && (!instrId || p.instrument === instrId),
            )
            const newParam = newStructure.parameters.find(
              (p) => p.name === paramName && (!instrId || p.instrument === instrId),
            )
            if (oldParam?.value && newParam?.value && oldParam.value !== newParam.value) {
              violations.push(`${paramName}: ${oldParam.value} -> ${newParam.value}`)
            }
          }
          if (violations.length > 0) {
            lockedWarning = `\n\n**WARNING: Locked parameter(s) were modified:**\n${violations.map((v) => `- ${v}`).join("\n")}`
          }
        } catch {
          // Best-effort validation
        }
      }

      return {
        title: "Applied CSD patch",
        metadata: {
          filePath,
          targetSection: params.targetSection || "all",
        },
        output: `## Patch Applied Successfully\n\nFile: ${filePath}\n\n\`\`\`diff\n${diff}\n\`\`\`${lockedWarning}\n\n**Next step:** Run csound_compile to verify the patch compiles correctly.`,
      }
    },
  },
)

function validateCsdStructure(content: string): void {
  if (!content.includes("<CsoundSynthesizer>")) {
    throw new Error("Invalid CSD file: missing <CsoundSynthesizer> tag")
  }
  if (!content.includes("</CsoundSynthesizer>")) {
    throw new Error("Invalid CSD file: missing </CsoundSynthesizer> closing tag")
  }
  if (!content.includes("<CsInstruments>")) {
    throw new Error("Invalid CSD file: missing <CsInstruments> section")
  }
  if (!content.includes("</CsInstruments>")) {
    throw new Error("Invalid CSD file: missing </CsInstruments> closing tag")
  }
}

function applyPatch(original: string, patch: string): string {
  const lines = original.split("\n")
  const patchLines = patch.split("\n")

  // Parse unified diff hunks
  const hunks = parseUnifiedDiff(patchLines)

  if (hunks.length === 0) {
    // If no hunks found, try treating patch as direct replacement content
    throw new Error("Could not parse patch: no valid unified diff hunks found")
  }

  // Apply hunks in reverse order to preserve line numbers
  const sortedHunks = [...hunks].sort((a, b) => b.oldStart - a.oldStart)

  let result = [...lines]

  for (const hunk of sortedHunks) {
    const startIdx = hunk.oldStart - 1 // 0-indexed
    const endIdx = startIdx + hunk.oldCount

    // Verify context matches
    const originalSlice = result.slice(startIdx, endIdx)
    const expectedOld = hunk.oldLines

    // Fuzzy match: check if the old lines are roughly correct
    if (!fuzzyMatch(originalSlice, expectedOld)) {
      log.warn("hunk context mismatch", {
        expected: expectedOld.slice(0, 3),
        actual: originalSlice.slice(0, 3),
        line: hunk.oldStart,
      })
      throw new Error(
        `Patch hunk context mismatch at line ${hunk.oldStart}. ` +
          `Expected ${hunk.oldCount} lines but content doesn't match.`,
      )
    }

    result.splice(startIdx, hunk.oldCount, ...hunk.newLines)
  }

  return result.join("\n")
}

interface DiffHunk {
  oldStart: number
  oldCount: number
  newStart: number
  newCount: number
  oldLines: string[]
  newLines: string[]
}

function parseUnifiedDiff(lines: string[]): DiffHunk[] {
  const hunks: DiffHunk[] = []
  let i = 0

  while (i < lines.length) {
    // Look for hunk header: @@ -<old_start>,<old_count> +<new_start>,<new_count> @@
    const header = lines[i].match(/^@@\s+-(\d+)(?:,(\d+))?\s+\+(\d+)(?:,(\d+))?\s+@@/)
    if (!header) {
      i++
      continue
    }

    const hunk: DiffHunk = {
      oldStart: parseInt(header[1]),
      oldCount: parseInt(header[2] ?? "1"),
      newStart: parseInt(header[3]),
      newCount: parseInt(header[4] ?? "1"),
      oldLines: [],
      newLines: [],
    }

    i++

    while (i < lines.length && !lines[i].startsWith("@@") && !lines[i].startsWith("diff ")) {
      const line = lines[i]

      if (line.startsWith("-")) {
        hunk.oldLines.push(line.slice(1))
      } else if (line.startsWith("+")) {
        hunk.newLines.push(line.slice(1))
      } else if (line.startsWith(" ") || line === "") {
        // Context line — belongs to both old and new
        const content = line.startsWith(" ") ? line.slice(1) : line
        hunk.oldLines.push(content)
        hunk.newLines.push(content)
      } else if (line.startsWith("\\")) {
        // "\ No newline at end of file" — skip
      } else {
        break
      }

      i++
    }

    hunks.push(hunk)
  }

  return hunks
}

function fuzzyMatch(actual: string[], expected: string[]): boolean {
  if (actual.length !== expected.length) return false
  let mismatches = 0
  for (let i = 0; i < actual.length; i++) {
    if (actual[i].trim() !== expected[i].trim()) {
      mismatches++
    }
  }
  // Allow up to 10% mismatches for whitespace differences
  return mismatches <= Math.max(1, Math.floor(actual.length * 0.1))
}
