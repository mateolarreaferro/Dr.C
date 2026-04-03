import z from "zod"
import fs from "fs/promises"
import path from "path"
import { Tool } from "./tool"
import DESCRIPTION from "./export_ableton_clip.txt"
import { SessionWorkspace } from "../session/workspace"
import { Log } from "../util/log"
import { Instance } from "../project/instance"

const log = Log.create({ service: "export-ableton-clip" })

export const ExportAbletonClipTool = Tool.define(
  "export_ableton_clip",
  {
    description: DESCRIPTION,
    parameters: z.object({
      trackIndex: z.number().int().min(0).optional().describe("Target track number in Ableton (default 0)"),
      clipSlot: z.number().int().min(0).optional().describe("Target clip slot (default 0)"),
      fire: z.boolean().optional().describe("Immediately fire/play the clip after import (default true)"),
    }),
    async execute(params, ctx) {
      const trackIndex = params.trackIndex ?? 0
      const clipSlot = params.clipSlot ?? 0
      const fire = params.fire ?? true

      // Find the most recent WAV in the session workspace
      const wsStatus = SessionWorkspace.status(ctx.sessionID)
      if (!wsStatus.active || !wsStatus.tempDir) {
        throw new Error("No active workspace for this session. Render audio first.")
      }

      const tempDir = wsStatus.tempDir
      const entries = await fs.readdir(tempDir)
      const wavFiles = entries.filter((e) => e.endsWith(".wav"))

      if (wavFiles.length === 0) {
        throw new Error("No WAV files found in workspace. Render audio first using csound_render.")
      }

      // Find the most recently modified WAV
      let mostRecent = { name: wavFiles[0], mtime: 0 }
      for (const wav of wavFiles) {
        const stat = await fs.stat(path.join(tempDir, wav))
        if (stat.mtimeMs > mostRecent.mtime) {
          mostRecent = { name: wav, mtime: stat.mtimeMs }
        }
      }

      const wavPath = path.join(tempDir, mostRecent.name)

      ctx.metadata({
        metadata: {
          status: "exporting",
          wavPath,
          trackIndex,
          clipSlot,
        },
      })

      // Check if the Ableton bridge is connected
      // The OSC bridge module may not exist yet — try dynamic import
      let bridgeConnected = false
      try {
        const bridgeMod = await import("../osc/ableton-bridge")
        if (bridgeMod.AbletonBridge && typeof bridgeMod.AbletonBridge.isConnected === "function") {
          bridgeConnected = bridgeMod.AbletonBridge.isConnected()
        }
      } catch {
        // Bridge module not available — fall through to manual export
        log.info("ableton bridge not available, falling back to file export")
      }

      const parts: string[] = []

      if (bridgeConnected) {
        try {
          const bridgeMod = await import("../osc/ableton-bridge")
          await bridgeMod.AbletonBridge.sendClip({
            wavPath,
            trackIndex,
            clipSlot,
            fire,
          })

          parts.push(`## Ableton Clip Export: SUCCESS`)
          parts.push(``)
          parts.push(`WAV: ${wavPath}`)
          parts.push(`Track: ${trackIndex}, Slot: ${clipSlot}`)
          parts.push(`Fire: ${fire ? "yes" : "no"}`)
          parts.push(``)
          parts.push(`Clip sent to Ableton Live via OSC bridge.`)

          ctx.metadata({
            metadata: {
              status: "success",
              wavPath,
              trackIndex,
              clipSlot,
              method: "bridge",
            },
          })
        } catch (err) {
          // Bridge send failed — fall back to file copy
          log.error("bridge send failed, falling back to file export", { error: String(err) })
          bridgeConnected = false
        }
      }

      if (!bridgeConnected) {
        // Copy WAV to a user-accessible location
        const exportDir = path.join(Instance.directory, "ableton-clips")
        await fs.mkdir(exportDir, { recursive: true })
        const exportPath = path.join(exportDir, mostRecent.name)
        const content = await Bun.file(wavPath).arrayBuffer()
        await Bun.write(exportPath, content)

        parts.push(`## Ableton Clip Export: FILE READY`)
        parts.push(``)
        parts.push(`WAV copied to: ${exportPath}`)
        parts.push(`Target: Track ${trackIndex}, Slot ${clipSlot}`)
        parts.push(``)
        parts.push(`### Manual Import Instructions`)
        parts.push(`1. Open Ableton Live`)
        parts.push(`2. Drag the WAV file into Track ${trackIndex}, Clip Slot ${clipSlot}`)
        parts.push(`3. Or use File > Import to browse to: ${exportDir}`)
        parts.push(``)
        parts.push(`*Ableton OSC bridge not connected. Start the bridge for direct clip insertion.*`)

        ctx.metadata({
          metadata: {
            status: "success",
            wavPath: exportPath,
            trackIndex,
            clipSlot,
            method: "file",
          },
        })
      }

      return {
        title: `Exported clip to ${bridgeConnected ? "Ableton" : "ableton-clips/"}`,
        metadata: {
          wavPath,
          trackIndex,
          clipSlot,
          bridgeConnected,
          status: "success",
        },
        output: parts.join("\n"),
      }
    },
  },
)
