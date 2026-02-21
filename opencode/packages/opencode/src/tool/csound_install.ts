import z from "zod"
import { spawn } from "child_process"
import { Tool } from "./tool"
import DESCRIPTION from "./csound_install.txt"
import { Log } from "../util/log"

const log = Log.create({ service: "csound-install" })

export const CsoundInstallTool = Tool.define(
  "csound_install",
  {
    description: DESCRIPTION,
    parameters: z.object({}),
    async execute(_params, ctx) {
      // Check if already installed
      const existing = await checkCsound()
      if (existing.installed) {
        return {
          title: "Csound already installed",
          metadata: {
            status: "already_installed",
            version: existing.version,
          },
          output: `Csound is already installed: ${existing.version}\nPath: ${existing.path}`,
        }
      }

      ctx.metadata({
        metadata: {
          status: "installing",
          platform: process.platform,
        },
      })

      // Detect platform and package manager
      const installCmd = await detectInstallCommand()
      if (!installCmd) {
        return {
          title: "Cannot auto-install Csound",
          metadata: { status: "unsupported" },
          output: [
            "## Cannot Auto-Install Csound",
            "",
            `Platform: ${process.platform}`,
            "No supported package manager found.",
            "",
            "Please install Csound manually:",
            "- macOS: `brew install csound` (install Homebrew first: https://brew.sh)",
            "- Ubuntu/Debian: `sudo apt-get install csound`",
            "- Fedora: `sudo dnf install csound`",
            "- Arch: `sudo pacman -S csound`",
            "- Windows: Download from https://csound.com/download.html",
            "- Or build from source: https://github.com/csound/csound",
          ].join("\n"),
        }
      }

      // Run installation
      const result = await runInstall(installCmd, ctx.abort)

      if (result.success) {
        // Verify installation
        const verify = await checkCsound()
        ctx.metadata({
          metadata: {
            status: "installed",
            version: verify.version,
          },
        })

        return {
          title: "Csound installed successfully",
          metadata: {
            status: "installed",
            version: verify.version,
            method: installCmd.method,
          },
          output: [
            "## Csound Installed Successfully",
            "",
            `Method: ${installCmd.method}`,
            `Version: ${verify.version || "unknown"}`,
            verify.path ? `Path: ${verify.path}` : "",
            "",
            "Csound is ready to use. You can now compile and render .csd files.",
          ]
            .filter(Boolean)
            .join("\n"),
        }
      } else {
        ctx.metadata({
          metadata: {
            status: "failed",
            method: installCmd.method,
          },
        })

        return {
          title: "Csound installation failed",
          metadata: {
            status: "failed",
            method: installCmd.method,
            exitCode: result.exitCode,
          },
          output: [
            "## Csound Installation Failed",
            "",
            `Method: ${installCmd.method}`,
            `Exit code: ${result.exitCode}`,
            "",
            "Please install Csound manually:",
            "- macOS: `brew install csound`",
            "- Ubuntu/Debian: `sudo apt-get install csound`",
            "- Download: https://csound.com/download.html",
            "",
            result.stderr ? `### Error Output\n\`\`\`\n${result.stderr.slice(0, 2000)}\n\`\`\`` : "",
          ]
            .filter(Boolean)
            .join("\n"),
        }
      }
    },
  },
)

interface CsoundCheck {
  installed: boolean
  version?: string
  path?: string
}

async function checkCsound(): Promise<CsoundCheck> {
  try {
    const whichResult = await runCommand("which", ["csound"])
    if (!whichResult.success) {
      return { installed: false }
    }
    const csoundPath = whichResult.stdout.trim()

    const versionResult = await runCommand("csound", ["--version"])
    const stderr = versionResult.stderr
    const match = stderr.match(/Csound version (\S+)/i) || stderr.match(/(\d+\.\d+\.\d+)/)
    const version = match ? match[1] : "unknown"

    return { installed: true, version, path: csoundPath }
  } catch {
    return { installed: false }
  }
}

interface InstallCommand {
  command: string
  args: string[]
  method: string
}

async function detectInstallCommand(): Promise<InstallCommand | null> {
  if (process.platform === "darwin") {
    // macOS — check for Homebrew
    const brew = await runCommand("which", ["brew"])
    if (brew.success) {
      return { command: "brew", args: ["install", "csound"], method: "homebrew" }
    }
    return null
  }

  if (process.platform === "linux") {
    // Try apt-get (Debian/Ubuntu)
    const apt = await runCommand("which", ["apt-get"])
    if (apt.success) {
      return { command: "sudo", args: ["apt-get", "install", "-y", "csound"], method: "apt" }
    }

    // Try dnf (Fedora/RHEL)
    const dnf = await runCommand("which", ["dnf"])
    if (dnf.success) {
      return { command: "sudo", args: ["dnf", "install", "-y", "csound"], method: "dnf" }
    }

    // Try pacman (Arch)
    const pacman = await runCommand("which", ["pacman"])
    if (pacman.success) {
      return { command: "sudo", args: ["pacman", "-S", "--noconfirm", "csound"], method: "pacman" }
    }

    return null
  }

  return null
}

async function runInstall(
  cmd: InstallCommand,
  abort: AbortSignal,
): Promise<{ success: boolean; exitCode: number; stdout: string; stderr: string }> {
  return new Promise((resolve) => {
    let stdout = ""
    let stderr = ""
    let exited = false

    const proc = spawn(cmd.command, cmd.args, {
      stdio: ["ignore", "pipe", "pipe"],
    })

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    // 5-minute timeout for installation
    const timer = setTimeout(() => {
      if (!exited) {
        try {
          proc.kill("SIGTERM")
        } catch {}
      }
    }, 300_000)

    const abortHandler = () => {
      clearTimeout(timer)
      if (!exited) {
        try {
          proc.kill("SIGTERM")
        } catch {}
      }
    }

    if (abort.aborted) abortHandler()
    abort.addEventListener("abort", abortHandler, { once: true })

    proc.once("exit", (code) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      resolve({ success: code === 0, exitCode: code ?? 1, stdout, stderr })
    })

    proc.once("error", (err) => {
      exited = true
      clearTimeout(timer)
      abort.removeEventListener("abort", abortHandler)
      resolve({ success: false, exitCode: 1, stdout, stderr: err.message })
    })
  })
}

function runCommand(cmd: string, args: string[]): Promise<{ success: boolean; stdout: string; stderr: string }> {
  return new Promise((resolve) => {
    let stdout = ""
    let stderr = ""

    const proc = spawn(cmd, args, { stdio: ["ignore", "pipe", "pipe"] })

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const timer = setTimeout(() => {
      try {
        proc.kill("SIGTERM")
      } catch {}
    }, 10_000)

    proc.once("exit", (code) => {
      clearTimeout(timer)
      resolve({ success: code === 0, stdout, stderr })
    })

    proc.once("error", () => {
      clearTimeout(timer)
      resolve({ success: false, stdout, stderr })
    })
  })
}
