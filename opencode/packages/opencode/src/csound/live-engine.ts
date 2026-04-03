import { spawn, type ChildProcess } from "child_process"
import * as dgram from "dgram"
import { Log } from "../util/log"
import { Bus } from "../bus"
import { BusEvent } from "../bus/bus-event"
import { CsdParser } from "./parser"
import { CsoundProcessRegistry } from "./process-registry"
import z from "zod"

const log = Log.create({ service: "csound.live-engine" })

export namespace LiveEngine {
  // --- Bus Events ---

  export const Event = {
    Started: BusEvent.define(
      "live-engine.started",
      z.object({
        sessionID: z.string(),
        channels: z.array(z.string()),
        port: z.number(),
      }),
    ),
    Stopped: BusEvent.define(
      "live-engine.stopped",
      z.object({ sessionID: z.string() }),
    ),
    ChannelSet: BusEvent.define(
      "live-engine.channel-set",
      z.object({
        sessionID: z.string(),
        channel: z.string(),
        value: z.number(),
      }),
    ),
  }

  // --- Internal State ---

  interface LiveInstance {
    process: ChildProcess
    port: number
    channels: Record<string, number>
    csdPath: string
    startedAt: number
  }

  const instances = new Map<string, LiveInstance>()
  const usedPorts = new Set<number>()

  const PORT_MIN = 10000
  const PORT_MAX = 10100

  function allocatePort(): number {
    for (let port = PORT_MIN; port <= PORT_MAX; port++) {
      if (!usedPorts.has(port)) {
        usedPorts.add(port)
        return port
      }
    }
    throw new Error("No available UDP ports for live coding (all ports 10000-10100 in use)")
  }

  function releasePort(port: number): void {
    usedPorts.delete(port)
  }

  /**
   * Extract channel names from CSD content by looking for `chnget` patterns.
   */
  function detectChannels(csdContent: string): string[] {
    try {
      const structure = CsdParser.parse(csdContent)
      const channelNames: string[] = []
      for (const param of structure.parameters) {
        if (param.source === "chnget" && param.channel) {
          if (!channelNames.includes(param.channel)) {
            channelNames.push(param.channel)
          }
        }
      }
      return channelNames
    } catch (e) {
      log.warn("failed to parse CSD for channel detection", { error: e })
      return []
    }
  }

  /**
   * Rewrite a CSD to ensure it works for live real-time output:
   * - Add `-odac` to CsOptions if not present
   * - Add `--port=PORT` to CsOptions for UDP control
   * - Add `f 0 3600` to CsScore if no indefinite event exists
   */
  function rewriteCsdForLive(csdContent: string, port: number): string {
    let result = csdContent

    // Ensure -odac in CsOptions
    const csOptionsMatch = result.match(/<CsOptions>([\s\S]*?)<\/CsOptions>/)
    if (csOptionsMatch) {
      let options = csOptionsMatch[1]
      if (!options.includes("-odac")) {
        options = options.trimEnd() + "\n-odac\n"
      }
      // Remove any -o <file> output directives that conflict with -odac
      options = options.replace(/-o\s+\S+\.wav/g, "")
      // Add --port for UDP
      if (!options.includes("--port=")) {
        options = options.trimEnd() + `\n--port=${port}\n`
      }
      result = result.replace(/<CsOptions>[\s\S]*?<\/CsOptions>/, `<CsOptions>${options}</CsOptions>`)
    } else {
      // No CsOptions section — inject one
      result = result.replace(
        /<CsoundSynthesizer>/,
        `<CsoundSynthesizer>\n<CsOptions>\n-odac\n--port=${port}\n</CsOptions>`,
      )
    }

    // Ensure f 0 3600 in CsScore for indefinite performance
    const csScoreMatch = result.match(/<CsScore>([\s\S]*?)<\/CsScore>/)
    if (csScoreMatch) {
      const score = csScoreMatch[1]
      // Check if there's already an indefinite f 0 event
      if (!score.match(/f\s+0\s+\d+\s+\d+/)) {
        const newScore = score.trimEnd() + "\nf 0 3600\n"
        result = result.replace(/<CsScore>[\s\S]*?<\/CsScore>/, `<CsScore>${newScore}</CsScore>`)
      }
    }

    return result
  }

  /**
   * Send a UDP message to a running Csound instance.
   */
  function sendUdp(port: number, message: string): Promise<void> {
    return new Promise((resolve, reject) => {
      const client = dgram.createSocket("udp4")
      const buf = Buffer.from(message)
      client.send(buf, 0, buf.length, port, "127.0.0.1", (err) => {
        client.close()
        if (err) reject(err)
        else resolve()
      })
    })
  }

  /**
   * Start a live Csound instance from a CSD file.
   */
  export async function start(
    sessionID: string,
    csdPath: string,
  ): Promise<{ success: boolean; channels: string[]; error?: string }> {
    // Stop existing instance if running
    if (instances.has(sessionID)) {
      await stop(sessionID)
    }

    // Read and rewrite CSD
    const file = Bun.file(csdPath)
    if (!(await file.exists())) {
      return { success: false, channels: [], error: `File not found: ${csdPath}` }
    }

    const csdContent = await file.text()
    const channels = detectChannels(csdContent)
    let port: number

    try {
      port = allocatePort()
    } catch (e: any) {
      return { success: false, channels: [], error: e.message }
    }

    const rewrittenCsd = rewriteCsdForLive(csdContent, port)

    // Write rewritten CSD to a temp file
    const liveCsdPath = csdPath.replace(/\.csd$/, ".live.csd")
    await Bun.write(liveCsdPath, rewrittenCsd)

    return new Promise((resolve) => {
      let started = false
      let stderr = ""

      const proc = spawn("csound", ["-d", "-m0", liveCsdPath], {
        stdio: ["ignore", "pipe", "pipe"],
        detached: process.platform !== "win32",
      })

      CsoundProcessRegistry.register(proc, "render")

      proc.stderr?.on("data", (chunk: Buffer) => {
        stderr += chunk.toString()
        // Csound prints to stderr when it starts performing
        if (!started && (stderr.includes("rtaudio:") || stderr.includes("real-time") || stderr.includes("SECTION 1"))) {
          started = true
          const instance: LiveInstance = {
            process: proc,
            port,
            channels: Object.fromEntries(channels.map((ch) => [ch, 0])),
            csdPath,
            startedAt: Date.now(),
          }
          instances.set(sessionID, instance)

          Bus.publish(LiveEngine.Event.Started, {
            sessionID,
            channels,
            port,
          }).catch(() => {})

          log.info("live engine started", { sessionID, port, channels })
          resolve({ success: true, channels })
        }
      })

      proc.stdout?.on("data", () => {})

      proc.once("exit", (code) => {
        log.info("live engine process exited", { sessionID, code })
        if (!started) {
          releasePort(port)
          const errorMsg = stderr.trim().split("\n").slice(-5).join("\n")
          resolve({
            success: false,
            channels: [],
            error: `Csound exited with code ${code}. ${errorMsg}`,
          })
        } else {
          // Process crashed/stopped after starting
          cleanup(sessionID)
        }
      })

      proc.once("error", (err) => {
        log.error("live engine process error", { sessionID, error: err })
        if (!started) {
          releasePort(port)
          if (err.message.includes("ENOENT")) {
            resolve({
              success: false,
              channels: [],
              error: "csound command not found. Please install Csound: https://csound.com/download.html",
            })
          } else {
            resolve({ success: false, channels: [], error: err.message })
          }
        } else {
          cleanup(sessionID)
        }
      })

      // Timeout: if Csound doesn't start within 10 seconds, fail
      setTimeout(() => {
        if (!started) {
          try {
            if (proc.pid && process.platform !== "win32") {
              process.kill(-proc.pid, "SIGTERM")
            } else {
              proc.kill("SIGTERM")
            }
          } catch {}
          releasePort(port)
          const errorMsg = stderr.trim().split("\n").slice(-5).join("\n")
          resolve({
            success: false,
            channels: [],
            error: `Csound failed to start within 10 seconds. ${errorMsg}`,
          })
        }
      }, 10_000)
    })
  }

  /**
   * Set a channel value on the running Csound instance via UDP.
   */
  export async function setChannel(sessionID: string, name: string, value: number): Promise<void> {
    const instance = instances.get(sessionID)
    if (!instance) {
      throw new Error("No live engine running for this session")
    }

    const message = `chnset ${value}, "${name}"\n`
    await sendUdp(instance.port, message)

    instance.channels[name] = value

    Bus.publish(LiveEngine.Event.ChannelSet, {
      sessionID,
      channel: name,
      value,
    }).catch(() => {})

    log.info("channel set", { sessionID, channel: name, value })
  }

  /**
   * Get current channel values for a running session.
   */
  export function getChannels(sessionID: string): Record<string, number> {
    const instance = instances.get(sessionID)
    if (!instance) return {}
    return { ...instance.channels }
  }

  /**
   * Hot-reload the orchestra section without restarting Csound.
   * Sends the CsInstruments content via UDP for live compilation.
   */
  export async function recompile(
    sessionID: string,
    newCsdContent: string,
  ): Promise<{ success: boolean; error?: string }> {
    const instance = instances.get(sessionID)
    if (!instance) {
      return { success: false, error: "No live engine running for this session" }
    }

    // Extract CsInstruments section
    const instrMatch = newCsdContent.match(/<CsInstruments>([\s\S]*?)<\/CsInstruments>/)
    if (!instrMatch) {
      return { success: false, error: "No <CsInstruments> section found in provided CSD content" }
    }

    const orchestraCode = instrMatch[1].trim()

    try {
      // Send orchestra code via UDP — Csound compiles it live
      await sendUdp(instance.port, orchestraCode + "\n")

      // Update detected channels from new content
      const newChannels = detectChannels(newCsdContent)
      for (const ch of newChannels) {
        if (!(ch in instance.channels)) {
          instance.channels[ch] = 0
        }
      }

      // Also update the stored CSD file for future reference
      const liveCsdPath = instance.csdPath.replace(/\.csd$/, ".live.csd")
      const rewritten = rewriteCsdForLive(newCsdContent, instance.port)
      await Bun.write(liveCsdPath, rewritten)

      log.info("hot-reload successful", { sessionID })
      return { success: true }
    } catch (e: any) {
      log.error("hot-reload failed", { sessionID, error: e })
      return { success: false, error: e.message }
    }
  }

  /**
   * Stop the live Csound instance for a session.
   */
  export async function stop(sessionID: string): Promise<void> {
    const instance = instances.get(sessionID)
    if (!instance) return

    try {
      // Send a score end event via UDP to cleanly stop
      await sendUdp(instance.port, "e\n").catch(() => {})
    } catch {}

    // Give Csound a moment to clean up, then force kill
    await new Promise<void>((resolve) => {
      const killTimer = setTimeout(() => {
        try {
          if (instance.process.pid && process.platform !== "win32") {
            process.kill(-instance.process.pid, "SIGTERM")
          } else {
            instance.process.kill("SIGTERM")
          }
        } catch {}
        resolve()
      }, 1000)

      instance.process.once("exit", () => {
        clearTimeout(killTimer)
        resolve()
      })
    })

    cleanup(sessionID)
    log.info("live engine stopped", { sessionID })
  }

  /**
   * Check if a live instance is running for a session.
   */
  export function isRunning(sessionID: string): boolean {
    return instances.has(sessionID)
  }

  /**
   * Get info about a running live instance.
   */
  export function getInfo(
    sessionID: string,
  ): { csdPath: string; channels: Record<string, number>; startedAt: number; port: number } | null {
    const instance = instances.get(sessionID)
    if (!instance) return null
    return {
      csdPath: instance.csdPath,
      channels: { ...instance.channels },
      startedAt: instance.startedAt,
      port: instance.port,
    }
  }

  /**
   * Internal cleanup after a process exits.
   */
  function cleanup(sessionID: string): void {
    const instance = instances.get(sessionID)
    if (!instance) return

    releasePort(instance.port)
    instances.delete(sessionID)

    Bus.publish(LiveEngine.Event.Stopped, { sessionID }).catch(() => {})
  }

  /**
   * Stop all running live instances (for shutdown).
   */
  export async function stopAll(): Promise<void> {
    const sessionIDs = [...instances.keys()]
    for (const sid of sessionIDs) {
      await stop(sid)
    }
  }
}
