import { Log } from "../util/log"
import { Bus } from "../bus"
import { SessionWorkspace } from "../session/workspace"
import { DesignTree } from "../csound/design-tree"
import { MessageV2 } from "../session/message-v2"
import type { ServerWebSocket } from "bun"

const log = Log.create({ service: "companion-sync" })

export namespace CompanionSync {
  type WS = ServerWebSocket<unknown> | { send: (data: string) => void; close: () => void }

  const sessions = new Map<string, Set<WS>>()
  const unsubs: (() => void)[] = []

  export function register(sessionID: string, ws: WS) {
    let clients = sessions.get(sessionID)
    if (!clients) {
      clients = new Set()
      sessions.set(sessionID, clients)
    }
    clients.add(ws)
    log.info("companion connected", { sessionID, clients: clients.size })
  }

  export function unregister(sessionID: string, ws: WS) {
    const clients = sessions.get(sessionID)
    if (!clients) return
    clients.delete(ws)
    if (clients.size === 0) sessions.delete(sessionID)
    log.info("companion disconnected", { sessionID, clients: clients?.size ?? 0 })
  }

  export function broadcast(sessionID: string, event: unknown) {
    const clients = sessions.get(sessionID)
    if (!clients || clients.size === 0) return
    const data = JSON.stringify(event)
    for (const ws of clients) {
      try {
        ws.send(data)
      } catch {
        // dead socket — will be cleaned up on close
      }
    }
  }

  export function clientCount(sessionID: string): number {
    return sessions.get(sessionID)?.size ?? 0
  }

  /**
   * Subscribe to Bus events and relay to connected companions.
   * Call once at server startup.
   */
  export function init() {
    // CSD file changes — workspace activated means a CSD was written/initialized
    unsubs.push(
      Bus.subscribe(SessionWorkspace.Event.Activated, (event) => {
        broadcast(event.properties.sessionID, {
          type: "csd-update",
          sessionID: event.properties.sessionID,
          csdFilePath: event.properties.csdFilePath,
        })
      }),
    )

    // Design tree updates
    unsubs.push(
      Bus.subscribe(DesignTree.Event.TreeUpdated, (event) => {
        const csdFilePath = event.properties.csdFilePath
        // Broadcast to all sessions that might be watching this CSD
        for (const [sessionID] of sessions) {
          broadcast(sessionID, {
            type: "design-tree-update",
            csdFilePath,
          })
        }
      }),
    )

    unsubs.push(
      Bus.subscribe(DesignTree.Event.NodeAdded, (event) => {
        for (const [sessionID] of sessions) {
          broadcast(sessionID, {
            type: "design-tree-update",
            csdFilePath: event.properties.csdFilePath,
          })
        }
      }),
    )

    unsubs.push(
      Bus.subscribe(DesignTree.Event.NodeSelected, (event) => {
        for (const [sessionID] of sessions) {
          broadcast(sessionID, {
            type: "design-tree-update",
            csdFilePath: event.properties.csdFilePath,
          })
        }
      }),
    )

    // Message updates — relay chat messages to companions
    unsubs.push(
      Bus.subscribe(MessageV2.Event.Updated, (event) => {
        const msg = event.properties.info
        broadcast(msg.sessionID, {
          type: "chat-message",
          role: msg.role,
          sessionID: msg.sessionID,
          messageID: msg.id,
        })
      }),
    )

    // Part updates — relay streaming text to companions
    unsubs.push(
      Bus.subscribe(MessageV2.Event.PartUpdated, (event) => {
        const part = event.properties.part
        broadcast(part.sessionID, {
          type: "chat-part-updated",
          sessionID: part.sessionID,
          messageID: part.messageID,
          partID: part.id,
          partType: part.type,
        })
      }),
    )

    log.info("companion sync initialized")
  }

  export function dispose() {
    for (const unsub of unsubs) unsub()
    unsubs.length = 0
    sessions.clear()
  }
}
