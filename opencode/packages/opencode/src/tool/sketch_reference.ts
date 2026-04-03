import z from "zod"
import fs from "fs/promises"
import path from "path"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"

const log = Log.create({ service: "tool.sketch-reference" })

const DESCRIPTION = `Add, remove, or list sonic references that guide sketch generation.

References are descriptions of sounds, artists, pieces, or sonic imagery that anchor the creative direction. For example: "Autechre's metallic textures", "a music box in a cathedral", "tape hiss and warmth", "Boards of Canada detuned nostalgia".

References persist in the session workspace and are available as prompt context for other sketch tools and alternative proposals.`

interface ReferenceData {
  references: string[]
  updatedAt: number
}

async function referencePath(sessionID: string): Promise<string> {
  const wsStatus = SessionWorkspace.status(sessionID)
  const dir = wsStatus.tempDir ?? path.join(process.env.HOME ?? "~", ".drc", "sessions", sessionID, "temp")
  await fs.mkdir(dir, { recursive: true })
  return path.join(dir, "sketch-references.json")
}

async function loadReferences(sessionID: string): Promise<ReferenceData> {
  try {
    const p = await referencePath(sessionID)
    const file = Bun.file(p)
    if (await file.exists()) {
      return await file.json() as ReferenceData
    }
  } catch {
    // File doesn't exist yet
  }
  return { references: [], updatedAt: Date.now() }
}

async function saveReferences(sessionID: string, data: ReferenceData): Promise<void> {
  const p = await referencePath(sessionID)
  data.updatedAt = Date.now()
  await Bun.write(p, JSON.stringify(data, null, 2))
}

export const SketchReferenceTool = Tool.define(
  "sketch_reference",
  {
    description: DESCRIPTION,
    parameters: z.object({
      action: z.enum(["add", "remove", "list"]).describe("Action to perform on sonic references"),
      reference: z
        .string()
        .optional()
        .describe("Sonic reference to add or remove (e.g., 'Autechre metallic textures', 'a music box in a cathedral')"),
    }),
    async execute(params, ctx) {
      const { action, reference } = params

      log.info("sketch reference action", { action, reference, sessionID: ctx.sessionID })

      const data = await loadReferences(ctx.sessionID)

      switch (action) {
        case "add":
          if (!reference) {
            return {
              title: "Missing reference",
              output: "Provide a reference string to add (e.g., 'Autechre metallic textures').",
              metadata: { action, references: data.references },
            }
          }
          if (!data.references.includes(reference)) {
            data.references.push(reference)
            await saveReferences(ctx.sessionID, data)
          }
          break

        case "remove":
          if (!reference) {
            return {
              title: "Missing reference",
              output: "Provide a reference string to remove.",
              metadata: { action, references: data.references },
            }
          }
          data.references = data.references.filter((r) => r !== reference)
          await saveReferences(ctx.sessionID, data)
          break

        case "list":
          // Just return current state
          break
      }

      const refList = data.references.length > 0
        ? data.references.map((r, i) => `${i + 1}. ${r}`).join("\n")
        : "(no references set)"

      return {
        title: action === "list"
          ? `${data.references.length} reference(s)`
          : `Updated references (${data.references.length})`,
        output: [
          `## Sonic References`,
          ``,
          refList,
          ``,
          data.references.length > 0
            ? `These references guide sketch generation and alternative proposals. The agent will use them as creative anchors.`
            : `Add sonic references to guide the creative direction (e.g., "Autechre's metallic textures", "a music box in a cathedral").`,
        ].join("\n"),
        metadata: {
          action,
          references: data.references,
        },
      }
    },
  },
)
