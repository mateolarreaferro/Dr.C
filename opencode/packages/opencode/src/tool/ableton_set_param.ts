import z from "zod"
import { Tool } from "./tool"
import DESCRIPTION from "./ableton_set_param.txt"
import { Log } from "../util/log"
import { AbletonBridge } from "../osc/ableton-bridge"

const log = Log.create({ service: "ableton-set-param" })

export const AbletonSetParamTool = Tool.define(
  "ableton_set_param",
  {
    description: DESCRIPTION,
    parameters: z.object({
      trackIndex: z
        .number()
        .int()
        .min(0)
        .describe("Track index in Ableton (0-based)"),
      deviceIndex: z
        .number()
        .int()
        .min(0)
        .describe("Device index on the track (0-based)"),
      paramIndex: z
        .number()
        .int()
        .min(0)
        .describe("Parameter index within the device (0-based)"),
      value: z
        .number()
        .min(0)
        .max(1)
        .describe("Parameter value (normalized 0.0 to 1.0)"),
    }),
    async execute(params, ctx) {
      const { trackIndex, deviceIndex, paramIndex, value } = params

      if (!AbletonBridge.isConnected()) {
        throw new Error(
          "Not connected to Ableton Live. Ensure Ableton is running with AbletonOSC and use the /ableton connect command first.",
        )
      }

      ctx.metadata({
        metadata: {
          status: "setting",
          trackIndex,
          deviceIndex,
          paramIndex,
          value,
        },
      })

      await AbletonBridge.setParam(trackIndex, deviceIndex, paramIndex, value)

      const parts: string[] = []
      parts.push(`## Ableton: Parameter Set`)
      parts.push(`Track: ${trackIndex}, Device: ${deviceIndex}, Param: ${paramIndex}`)
      parts.push(`Value: ${value}`)

      ctx.metadata({
        metadata: {
          status: "success",
          trackIndex,
          deviceIndex,
          paramIndex,
          value,
        },
      })

      return {
        title: `Set param [${trackIndex}/${deviceIndex}/${paramIndex}] = ${value}`,
        metadata: {
          success: true,
          trackIndex,
          deviceIndex,
          paramIndex,
          value,
        },
        output: parts.join("\n"),
      }
    },
  },
)
