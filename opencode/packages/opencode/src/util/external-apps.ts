import { $ } from "bun"
import { spawn } from "child_process"
import fs from "fs/promises"
import { homedir } from "os"
import path from "path"
import { Config } from "../config/config"

export namespace ExternalApps {
  async function exists(p: string): Promise<boolean> {
    try {
      await fs.access(p)
      return true
    } catch {
      return false
    }
  }

  async function workshopPath(key: "csoundqt_path" | "cabbage_path"): Promise<string | null> {
    try {
      const global = await Config.getGlobal()
      const configured = global.workshop?.[key]?.trim()
      if (configured && (await exists(configured))) return configured
    } catch {}
    return null
  }

  async function globApp(dir: string, prefix: string): Promise<string | null> {
    try {
      const entries = await fs.readdir(dir)
      const match = entries
        .filter((n) => n.toLowerCase().startsWith(prefix) && n.toLowerCase().endsWith(".app"))
        .sort()
        .reverse()[0]
      if (match) {
        const appPath = path.join(dir, match)
        if (await exists(appPath)) return appPath
      }
    } catch {}
    return null
  }

  export async function findCsoundQt(): Promise<string | null> {
    const configured = await workshopPath("csoundqt_path")
    if (configured) return configured

    if (process.platform === "darwin") {
      for (const dir of ["/Applications", path.join(homedir(), "Applications")]) {
        const app = await globApp(dir, "csoundqt")
        if (app) return app
      }
    }

    if (process.platform === "win32") {
      const roots = [
        process.env.ProgramFiles,
        process.env["ProgramFiles(x86)"],
        process.env.LOCALAPPDATA,
      ].filter(Boolean) as string[]
      for (const root of roots) {
        for (const sub of ["CsoundQt", "csoundqt"]) {
          for (const rel of ["CsoundQt.exe", path.join("bin", "CsoundQt.exe")]) {
            const exe = path.join(root, sub, rel)
            if (await exists(exe)) return exe
          }
        }
        try {
          const entries = await fs.readdir(root)
          for (const name of entries) {
            if (!name.toLowerCase().includes("csoundqt")) continue
            const bin = path.join(root, name, "CsoundQt.exe")
            if (await exists(bin)) return bin
          }
        } catch {}
      }
    }

    if (process.platform === "linux") {
      for (const p of ["/usr/bin/csoundqt", "/usr/local/bin/csoundqt", "/snap/bin/csoundqt"]) {
        if (await exists(p)) return p
      }
    }

    for (const name of ["csoundqt", "CsoundQt", "qcsound"]) {
      try {
        const result = await $`which ${name} 2>/dev/null`.quiet().nothrow().text()
        if (result.trim()) return result.trim()
      } catch {}
    }

    if (process.platform === "darwin") {
      try {
        const result = await $`brew --prefix csoundqt 2>/dev/null`.quiet().nothrow().text()
        if (result.trim()) return result.trim()
      } catch {}
    }

    return null
  }

  export async function findCabbage(): Promise<string | null> {
    const configured = await workshopPath("cabbage_path")
    if (configured) return configured

    if (await exists("/Applications/Cabbage.app")) return "/Applications/Cabbage.app"

    // macOS installs are often versioned, e.g. Cabbage-2.10.7.app
    if (process.platform === "darwin") {
      try {
        const entries = await fs.readdir("/Applications")
        const bundles = entries
          .filter((name) => /^Cabbage(?:-[\w.]+)?\.app$/i.test(name))
          .sort()
          .reverse()
        for (const bundle of bundles) {
          const appPath = `/Applications/${bundle}`
          if (await exists(appPath)) return appPath
        }
      } catch {}
    }

    const cliPaths = [
      "/Applications/Cabbage.app/Contents/MacOS/Cabbage",
      "/Applications/Cabbage-2.10.7.app/Contents/MacOS/Cabbage",
    ]
    for (const cliPath of cliPaths) {
      if (await exists(cliPath)) return cliPath
    }

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
