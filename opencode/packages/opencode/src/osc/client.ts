import dgram from "dgram"
import { Log } from "@/util/log"

const log = Log.create({ service: "osc.client" })

/**
 * Minimal OSC binary encoding/decoding for UDP communication.
 * Supports string (s), int32 (i), and float32 (f) types only.
 */

export type OscArgument = string | number
export type OscArgType = "s" | "i" | "f"

export interface OscMessage {
  address: string
  args: OscArgument[]
}

// --- Encoding ---

function padToFourBytes(len: number): number {
  return len + (4 - (len % 4)) % 4
}

function encodeString(str: string): Buffer {
  const nullTerminated = Buffer.from(str + "\0", "utf-8")
  const padded = padToFourBytes(nullTerminated.length)
  const buf = Buffer.alloc(padded)
  nullTerminated.copy(buf)
  return buf
}

function encodeInt32(value: number): Buffer {
  const buf = Buffer.alloc(4)
  buf.writeInt32BE(value, 0)
  return buf
}

function encodeFloat32(value: number): Buffer {
  const buf = Buffer.alloc(4)
  buf.writeFloatBE(value, 0)
  return buf
}

function inferType(arg: OscArgument): OscArgType {
  if (typeof arg === "string") return "s"
  if (Number.isInteger(arg)) return "i"
  return "f"
}

export function encodeOscMessage(address: string, args: OscArgument[]): Buffer {
  const parts: Buffer[] = []

  // Address
  parts.push(encodeString(address))

  // Type tag string: comma + type chars
  const types = args.map(inferType)
  const typeTag = "," + types.join("")
  parts.push(encodeString(typeTag))

  // Arguments
  for (let i = 0; i < args.length; i++) {
    const type = types[i]
    const arg = args[i]
    switch (type) {
      case "s":
        parts.push(encodeString(arg as string))
        break
      case "i":
        parts.push(encodeInt32(arg as number))
        break
      case "f":
        parts.push(encodeFloat32(arg as number))
        break
    }
  }

  return Buffer.concat(parts)
}

// --- Decoding ---

function readString(buf: Buffer, offset: number): { value: string; offset: number } {
  let end = offset
  while (end < buf.length && buf[end] !== 0) end++
  const value = buf.toString("utf-8", offset, end)
  const padded = end + 1 // skip null terminator
  const newOffset = padded + (4 - (padded % 4)) % 4
  return { value, offset: newOffset }
}

export function decodeOscMessage(buf: Buffer): OscMessage | null {
  try {
    if (buf.length < 4) return null

    // Read address
    const addr = readString(buf, 0)
    if (!addr.value.startsWith("/")) return null

    // Read type tag
    const typeTag = readString(buf, addr.offset)
    if (!typeTag.value.startsWith(",")) return null

    const types = typeTag.value.slice(1) // remove leading comma
    const args: OscArgument[] = []
    let offset = typeTag.offset

    for (const type of types) {
      switch (type) {
        case "s": {
          const s = readString(buf, offset)
          args.push(s.value)
          offset = s.offset
          break
        }
        case "i": {
          args.push(buf.readInt32BE(offset))
          offset += 4
          break
        }
        case "f": {
          args.push(buf.readFloatBE(offset))
          offset += 4
          break
        }
        default:
          // Unknown type — skip
          break
      }
    }

    return { address: addr.value, args }
  } catch (e) {
    log.error("failed to decode OSC message", { error: e })
    return null
  }
}

// --- UDP Client ---

export interface OscClientOptions {
  host: string
  port: number
}

const DEFAULT_OPTIONS: OscClientOptions = {
  host: "127.0.0.1",
  port: 11000,
}

type ReplyHandler = (msg: OscMessage) => void

class OscClient {
  private socket: dgram.Socket | null = null
  private options: OscClientOptions
  private connected = false
  private replyHandlers = new Map<string, ReplyHandler[]>()
  private heartbeatTimer: ReturnType<typeof setInterval> | null = null
  private lastPong = 0

  constructor(options: Partial<OscClientOptions> = {}) {
    this.options = { ...DEFAULT_OPTIONS, ...options }
  }

  async connect(options?: Partial<OscClientOptions>): Promise<void> {
    if (options) {
      this.options = { ...this.options, ...options }
    }

    if (this.socket) {
      this.disconnect()
    }

    return new Promise((resolve, reject) => {
      const socket = dgram.createSocket("udp4")

      socket.on("message", (msg: Buffer) => {
        const decoded = decodeOscMessage(msg)
        if (!decoded) return
        log.info("osc recv", { address: decoded.address, args: decoded.args })

        // Track pong for heartbeat
        this.lastPong = Date.now()

        // Dispatch to reply handlers
        const handlers = this.replyHandlers.get(decoded.address)
        if (handlers) {
          for (const handler of handlers) {
            handler(decoded)
          }
        }

        // Also dispatch to wildcard handlers
        const wildcardHandlers = this.replyHandlers.get("*")
        if (wildcardHandlers) {
          for (const handler of wildcardHandlers) {
            handler(decoded)
          }
        }
      })

      socket.on("error", (err) => {
        log.error("osc socket error", { error: err })
        if (!this.connected) {
          reject(err)
        }
      })

      socket.bind(0, () => {
        this.socket = socket
        this.connected = true
        this.lastPong = Date.now()
        this.startHeartbeat()
        log.info("osc client connected", { host: this.options.host, port: this.options.port })
        resolve()
      })
    })
  }

  disconnect(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer)
      this.heartbeatTimer = null
    }
    if (this.socket) {
      try {
        this.socket.close()
      } catch {}
      this.socket = null
    }
    this.connected = false
    this.replyHandlers.clear()
    log.info("osc client disconnected")
  }

  isConnected(): boolean {
    return this.connected
  }

  /**
   * Returns true if we received a reply within the last heartbeat window.
   */
  isAlive(): boolean {
    if (!this.connected) return false
    // Consider alive if last pong was within 10 seconds
    return Date.now() - this.lastPong < 10000
  }

  async send(address: string, ...args: OscArgument[]): Promise<void> {
    if (!this.socket || !this.connected) {
      throw new Error("OSC client not connected")
    }

    const buf = encodeOscMessage(address, args)
    return new Promise((resolve, reject) => {
      this.socket!.send(buf, 0, buf.length, this.options.port, this.options.host, (err) => {
        if (err) {
          log.error("osc send error", { address, error: err })
          reject(err)
        } else {
          log.info("osc send", { address, args })
          resolve()
        }
      })
    })
  }

  /**
   * Send a message and wait for a reply on the same address.
   */
  async sendAndReceive(address: string, args: OscArgument[], timeoutMs = 5000): Promise<OscMessage> {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.removeReplyHandler(address, handler)
        reject(new Error(`OSC reply timeout for ${address}`))
      }, timeoutMs)

      const handler: ReplyHandler = (msg) => {
        clearTimeout(timer)
        this.removeReplyHandler(address, handler)
        resolve(msg)
      }

      this.addReplyHandler(address, handler)
      this.send(address, ...args).catch((err) => {
        clearTimeout(timer)
        this.removeReplyHandler(address, handler)
        reject(err)
      })
    })
  }

  addReplyHandler(address: string, handler: ReplyHandler): void {
    const handlers = this.replyHandlers.get(address) || []
    handlers.push(handler)
    this.replyHandlers.set(address, handlers)
  }

  removeReplyHandler(address: string, handler: ReplyHandler): void {
    const handlers = this.replyHandlers.get(address)
    if (!handlers) return
    const idx = handlers.indexOf(handler)
    if (idx >= 0) handlers.splice(idx, 1)
    if (handlers.length === 0) this.replyHandlers.delete(address)
  }

  private startHeartbeat(): void {
    // Ping AbletonOSC every 5 seconds to check liveness
    this.heartbeatTimer = setInterval(async () => {
      if (!this.connected || !this.socket) return
      try {
        await this.send("/live/test")
      } catch {
        // Ignore send failures during heartbeat
      }
    }, 5000)
  }
}

/**
 * Singleton OSC client for Ableton communication.
 */
export const AbletonOSC = new OscClient()
