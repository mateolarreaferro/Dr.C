import z from "zod"
import { Tool } from "./tool"
import { LiveEngine } from "../csound/live-engine"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.live-coding-set-channel" })

const DESCRIPTION = `Set a channel value on the running live Csound instance. The channel must correspond to a chnget-based parameter in the active CSD. Values are sent via UDP and take effect immediately in the running audio engine. Use this for real-time parameter tweaking: adjusting cutoff frequencies, gain levels, modulation depths, etc.`

export const LiveCodingSetChannelTool = Tool.define(
  "live_coding_set_channel",
  {
    description: DESCRIPTION,
    parameters: z.object({
      channel: z.string().describe("The channel name (must match a chnget channel in the running CSD)"),
      value: z.number().describe("The numeric value to set on the channel"),
    }),
    async execute(params, ctx) {
      if (!LiveEngine.isRunning(ctx.sessionID)) {
        throw new Error(
          "No live engine is running for this session. Use live_coding_start_stop with action 'start' first.",
        )
      }

      await LiveEngine.setChannel(ctx.sessionID, params.channel, params.value)

      const allChannels = LiveEngine.getChannels(ctx.sessionID)

      const parts = [
        `## Channel Set: ${params.channel} = ${params.value}`,
        "",
        "Current channel values:",
      ]

      for (const [name, value] of Object.entries(allChannels)) {
        const marker = name === params.channel ? " ◀" : ""
        parts.push(`  ${name}: ${value}${marker}`)
      }

      ctx.metadata({
        metadata: {
          channel: params.channel,
          value: params.value,
        },
      })

      return {
        title: `Set ${params.channel} = ${params.value}`,
        metadata: { channel: params.channel, value: params.value },
        output: parts.join("\n"),
      }
    },
  },
)
