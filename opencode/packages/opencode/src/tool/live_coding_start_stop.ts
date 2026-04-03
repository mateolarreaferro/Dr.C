import z from "zod"
import { Tool } from "./tool"
import { LiveEngine } from "../csound/live-engine"
import { SessionWorkspace } from "../session/workspace"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.live-coding-start-stop" })

const DESCRIPTION = `Start or stop the live coding engine. When started, Csound runs in real-time with audio output to DAC, accepting channel updates and hot-reloads via UDP. Use 'start' with a CSD file path to begin live coding, 'stop' to end the session. If already running and 'start' is called, the engine restarts with the new CSD.`

export const LiveCodingStartStopTool = Tool.define(
  "live_coding_start_stop",
  {
    description: DESCRIPTION,
    parameters: z.object({
      action: z.enum(["start", "stop"]).describe("Whether to start or stop the live coding engine"),
      csdPath: z
        .string()
        .optional()
        .describe("Absolute path to the .csd file (required for 'start')"),
    }),
    async execute(params, ctx) {
      if (params.action === "start") {
        if (!params.csdPath) {
          throw new Error("csdPath is required when action is 'start'")
        }

        // Resolve through workspace
        const resolvedPath = SessionWorkspace.resolve(ctx.sessionID, params.csdPath)

        const file = Bun.file(resolvedPath)
        if (!(await file.exists())) {
          throw new Error(`File not found: ${resolvedPath}`)
        }

        if (!resolvedPath.endsWith(".csd")) {
          throw new Error(`Expected a .csd file, got: ${resolvedPath}`)
        }

        ctx.metadata({
          metadata: {
            status: "starting",
            csdPath: resolvedPath,
          },
        })

        const result = await LiveEngine.start(ctx.sessionID, resolvedPath)

        if (!result.success) {
          ctx.metadata({
            metadata: {
              status: "error",
              error: result.error,
            },
          })
          return {
            title: "Live engine failed to start",
            metadata: { success: false, error: result.error },
            output: `## Live Engine: FAILED TO START\n\n${result.error}`,
          }
        }

        const parts = [
          "## Live Engine: STARTED",
          `CSD: ${resolvedPath}`,
          `Detected channels (${result.channels.length}):`,
        ]

        if (result.channels.length > 0) {
          for (const ch of result.channels) {
            parts.push(`  - ${ch}`)
          }
          parts.push(
            "\nUse `live_coding_set_channel` to set channel values in real-time.",
            "Use `live_coding_hot_reload` to update the orchestra code while running.",
          )
        } else {
          parts.push("  (no chnget channels detected — add chnget-based parameters for real-time control)")
        }

        ctx.metadata({
          metadata: {
            status: "running",
            csdPath: resolvedPath,
            channels: result.channels,
          },
        })

        return {
          title: "Live engine started",
          metadata: { success: true, channels: result.channels },
          output: parts.join("\n"),
        }
      } else {
        // Stop
        const info = LiveEngine.getInfo(ctx.sessionID)
        if (!info) {
          return {
            title: "Live engine not running",
            metadata: { success: true },
            output: "## Live Engine: NOT RUNNING\n\nNo live engine is currently active for this session.",
          }
        }

        await LiveEngine.stop(ctx.sessionID)

        ctx.metadata({
          metadata: {
            status: "stopped",
          },
        })

        return {
          title: "Live engine stopped",
          metadata: { success: true },
          output: `## Live Engine: STOPPED\n\nLive coding session ended. CSD was: ${info.csdPath}`,
        }
      }
    },
  },
)
