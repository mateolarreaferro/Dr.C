import fs from "fs/promises"
import path from "path"
import os from "os"
import { Log } from "../util/log"

export namespace MemoryStore {
  const log = Log.create({ service: "memory.store" })

  // === Types ===

  export interface SessionSummary {
    sessionID: string
    timestamp: number
    summary: string
    techniques: string[]
    renderCount: number
    exported: boolean
    designTreeNodes: number
    duration: number
  }

  export interface SonicIdentity {
    aestheticPreferences: string[]
    signatureChains: string[]
    referenceArtists: string[]
    avoidances: string[]
    frequentOpcodes: Record<string, number>
    lastUpdated: number
  }

  export interface TechniqueEntry {
    date: number
    sessionID: string
    description: string
    outcome: "success" | "partial" | "failed"
    csdSnippet?: string
    lesson?: string
  }

  export interface TechniqueJournal {
    technique: string
    entries: TechniqueEntry[]
    preferredPatterns: string[]
  }

  // === Paths ===

  function basePath(): string {
    return path.join(os.homedir(), ".drc", "memory")
  }

  function sessionsDir(): string {
    return path.join(basePath(), "sessions")
  }

  function techniquesDir(): string {
    return path.join(basePath(), "techniques")
  }

  function identityPath(): string {
    return path.join(basePath(), "identity.json")
  }

  // === Session Summaries ===

  export async function saveSessionSummary(summary: SessionSummary): Promise<void> {
    try {
      const dir = sessionsDir()
      await fs.mkdir(dir, { recursive: true })
      const filePath = path.join(dir, `${summary.sessionID}.json`)
      await fs.writeFile(filePath, JSON.stringify(summary, null, 2), "utf-8")
    } catch (e) {
      log.error("failed to save session summary", { error: e })
    }
  }

  export async function getRecentSummaries(count: number): Promise<SessionSummary[]> {
    try {
      const dir = sessionsDir()
      await fs.mkdir(dir, { recursive: true })
      const files = await fs.readdir(dir)
      const jsonFiles = files.filter((f) => f.endsWith(".json"))

      const summaries: SessionSummary[] = []
      for (const file of jsonFiles) {
        try {
          const raw = await fs.readFile(path.join(dir, file), "utf-8")
          summaries.push(JSON.parse(raw))
        } catch {
          // Skip corrupted files
        }
      }

      // Sort by timestamp descending, return top N
      summaries.sort((a, b) => b.timestamp - a.timestamp)
      return summaries.slice(0, count)
    } catch (e) {
      log.error("failed to get recent summaries", { error: e })
      return []
    }
  }

  export async function searchSummaries(query: string): Promise<SessionSummary[]> {
    try {
      const all = await getRecentSummaries(100)
      const lower = query.toLowerCase()
      return all.filter(
        (s) =>
          s.summary.toLowerCase().includes(lower) ||
          s.techniques.some((t) => t.toLowerCase().includes(lower)),
      )
    } catch (e) {
      log.error("failed to search summaries", { error: e })
      return []
    }
  }

  // === Sonic Identity ===

  const DEFAULT_IDENTITY: SonicIdentity = {
    aestheticPreferences: [],
    signatureChains: [],
    referenceArtists: [],
    avoidances: [],
    frequentOpcodes: {},
    lastUpdated: Date.now(),
  }

  export async function getSonicIdentity(): Promise<SonicIdentity> {
    try {
      const raw = await fs.readFile(identityPath(), "utf-8")
      return { ...DEFAULT_IDENTITY, ...JSON.parse(raw) }
    } catch {
      return { ...DEFAULT_IDENTITY }
    }
  }

  export async function updateSonicIdentity(partial: Partial<SonicIdentity>): Promise<void> {
    try {
      const current = await getSonicIdentity()
      const updated: SonicIdentity = {
        ...current,
        ...partial,
        lastUpdated: Date.now(),
      }

      // Merge arrays (deduplicate)
      if (partial.aestheticPreferences) {
        updated.aestheticPreferences = [...new Set([...current.aestheticPreferences, ...partial.aestheticPreferences])]
      }
      if (partial.signatureChains) {
        updated.signatureChains = [...new Set([...current.signatureChains, ...partial.signatureChains])]
      }
      if (partial.referenceArtists) {
        updated.referenceArtists = [...new Set([...current.referenceArtists, ...partial.referenceArtists])]
      }
      if (partial.avoidances) {
        updated.avoidances = [...new Set([...current.avoidances, ...partial.avoidances])]
      }

      // Merge opcode counts
      if (partial.frequentOpcodes) {
        for (const [opcode, count] of Object.entries(partial.frequentOpcodes)) {
          updated.frequentOpcodes[opcode] = (current.frequentOpcodes[opcode] || 0) + count
        }
      }

      const dir = basePath()
      await fs.mkdir(dir, { recursive: true })
      await fs.writeFile(identityPath(), JSON.stringify(updated, null, 2), "utf-8")
    } catch (e) {
      log.error("failed to update sonic identity", { error: e })
    }
  }

  // === Technique Journal ===

  function techniqueFilePath(technique: string): string {
    // Sanitize technique name for file system
    const safe = technique.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "")
    return path.join(techniquesDir(), `${safe}.json`)
  }

  export async function getTechniqueJournal(technique: string): Promise<TechniqueJournal | null> {
    try {
      const raw = await fs.readFile(techniqueFilePath(technique), "utf-8")
      return JSON.parse(raw)
    } catch {
      return null
    }
  }

  export async function addTechniqueEntry(technique: string, entry: TechniqueEntry): Promise<void> {
    try {
      const dir = techniquesDir()
      await fs.mkdir(dir, { recursive: true })

      let journal = await getTechniqueJournal(technique)
      if (!journal) {
        journal = {
          technique,
          entries: [],
          preferredPatterns: [],
        }
      }

      journal.entries.push(entry)

      // Keep only last 50 entries per technique
      if (journal.entries.length > 50) {
        journal.entries = journal.entries.slice(-50)
      }

      await fs.writeFile(techniqueFilePath(technique), JSON.stringify(journal, null, 2), "utf-8")
    } catch (e) {
      log.error("failed to add technique entry", { error: e, technique })
    }
  }

  export async function listTechniques(): Promise<string[]> {
    try {
      const dir = techniquesDir()
      await fs.mkdir(dir, { recursive: true })
      const files = await fs.readdir(dir)
      const techniques: string[] = []
      for (const file of files) {
        if (!file.endsWith(".json")) continue
        try {
          const raw = await fs.readFile(path.join(dir, file), "utf-8")
          const journal: TechniqueJournal = JSON.parse(raw)
          techniques.push(journal.technique)
        } catch {
          // Skip corrupted
        }
      }
      return techniques
    } catch {
      return []
    }
  }

  export async function searchTechniques(query: string): Promise<TechniqueJournal[]> {
    try {
      const dir = techniquesDir()
      await fs.mkdir(dir, { recursive: true })
      const files = await fs.readdir(dir)
      const lower = query.toLowerCase()
      const results: TechniqueJournal[] = []

      for (const file of files) {
        if (!file.endsWith(".json")) continue
        try {
          const raw = await fs.readFile(path.join(dir, file), "utf-8")
          const journal: TechniqueJournal = JSON.parse(raw)
          const matches =
            journal.technique.toLowerCase().includes(lower) ||
            journal.entries.some((e) => e.description.toLowerCase().includes(lower))
          if (matches) {
            results.push(journal)
          }
        } catch {
          // Skip corrupted
        }
      }

      return results
    } catch (e) {
      log.error("failed to search techniques", { error: e })
      return []
    }
  }
}
