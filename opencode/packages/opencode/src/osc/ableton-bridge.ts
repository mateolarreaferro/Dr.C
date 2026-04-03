import { AbletonOSC, type OscClientOptions } from "./client"
import { Bus } from "@/bus"
import { BusEvent } from "@/bus/bus-event"
import { Log } from "@/util/log"
import z from "zod"

const log = Log.create({ service: "osc.ableton-bridge" })

export namespace AbletonBridge {
  // --- Bus Events ---

  export const ConnectionChanged = BusEvent.define(
    "ableton.connection.changed",
    z.object({
      connected: z.boolean(),
      host: z.string(),
      port: z.number(),
    }),
  )

  // --- Connection ---

  export async function connect(options?: Partial<OscClientOptions>): Promise<void> {
    await AbletonOSC.connect(options)

    // Send a test message to verify Ableton is listening
    try {
      const reply = await AbletonOSC.sendAndReceive("/live/test", [], 3000)
      log.info("ableton connection verified", { reply: reply.args })
    } catch {
      log.warn("ableton did not respond to test — connection established but Ableton may not be running AbletonOSC")
    }

    await Bus.publish(ConnectionChanged, {
      connected: true,
      host: options?.host ?? "127.0.0.1",
      port: options?.port ?? 11000,
    })
  }

  export function disconnect(): void {
    const wasConnected = AbletonOSC.isConnected()
    AbletonOSC.disconnect()

    if (wasConnected) {
      Bus.publish(ConnectionChanged, {
        connected: false,
        host: "127.0.0.1",
        port: 11000,
      }).catch(() => {})
    }
  }

  export function isConnected(): boolean {
    return AbletonOSC.isConnected()
  }

  // --- Clip Operations ---

  /**
   * Send a rendered WAV file to an Ableton clip slot.
   *
   * AbletonOSC flow:
   * 1. Create an empty clip in the slot
   * 2. Set the clip's file path to the WAV
   */
  export async function sendClip(trackIndex: number, clipSlot: number, wavPath: string): Promise<void> {
    if (!AbletonOSC.isConnected()) {
      throw new Error("Not connected to Ableton Live. Call connect() first.")
    }

    // Create a clip in the slot (duration will be auto-detected from WAV)
    await AbletonOSC.send("/live/clip_slot/delete_clip", trackIndex, clipSlot)
    // Insert the audio file — AbletonOSC uses set/clip_file or we create and set
    await AbletonOSC.send("/live/clip_slot/create_audio_clip/path", trackIndex, clipSlot, wavPath)

    log.info("sent clip to ableton", { trackIndex, clipSlot, wavPath })
  }

  // --- Device Parameters ---

  /**
   * Set a device parameter value in Ableton.
   * Value is normalized 0-1.
   */
  export async function setParam(
    trackIndex: number,
    deviceIndex: number,
    paramIndex: number,
    value: number,
  ): Promise<void> {
    if (!AbletonOSC.isConnected()) {
      throw new Error("Not connected to Ableton Live. Call connect() first.")
    }

    await AbletonOSC.send("/live/device/set/parameter/value", trackIndex, deviceIndex, paramIndex, value)

    log.info("set ableton param", { trackIndex, deviceIndex, paramIndex, value })
  }

  // --- Track Operations ---

  /**
   * Create a new track in Ableton.
   * Returns the new track index from the reply.
   */
  export async function createTrack(
    type: "audio" | "midi" | "return",
    name: string,
  ): Promise<{ trackIndex: number }> {
    if (!AbletonOSC.isConnected()) {
      throw new Error("Not connected to Ableton Live. Call connect() first.")
    }

    const addressMap = {
      audio: "/live/song/create_audio_track",
      midi: "/live/song/create_midi_track",
      return: "/live/song/create_return_track",
    } as const

    const address = addressMap[type]

    // Create track at index -1 (append)
    const reply = await AbletonOSC.sendAndReceive(address, [-1], 5000)
    const trackIndex = typeof reply.args[0] === "number" ? reply.args[0] : -1

    // Set track name if we got a valid index
    if (trackIndex >= 0 && name) {
      await AbletonOSC.send("/live/track/set/name", trackIndex, name)
    }

    log.info("created ableton track", { type, name, trackIndex })
    return { trackIndex }
  }

  /**
   * Get the list of tracks from Ableton.
   */
  export async function getTrackList(): Promise<{ tracks: Array<{ index: number; name: string }> }> {
    if (!AbletonOSC.isConnected()) {
      throw new Error("Not connected to Ableton Live. Call connect() first.")
    }

    const reply = await AbletonOSC.sendAndReceive("/live/song/get/track_data", ["track.name"], 5000)

    // AbletonOSC returns track data as alternating index/name pairs
    const tracks: Array<{ index: number; name: string }> = []
    const args = reply.args
    for (let i = 0; i < args.length; i += 2) {
      if (typeof args[i] === "number" && typeof args[i + 1] === "string") {
        tracks.push({ index: args[i] as number, name: args[i + 1] as string })
      }
    }

    return { tracks }
  }

  /**
   * Get the current tempo from Ableton.
   */
  export async function getTempo(): Promise<number> {
    if (!AbletonOSC.isConnected()) {
      throw new Error("Not connected to Ableton Live. Call connect() first.")
    }

    const reply = await AbletonOSC.sendAndReceive("/live/song/get/tempo", [], 3000)
    return typeof reply.args[0] === "number" ? reply.args[0] : 120
  }

  /**
   * Fire (launch) a clip in a clip slot.
   */
  export async function fireClip(trackIndex: number, clipSlot: number): Promise<void> {
    if (!AbletonOSC.isConnected()) {
      throw new Error("Not connected to Ableton Live. Call connect() first.")
    }

    await AbletonOSC.send("/live/clip_slot/fire", trackIndex, clipSlot)
    log.info("fired clip", { trackIndex, clipSlot })
  }
}
