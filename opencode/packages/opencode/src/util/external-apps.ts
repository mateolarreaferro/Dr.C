import { $ } from "bun"
import { spawn } from "child_process"
import fs from "fs/promises"

export namespace ExternalApps {
  async function exists(p: string): Promise<boolean> {
    try {
      await fs.access(p)
      return true
    } catch {
      return false
    }
  }

  export async function findCsoundQt(): Promise<string | null> {
    // macOS .app bundle
    if (await exists("/Applications/CsoundQt.app")) return "/Applications/CsoundQt.app"
    // Homebrew or PATH
    try {
      const result = await $`which csoundqt 2>/dev/null`.quiet().nothrow().text()
      if (result.trim()) return result.trim()
    } catch {}
    // Homebrew prefix
    try {
      const result = await $`brew --prefix csoundqt 2>/dev/null`.quiet().nothrow().text()
      if (result.trim()) return result.trim()
    } catch {}
    return null
  }

  export async function findCabbage(): Promise<string | null> {
    if (await exists("/Applications/Cabbage.app")) return "/Applications/Cabbage.app"
    try {
      const result = await $`which cabbage 2>/dev/null`.quiet().nothrow().text()
      if (result.trim()) return result.trim()
    } catch {}
    return null
  }

  export function openInApp(appPath: string, filePath: string): void {
    if (appPath.endsWith(".app")) {
      // macOS: use `open -a` for .app bundles
      spawn("open", ["-a", appPath, filePath], { detached: true, stdio: "ignore" }).unref()
    } else {
      spawn(appPath, [filePath], { detached: true, stdio: "ignore" }).unref()
    }
  }
}
