import z from "zod"
import fs from "fs/promises"
import path from "path"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"

const log = Log.create({ service: "tool.sketch-mood-palette" })

const DESCRIPTION = `Set, add to, remove from, or query the mood/texture palette for the current sketch session.

The mood palette anchors the aesthetic direction of a sketching session. Use descriptors like "dark", "crystalline", "warm", "percussive", "evolving", "metallic", "organic", etc.

The palette persists in the session workspace metadata and is available to other sketch tools for context.`

interface PaletteData {
  moods: string[]
  updatedAt: number
}

async function palettePath(sessionID: string): Promise<string> {
  const wsStatus = SessionWorkspace.status(sessionID)
  const dir = wsStatus.tempDir ?? path.join(process.env.HOME ?? "~", ".drc", "sessions", sessionID, "temp")
  await fs.mkdir(dir, { recursive: true })
  return path.join(dir, "sketch-palette.json")
}

async function loadPalette(sessionID: string): Promise<PaletteData> {
  try {
    const p = await palettePath(sessionID)
    const file = Bun.file(p)
    if (await file.exists()) {
      return await file.json() as PaletteData
    }
  } catch {
    // File doesn't exist yet
  }
  return { moods: [], updatedAt: Date.now() }
}

async function savePalette(sessionID: string, data: PaletteData): Promise<void> {
  const p = await palettePath(sessionID)
  data.updatedAt = Date.now()
  await Bun.write(p, JSON.stringify(data, null, 2))
}

export const SketchMoodPaletteTool = Tool.define(
  "sketch_mood_palette",
  {
    description: DESCRIPTION,
    parameters: z.object({
      action: z.enum(["set", "add", "remove", "get"]).describe("Action to perform on the mood palette"),
      moods: z
        .array(z.string())
        .optional()
        .describe("Mood/texture descriptors (e.g., 'dark', 'crystalline', 'warm', 'percussive', 'evolving')"),
    }),
    async execute(params, ctx) {
      const { action, moods = [] } = params
      const palette = await loadPalette(ctx.sessionID)

      log.info("mood palette action", { action, moods, sessionID: ctx.sessionID })

      switch (action) {
        case "set":
          palette.moods = moods
          await savePalette(ctx.sessionID, palette)
          break

        case "add":
          for (const mood of moods) {
            if (!palette.moods.includes(mood)) {
              palette.moods.push(mood)
            }
          }
          await savePalette(ctx.sessionID, palette)
          break

        case "remove":
          palette.moods = palette.moods.filter((m) => !moods.includes(m))
          await savePalette(ctx.sessionID, palette)
          break

        case "get":
          // Just return current state
          break
      }

      const moodList = palette.moods.length > 0 ? palette.moods.join(", ") : "(empty)"

      return {
        title: action === "get" ? `Palette: ${moodList}` : `Updated palette: ${moodList}`,
        output: [
          `Current mood palette: ${moodList}`,
          palette.moods.length > 0
            ? `Use these moods to guide sketch generation and alternative proposals.`
            : `No moods set. Add moods to anchor the aesthetic direction of this session.`,
        ].join("\n"),
        metadata: {
          action,
          moods: palette.moods,
        },
      }
    },
  },
)
