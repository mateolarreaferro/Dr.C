import { Hook } from "./index"
import { Log } from "@/util/log"
import { SessionWorkspace } from "@/session/workspace"
import { UserProfile } from "@/retrieval/user-profile"
import { spawn } from "child_process"

export namespace BuiltinHooks {
  const log = Log.create({ service: "hook.builtin" })

  /**
   * Register all built-in hooks.
   */
  export function register(): void {
    Hook.register("post-edit", postEditHook)
    Hook.register("post-render", postRenderHook)
    Hook.register("session-start", sessionStartHook)
    Hook.register("pre-export", preExportHook)
  }

  /**
   * PostEdit: Auto-compile CSD after apply_csd_patch/write/edit modifies a .csd file.
   * Marks workspace as dirty.
   */
  async function postEditHook(ctx: Hook.HookContext): Promise<void> {
    const filePath = ctx.filePath ?? ctx.metadata?.filePath ?? ctx.metadata?.filepath
    if (!filePath || typeof filePath !== "string") return
    if (!filePath.endsWith(".csd")) return

    // Mark workspace dirty
    try {
      await SessionWorkspace.markDirty(ctx.sessionID)
    } catch {
      // Workspace might not be active yet
    }

    // Auto-compile check (fire and forget)
    try {
      const resolved = SessionWorkspace.resolve(ctx.sessionID, filePath)
      const proc = spawn("csound", ["--syntax-check-only", resolved], {
        timeout: 10000,
        stdio: "pipe",
      })

      const result = await new Promise<boolean>((resolve) => {
        proc.on("close", (code) => resolve(code === 0))
        proc.on("error", () => resolve(false))
      })

      if (!result) {
        log.info("post-edit auto-compile found syntax errors", { filePath })
      }
    } catch (e) {
      log.error("post-edit auto-compile failed", { error: e })
    }
  }

  /**
   * PostRender: Record RLHF signal and user profile update after audio render.
   */
  async function postRenderHook(ctx: Hook.HookContext): Promise<void> {
    const success = ctx.metadata?.success !== false
    const audioSignal = ctx.metadata?.audioSignal

    // Record to user profile
    await UserProfile.record(success ? "render_success" : "render_failure").catch(() => {})

    // Narration trigger happens in processor, not here
    log.info("post-render hook", { success, audioSignal })
  }

  /**
   * SessionStart: Check Csound installation and restore workspace.
   */
  async function sessionStartHook(ctx: Hook.HookContext): Promise<void> {
    // Record session start in user profile
    await UserProfile.record("session_start").catch(() => {})

    // Check if Csound is installed
    try {
      const proc = spawn("csound", ["--version"], {
        timeout: 5000,
        stdio: "pipe",
      })
      await new Promise<void>((resolve) => {
        proc.on("close", () => resolve())
        proc.on("error", () => resolve())
      })
    } catch {
      log.info("csound not found during session start")
    }
  }

  /**
   * PreExport: Validate CSD compiles before HTML generation.
   */
  async function preExportHook(ctx: Hook.HookContext): Promise<void> {
    const filePath = ctx.filePath ?? ctx.metadata?.filePath
    if (!filePath || typeof filePath !== "string") return
    if (!filePath.endsWith(".csd")) return

    try {
      const resolved = SessionWorkspace.resolve(ctx.sessionID, filePath)
      const proc = spawn("csound", ["--syntax-check-only", resolved], {
        timeout: 10000,
        stdio: "pipe",
      })

      let stderr = ""
      proc.stderr?.on("data", (data: Buffer) => { stderr += data.toString() })

      const success = await new Promise<boolean>((resolve) => {
        proc.on("close", (code) => resolve(code === 0))
        proc.on("error", () => resolve(false))
      })

      if (!success) {
        log.info("pre-export validation failed", { filePath, stderr: stderr.slice(0, 500) })
        // Don't throw — let the export proceed anyway (user might want to debug in browser)
      }
    } catch (e) {
      log.error("pre-export validation error", { error: e })
    }
  }
}
