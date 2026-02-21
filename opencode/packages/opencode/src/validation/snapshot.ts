import fs from "fs/promises"
import path from "path"
import { Log } from "../util/log"
import { Global } from "../global"
import crypto from "crypto"
import { SessionWorkspace } from "../session/workspace"

const log = Log.create({ service: "csd-snapshot" })

export namespace CsdSnapshot {
  const SNAPSHOT_DIR = path.join(Global.Path.data, "csd-snapshots")

  export interface SnapshotEntry {
    hash: string
    filePath: string
    timestamp: number
    size: number
  }

  async function ensureDir() {
    await fs.mkdir(SNAPSHOT_DIR, { recursive: true })
  }

  function hashContent(content: string): string {
    return crypto.createHash("sha256").update(content).digest("hex").slice(0, 16)
  }

  function snapshotPath(filePath: string): string {
    const encoded = Buffer.from(filePath).toString("base64url")
    return path.join(SNAPSHOT_DIR, encoded)
  }

  export async function capture(filePath: string, sessionID?: string): Promise<string> {
    await ensureDir()

    // Use workspace-resolved path if session workspace is active
    const resolvedPath = sessionID ? SessionWorkspace.resolve(sessionID, filePath) : filePath
    const content = await Bun.file(resolvedPath).text()
    const hash = hashContent(content)
    const dir = snapshotPath(filePath)
    await fs.mkdir(dir, { recursive: true })

    const snapshotFile = path.join(dir, `${hash}.csd`)
    const metaFile = path.join(dir, `${hash}.json`)

    await Bun.write(snapshotFile, content)
    await Bun.write(
      metaFile,
      JSON.stringify({
        hash,
        filePath,
        timestamp: Date.now(),
        size: content.length,
      }),
    )

    log.info("snapshot captured", { filePath, hash })
    return hash
  }

  export async function restore(filePath: string, hash: string, sessionID?: string): Promise<void> {
    const dir = snapshotPath(filePath)
    const snapshotFile = path.join(dir, `${hash}.csd`)

    const file = Bun.file(snapshotFile)
    if (!(await file.exists())) {
      throw new Error(`Snapshot ${hash} not found for ${filePath}`)
    }

    // Write to workspace-resolved path if session workspace is active
    const resolvedPath = sessionID ? SessionWorkspace.resolve(sessionID, filePath) : filePath
    const content = await file.text()
    await Bun.write(resolvedPath, content)

    log.info("snapshot restored", { filePath, hash })
  }

  export async function listHistory(filePath: string): Promise<SnapshotEntry[]> {
    const dir = snapshotPath(filePath)

    try {
      const entries = await fs.readdir(dir)
      const metaFiles = entries.filter((e) => e.endsWith(".json"))

      const snapshots: SnapshotEntry[] = []

      for (const metaFile of metaFiles) {
        try {
          const content = await Bun.file(path.join(dir, metaFile)).json()
          snapshots.push(content as SnapshotEntry)
        } catch {
          // Skip corrupted metadata
        }
      }

      return snapshots.sort((a, b) => b.timestamp - a.timestamp)
    } catch {
      return []
    }
  }

  export async function getContent(filePath: string, hash: string): Promise<string> {
    const dir = snapshotPath(filePath)
    const snapshotFile = path.join(dir, `${hash}.csd`)

    const file = Bun.file(snapshotFile)
    if (!(await file.exists())) {
      throw new Error(`Snapshot ${hash} not found for ${filePath}`)
    }

    return file.text()
  }
}
