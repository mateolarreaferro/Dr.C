import z from "zod"
import { Tool } from "./tool"
import { LiveEngine } from "../csound/live-engine"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.live-coding-hot-reload" })

const DESCRIPTION = `Hot-reload the orchestra code on the running live Csound instance. Sends the new CsInstruments section to the running Csound process via UDP, which compiles and applies it without restarting. The audio engine continues running — only the instrument definitions are updated. Use this after modifying the CSD to hear changes immediately.`

export const LiveCodingHotReloadTool = Tool.define(
  "live_coding_hot_reload",
  {
    description: DESCRIPTION,
    parameters: z.object({
      csdContent: z
        .string()
        .describe("The full CSD content (including <CsoundSynthesizer> tags). The <CsInstruments> section will be extracted and sent for live compilation."),
    }),
    async execute(params, ctx) {
      if (!LiveEngine.isRunning(ctx.sessionID)) {
        throw new Error(
          "No live engine is running for this session. Use live_coding_start_stop with action 'start' first.",
        )
      }

      ctx.metadata({
        metadata: {
          status: "recompiling",
        },
      })

      const result = await LiveEngine.recompile(ctx.sessionID, params.csdContent)

      if (!result.success) {
        ctx.metadata({
          metadata: {
            status: "error",
            error: result.error,
          },
        })
        return {
          title: "Hot-reload failed",
          metadata: { success: false, error: result.error },
          output: `## Hot-Reload: FAILED\n\n${result.error}\n\nThe live engine is still running with the previous orchestra code.`,
        }
      }

      const channels = LiveEngine.getChannels(ctx.sessionID)
      const channelList = Object.keys(channels)

      const parts = [
        "## Hot-Reload: SUCCESS",
        "",
        "The orchestra code has been updated in the running Csound instance.",
        "Audio continues without interruption.",
      ]

      if (channelList.length > 0) {
        parts.push("", "Active channels:")
        for (const [name, value] of Object.entries(channels)) {
          parts.push(`  ${name}: ${value}`)
        }
      }

      ctx.metadata({
        metadata: {
          status: "success",
          channels: channelList,
        },
      })

      return {
        title: "Hot-reload successful",
        metadata: { success: true, channels: channelList },
        output: parts.join("\n"),
      }
    },
  },
)
