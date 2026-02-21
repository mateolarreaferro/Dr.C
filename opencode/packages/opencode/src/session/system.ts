import { Ripgrep } from "../file/ripgrep"

import { Instance } from "../project/instance"

import PROMPT_ANTHROPIC from "./prompt/anthropic.txt"
import PROMPT_ANTHROPIC_WITHOUT_TODO from "./prompt/qwen.txt"
import PROMPT_BEAST from "./prompt/beast.txt"
import PROMPT_GEMINI from "./prompt/gemini.txt"

import PROMPT_CODEX from "./prompt/codex_header.txt"
import PROMPT_TRINITY from "./prompt/trinity.txt"
import type { Provider } from "@/provider/provider"
import { $ } from "bun"
import { RetrievalEngine } from "@/retrieval/engine"
import { SessionWorkspace } from "./workspace"

export namespace SystemPrompt {
  export function instructions() {
    return PROMPT_CODEX.trim()
  }

  export function provider(model: Provider.Model) {
    if (model.api.id.includes("gpt-5")) return [PROMPT_CODEX]
    if (model.api.id.includes("gpt-") || model.api.id.includes("o1") || model.api.id.includes("o3"))
      return [PROMPT_BEAST]
    if (model.api.id.includes("gemini-")) return [PROMPT_GEMINI]
    if (model.api.id.includes("claude")) return [PROMPT_ANTHROPIC]
    if (model.api.id.toLowerCase().includes("trinity")) return [PROMPT_TRINITY]
    return [PROMPT_ANTHROPIC_WITHOUT_TODO]
  }

  async function csoundVersion(): Promise<string> {
    try {
      const result = await $`csound --version 2>&1`.quiet().nothrow().text()
      const match = result.match(/Csound version (\S+)/i) || result.match(/(\d+\.\d+\.\d+)/)
      return match ? match[1] : "installed (version unknown)"
    } catch {
      return "not installed"
    }
  }

  async function cabbageVersion(): Promise<string> {
    try {
      const result = await $`which Cabbage 2>/dev/null || which cabbage 2>/dev/null`.quiet().nothrow().text()
      return result.trim() ? "available" : "not found"
    } catch {
      return "not found"
    }
  }

  async function audioPlaybackPlayer(): Promise<string> {
    const candidates =
      process.platform === "darwin"
        ? ["afplay"]
        : process.platform === "linux"
          ? ["paplay", "aplay"]
          : []
    for (const player of candidates) {
      try {
        const result = await $`which ${player} 2>/dev/null`.quiet().nothrow().text()
        if (result.trim()) return player
      } catch {}
    }
    return "none"
  }

  async function listCsdFiles(directory: string): Promise<string[]> {
    try {
      const glob = new Bun.Glob("**/*.csd")
      const matches: string[] = []
      for await (const match of glob.scan({ cwd: directory, absolute: false, onlyFiles: true })) {
        matches.push(match)
        if (matches.length >= 20) break
      }
      return matches
    } catch {
      return []
    }
  }

  export async function environment(model: Provider.Model) {
    const project = Instance.project
    const csound = await csoundVersion()
    const cabbage = await cabbageVersion()
    const audioPlayer = await audioPlaybackPlayer()
    const csdFiles = await listCsdFiles(Instance.directory)

    // Lazy-init retrieval engine on first call (fire-and-forget)
    RetrievalEngine.initialize().catch(() => {})
    // Clean up old session workspaces (fire-and-forget)
    SessionWorkspace.cleanup().catch(() => {})
    const csdSection =
      csdFiles.length > 0
        ? `  CSD files in workspace:\n${csdFiles.map((f) => `    - ${f}`).join("\n")}`
        : `  CSD files in workspace: none`
    return [
      [
        `You are DrC — an expert Csound sound designer and synthesis programmer, powered by the model ${model.api.id}.`,
        `Here is some useful information about the environment you are running in:`,
        `<env>`,
        `  Working directory: ${Instance.directory}`,
        `  Is directory a git repo: ${project.vcs === "git" ? "yes" : "no"}`,
        `  Platform: ${process.platform}`,
        `  Today's date: ${new Date().toDateString()}`,
        `  Csound: ${csound}${csound === "not installed" ? " ⚠ USE csound_install TOOL TO INSTALL BEFORE ANY CSOUND OPERATIONS" : ""}`,
        `  Cabbage: ${cabbage}`,
        `  Audio playback: ${audioPlayer}`,
        csdSection,
        `</env>`,
        `<directories>`,
        `  ${
          project.vcs === "git" && false
            ? await Ripgrep.tree({
                cwd: Instance.directory,
                limit: 50,
              })
            : ""
        }`,
        `</directories>`,
      ].join("\n"),
    ]
  }
}
