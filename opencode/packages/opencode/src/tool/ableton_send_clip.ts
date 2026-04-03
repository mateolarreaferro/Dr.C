import z from "zod"
import path from "path"
import { Tool } from "./tool"
import DESCRIPTION from "./ableton_send_clip.txt"
import { Log } from "../util/log"
import { SessionWorkspace } from "../session/workspace"
import { AbletonBridge } from "../osc/ableton-bridge"

const log = Log.create({ service: "ableton-send-clip" })

export const AbletonSendClipTool = Tool.define(
  "ableton_send_clip",
  {
    description: DESCRIPTION,
    parameters: z.object({
      wavPath: z.string().describe("Absolute path to the .wav file to send"),
      trackIndex: z
        .number()
        .int()
        .min(0)
        .optional()
        .describe("Target track index in Ableton (default 0)"),
      clipSlot: z
        .number()
        .int()
        .min(0)
        .optional()
        .describe("Target clip slot index (default 0)"),
      fireAfterSend: z
        .boolean()
        .optional()
        .describe("Immediately fire the clip after sending (default false)"),
    }),
    async execute(params, ctx) {
      const trackIndex = params.trackIndex ?? 0
      const clipSlot = params.clipSlot ?? 0
      const fireAfterSend = params.fireAfterSend ?? false

      // Resolve path through workspace
      const wavPath = SessionWorkspace.resolve(ctx.sessionID, params.wavPath)

      const file = Bun.file(wavPath)
      if (!(await file.exists())) {
        throw new Error(`WAV file not found: ${wavPath}`)
      }

      if (!wavPath.endsWith(".wav")) {
        throw new Error(`Expected a .wav file, got: ${wavPath}`)
      }

      if (!AbletonBridge.isConnected()) {
        throw new Error(
          "Not connected to Ableton Live. Ensure Ableton is running with AbletonOSC and use the /ableton connect command first.",
        )
      }

      ctx.metadata({
        metadata: {
          status: "sending",
          wavPath,
          trackIndex,
          clipSlot,
        },
      })

      await AbletonBridge.sendClip(trackIndex, clipSlot, wavPath)

      if (fireAfterSend) {
        await AbletonBridge.fireClip(trackIndex, clipSlot)
      }

      const parts: string[] = []
      parts.push(`## Ableton: Clip Sent`)
      parts.push(`File: ${path.basename(wavPath)}`)
      parts.push(`Track: ${trackIndex}, Clip Slot: ${clipSlot}`)
      if (fireAfterSend) {
        parts.push(`Clip fired (playing)`)
      }

      ctx.metadata({
        metadata: {
          status: "success",
          wavPath,
          trackIndex,
          clipSlot,
          fired: fireAfterSend,
        },
      })

      return {
        title: `Sent ${path.basename(wavPath)} to track ${trackIndex}`,
        metadata: {
          success: true,
          wavPath,
          trackIndex,
          clipSlot,
          fired: fireAfterSend,
        },
        output: parts.join("\n"),
      }
    },
  },
)
