import { Hook } from "./index"
import { Log } from "@/util/log"
import { SessionWorkspace } from "@/session/workspace"
import { UserProfile } from "@/retrieval/user-profile"
import { LiveEngine } from "@/csound/live-engine"
import { MemoryManager } from "@/memory/manager"
import { spawn } from "child_process"

export namespace BuiltinHooks {
  const log = Log.create({ service: "hook.builtin" })

  // Track render count per session for memory recording
  const sessionRenderCounts = new Map<string, number>()

  /**
   * Register all built-in hooks.
   */
  export function register(): void {
    Hook.register("post-edit", postEditHook)
    Hook.register("post-render", postRenderHook)
    Hook.register("session-start", sessionStartHook)
    Hook.register("pre-export", preExportHook)
    Hook.register("session-end", sessionEndHook)
    Hook.register("post-export", postExportHook)
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
   * Also checks if live engine is running and logs hot-reload availability.
   */
  async function postRenderHook(ctx: Hook.HookContext): Promise<void> {
    const success = ctx.metadata?.success !== false
    const audioSignal = ctx.metadata?.audioSignal

    // Record to user profile
    await UserProfile.record(success ? "render_success" : "render_failure").catch(() => {})

    // If live engine is running, log that hot-reload is available
    if (success && LiveEngine.isRunning(ctx.sessionID)) {
      const filePath = ctx.filePath ?? ctx.metadata?.filePath
      log.info("post-render: live engine active — CSD updated, hot-reload available", {
        sessionID: ctx.sessionID,
        filePath,
      })
    }

    // Track render count for memory recording
    const count = (sessionRenderCounts.get(ctx.sessionID) || 0) + 1
    sessionRenderCounts.set(ctx.sessionID, count)

    // After 3+ renders, record techniques from the current CSD (fire-and-forget)
    if (count >= 3 && ctx.metadata?.csdContent) {
      const outcome = success ? "success" : "failed"
      MemoryManager.recordTechniquesFromCsd(ctx.sessionID, ctx.metadata.csdContent, outcome).catch((e) =>
        log.error("memory technique recording failed", { error: e }),
      )
    }

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

  /**
   * SessionEnd: Generate session summary and update sonic identity (fire-and-forget).
   */
  async function sessionEndHook(ctx: Hook.HookContext): Promise<void> {
    // Fire-and-forget: generate summary and update identity in parallel
    Promise.all([
      MemoryManager.generateSessionSummary(ctx.sessionID),
      MemoryManager.updateIdentityFromSession(ctx.sessionID),
    ]).catch((e) => log.error("session-end memory hooks failed", { error: e }))

    // Clean up render counter
    sessionRenderCounts.delete(ctx.sessionID)

    log.info("session-end hook", { sessionID: ctx.sessionID })
  }

  /**
   * PostExport: Record technique as successful in journal when user exports.
   */
  async function postExportHook(ctx: Hook.HookContext): Promise<void> {
    const csdContent = ctx.metadata?.csdContent
    if (!csdContent || typeof csdContent !== "string") return

    // Record techniques with "success" outcome since user exported
    MemoryManager.recordTechniquesFromCsd(ctx.sessionID, csdContent, "success").catch((e) =>
      log.error("post-export memory recording failed", { error: e }),
    )

    log.info("post-export hook", { sessionID: ctx.sessionID })
  }
}
