import z from "zod"
import { Tool } from "./tool"
import DESCRIPTION from "./ableton_create_track.txt"
import { Log } from "../util/log"
import { AbletonBridge } from "../osc/ableton-bridge"

const log = Log.create({ service: "ableton-create-track" })

export const AbletonCreateTrackTool = Tool.define(
  "ableton_create_track",
  {
    description: DESCRIPTION,
    parameters: z.object({
      type: z
        .enum(["audio", "midi", "return"])
        .describe("Track type: audio, midi, or return"),
      name: z
        .string()
        .describe("Display name for the new track"),
    }),
    async execute(params, ctx) {
      const { type, name } = params

      if (!AbletonBridge.isConnected()) {
        throw new Error(
          "Not connected to Ableton Live. Ensure Ableton is running with AbletonOSC and use the /ableton connect command first.",
        )
      }

      ctx.metadata({
        metadata: {
          status: "creating",
          type,
          name,
        },
      })

      const { trackIndex } = await AbletonBridge.createTrack(type, name)

      const parts: string[] = []
      parts.push(`## Ableton: Track Created`)
      parts.push(`Type: ${type}`)
      parts.push(`Name: ${name}`)
      parts.push(`Track Index: ${trackIndex}`)

      ctx.metadata({
        metadata: {
          status: "success",
          type,
          name,
          trackIndex,
        },
      })

      return {
        title: `Created ${type} track "${name}" (index ${trackIndex})`,
        metadata: {
          success: true,
          type,
          name,
          trackIndex,
        },
        output: parts.join("\n"),
      }
    },
  },
)
