import fs from "fs/promises"
import path from "path"
import z from "zod"
import { Global } from "../global"
import { Log } from "../util/log"
import { Bus } from "../bus"
import { BusEvent } from "../bus/bus-event"

const log = Log.create({ service: "session.workspace" })

const SESSIONS_DIR = path.join(Global.Path.data, "sessions")
const MAX_AGE_DAYS = 7

export namespace SessionWorkspace {
  export const Event = {
    Saved: BusEvent.define(
      "workspace.saved",
      z.object({ sessionID: z.string(), files: z.array(z.string()) }),
    ),
    Discarded: BusEvent.define("workspace.discarded", z.object({ sessionID: z.string() })),
    Activated: BusEvent.define(
      "workspace.activated",
      z.object({ sessionID: z.string(), csdFilePath: z.string() }),
    ),
  }

  interface WorkspaceState {
    sessionID: string
    originalCsdPath: string
    tempDir: string
    createdAt: number
    unsavedChanges: boolean
  }

  const active = new Map<string, WorkspaceState>()

  function sessionDir(sessionID: string): string {
    return path.join(SESSIONS_DIR, sessionID, "temp")
  }

  function statePath(sessionID: string): string {
    return path.join(SESSIONS_DIR, sessionID, "workspace.json")
  }

  /**
   * Initialize workspace for a session — copies CSD to temp dir.
   * Called lazily when csound agent first writes/patches a CSD.
   */
  export async function init(sessionID: string, csdFilePath: string): Promise<void> {
    if (active.has(sessionID)) return

    const tempDir = sessionDir(sessionID)
    await fs.mkdir(tempDir, { recursive: true })

    // Copy CSD to temp dir
    const csdFile = Bun.file(csdFilePath)
    if (await csdFile.exists()) {
      const tempCsd = path.join(tempDir, path.basename(csdFilePath))
      await Bun.write(tempCsd, await csdFile.text())
      log.info("workspace initialized", { sessionID, csdFilePath, tempCsd })
    }

    const state: WorkspaceState = {
      sessionID,
      originalCsdPath: csdFilePath,
      tempDir,
      createdAt: Date.now(),
      unsavedChanges: false,
    }

    active.set(sessionID, state)
    await persistState(sessionID, state)
    await Bus.publish(SessionWorkspace.Event.Activated, { sessionID, csdFilePath })
  }

  /**
   * Resolve a project file path to its temp workspace equivalent.
   * Only intercepts .csd and .wav files when workspace is active.
   * Returns original path if no workspace or not a CSD/WAV.
   */
  export function resolve(sessionID: string, filePath: string): string {
    const ws = active.get(sessionID)
    if (!ws) return filePath

    const ext = path.extname(filePath).toLowerCase()
    if (ext !== ".csd" && ext !== ".wav") return filePath

    // If file is already in the temp dir, return as-is
    if (filePath.startsWith(ws.tempDir)) return filePath

    // Redirect to temp dir
    return path.join(ws.tempDir, path.basename(filePath))
  }

  /**
   * Mark workspace as having unsaved changes.
   */
  export async function markDirty(sessionID: string): Promise<void> {
    const ws = active.get(sessionID)
    if (!ws) return
    if (ws.unsavedChanges) return
    ws.unsavedChanges = true
    await persistState(sessionID, ws)
  }

  /**
   * Save temp CSD+WAV files back to the project directory.
   */
  export async function save(sessionID: string): Promise<string[]> {
    const ws = active.get(sessionID)
    if (!ws) throw new Error(`No active workspace for session ${sessionID}`)

    const tempDir = ws.tempDir
    const projectDir = path.dirname(ws.originalCsdPath)
    const saved: string[] = []

    try {
      const entries = await fs.readdir(tempDir)
      for (const entry of entries) {
        const ext = path.extname(entry).toLowerCase()
        if (ext === ".csd" || ext === ".wav") {
          const src = path.join(tempDir, entry)
          const dst = path.join(projectDir, entry)
          const content = await Bun.file(src).arrayBuffer()
          await Bun.write(dst, content)
          saved.push(dst)
          log.info("saved to project", { src, dst })
        }
      }
    } catch (err) {
      log.error("save failed", { error: String(err) })
      throw err
    }

    ws.unsavedChanges = false
    await persistState(sessionID, ws)
    await Bus.publish(SessionWorkspace.Event.Saved, { sessionID, files: saved })

    return saved
  }

  /**
   * Discard temp workspace — removes temp dir.
   */
  export async function discard(sessionID: string): Promise<void> {
    const ws = active.get(sessionID)
    if (!ws) return

    try {
      await fs.rm(path.join(SESSIONS_DIR, sessionID), { recursive: true, force: true })
    } catch (err) {
      log.warn("discard cleanup failed", { error: String(err) })
    }

    active.delete(sessionID)
    await Bus.publish(SessionWorkspace.Event.Discarded, { sessionID })
    log.info("workspace discarded", { sessionID })
  }

  /**
   * Check if a workspace is active for a session.
   */
  export function isActive(sessionID: string): boolean {
    return active.has(sessionID)
  }

  /**
   * Get workspace status for a session.
   */
  export function status(sessionID: string): { active: boolean; unsavedChanges: boolean; tempDir?: string } {
    const ws = active.get(sessionID)
    if (!ws) return { active: false, unsavedChanges: false }
    return {
      active: true,
      unsavedChanges: ws.unsavedChanges,
      tempDir: ws.tempDir,
    }
  }

  /**
   * Get the original CSD file path for a workspace.
   */
  export function originalPath(sessionID: string): string | undefined {
    return active.get(sessionID)?.originalCsdPath
  }

  /**
   * Load persisted workspace state on startup (for session resume).
   */
  export async function loadIfExists(sessionID: string): Promise<boolean> {
    if (active.has(sessionID)) return true

    try {
      const stateFile = Bun.file(statePath(sessionID))
      if (!(await stateFile.exists())) return false

      const state = (await stateFile.json()) as WorkspaceState
      const tempDirExists = await fs
        .stat(state.tempDir)
        .then(() => true)
        .catch(() => false)

      if (!tempDirExists) return false

      active.set(sessionID, state)
      log.info("workspace restored", { sessionID })
      return true
    } catch {
      return false
    }
  }

  /**
   * Remove old session workspaces (>7 days by default).
   */
  export async function cleanup(maxAgeDays: number = MAX_AGE_DAYS): Promise<number> {
    let cleaned = 0
    try {
      const sessionsExists = await fs
        .stat(SESSIONS_DIR)
        .then(() => true)
        .catch(() => false)
      if (!sessionsExists) return 0

      const entries = await fs.readdir(SESSIONS_DIR)
      const cutoff = Date.now() - maxAgeDays * 24 * 60 * 60 * 1000

      for (const entry of entries) {
        const stateFile = path.join(SESSIONS_DIR, entry, "workspace.json")
        try {
          const content = await Bun.file(stateFile).json()
          if (content.createdAt < cutoff) {
            await fs.rm(path.join(SESSIONS_DIR, entry), { recursive: true, force: true })
            cleaned++
          }
        } catch {
          // If state file missing/corrupt, check dir mtime
          try {
            const stat = await fs.stat(path.join(SESSIONS_DIR, entry))
            if (stat.mtimeMs < cutoff) {
              await fs.rm(path.join(SESSIONS_DIR, entry), { recursive: true, force: true })
              cleaned++
            }
          } catch {}
        }
      }

      if (cleaned > 0) {
        log.info("cleaned old workspaces", { cleaned })
      }
    } catch (err) {
      log.warn("cleanup failed", { error: String(err) })
    }
    return cleaned
  }

  async function persistState(sessionID: string, state: WorkspaceState): Promise<void> {
    try {
      const dir = path.join(SESSIONS_DIR, sessionID)
      await fs.mkdir(dir, { recursive: true })
      await Bun.write(statePath(sessionID), JSON.stringify(state, null, 2))
    } catch (err) {
      log.warn("failed to persist workspace state", { error: String(err) })
    }
  }
}
