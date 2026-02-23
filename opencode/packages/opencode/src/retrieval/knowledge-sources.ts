import path from "path"
import fs from "fs/promises"
import os from "os"
import crypto from "crypto"

export namespace KnowledgeSources {
  export interface Source {
    id: string
    name: string
    path: string
    type: "book" | "reference" | "custom"
    chunkConfig: {
      maxTokens: number
      overlapTokens: number
    }
  }

  const defaults: Source[] = [
    {
      id: "csound-book",
      name: "The Csound Book",
      path: "csound_book.txt",
      type: "book",
      chunkConfig: {
        maxTokens: 350,
        overlapTokens: 30,
      },
    },
    {
      id: "floss-manual",
      name: "FLOSS Csound Manual",
      path: "floss_manual.txt",
      type: "reference",
      chunkConfig: {
        maxTokens: 300,
        overlapTokens: 25,
      },
    },
    {
      id: "opcode-reference",
      name: "Csound Opcode Reference",
      path: "opcode_reference.txt",
      type: "reference",
      chunkConfig: {
        maxTokens: 250,
        overlapTokens: 20,
      },
    },
  ]

  export function dataDir(): string {
    return path.join(os.homedir(), ".drc", "knowledge")
  }

  export function customDir(): string {
    return path.join(dataDir(), "custom")
  }

  export function bundlePath(): string {
    return path.join(bundleDir(), "bundle.json")
  }

  /** Directory containing all knowledge bundles. */
  export function bundleDir(): string {
    return path.join(
      // Check resources dir relative to module location
      path.resolve(import.meta.dir, "..", ".."),
      "resources",
      "knowledge",
    )
  }

  /** Path to the core bundle (opcode cards + knowledge graph). */
  export function coreBundlePath(): string {
    return path.join(bundleDir(), "bundle-core.json")
  }

  /** Path to the CSD examples bundle. */
  export function examplesBundlePath(): string {
    return path.join(bundleDir(), "bundle-examples.json")
  }

  /** Path to the CSD content bundle (lazy-loaded). */
  export function csdContentBundlePath(): string {
    return path.join(bundleDir(), "bundle-csd.json")
  }

  export function list(worktree: string): Source[] {
    // Only return sources that actually exist on disk
    return defaults
      .map((s) => ({
        ...s,
        path: s.path.startsWith("/") ? s.path : path.join(worktree, s.path),
      }))
  }

  /**
   * List all sources including custom user files from ~/.drc/knowledge/custom/
   */
  export async function listWithCustom(worktree: string): Promise<Source[]> {
    const sources = list(worktree)

    // Scan custom directory
    try {
      const customPath = customDir()
      await fs.mkdir(customPath, { recursive: true })
      const entries = await fs.readdir(customPath)

      for (const entry of entries) {
        if (entry.endsWith(".txt") || entry.endsWith(".md")) {
          const basename = path.basename(entry, path.extname(entry))
          const id = `custom-${basename.toLowerCase().replace(/[^a-z0-9]+/g, "-")}`

          sources.push({
            id,
            name: `Custom: ${basename}`,
            path: path.join(customPath, entry),
            type: "custom",
            chunkConfig: {
              maxTokens: 300,
              overlapTokens: 25,
            },
          })
        }
      }
    } catch {
      // Custom dir doesn't exist yet — that's fine
    }

    return sources
  }

  /**
   * Compute a version hash from source file hashes.
   * When sources update, the version hash changes, triggering a rebuild.
   */
  export async function computeVersionHash(sources: Source[]): Promise<string> {
    const hashes: string[] = []

    for (const source of sources) {
      try {
        const content = await Bun.file(source.path).text()
        const hash = crypto.createHash("sha256").update(content).digest("hex").slice(0, 16)
        hashes.push(`${source.id}:${hash}`)
      } catch {
        hashes.push(`${source.id}:missing`)
      }
    }

    return crypto.createHash("sha256").update(hashes.sort().join("|")).digest("hex").slice(0, 16)
  }
}
