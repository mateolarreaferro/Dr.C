import { Log } from "@/util/log"

export namespace Hook {
  const log = Log.create({ service: "hook" })

  export type Lifecycle = "post-edit" | "post-render" | "session-start" | "pre-export"

  export interface HookContext {
    sessionID: string
    toolName?: string
    filePath?: string
    metadata?: Record<string, any>
  }

  export type HookHandler = (ctx: HookContext) => Promise<void>

  const registry = new Map<Lifecycle, HookHandler[]>()

  /**
   * Register a hook handler for a lifecycle event.
   */
  export function register(lifecycle: Lifecycle, handler: HookHandler): void {
    const handlers = registry.get(lifecycle) || []
    handlers.push(handler)
    registry.set(lifecycle, handlers)
  }

  /**
   * Trigger all hooks for a lifecycle event. Runs handlers sequentially.
   * Errors are logged but do not block execution.
   */
  export async function trigger(lifecycle: Lifecycle, ctx: HookContext): Promise<void> {
    const handlers = registry.get(lifecycle) || []
    for (const handler of handlers) {
      try {
        await handler(ctx)
      } catch (e) {
        log.error("hook failed", { lifecycle, error: e })
      }
    }
  }

  /**
   * Map tool names to their corresponding lifecycle events.
   */
  export function lifecycleForTool(toolName: string): Lifecycle | null {
    switch (toolName) {
      case "apply_csd_patch":
      case "write":
      case "edit":
        return "post-edit"
      case "csound_render":
        return "post-render"
      case "csound_export_html":
        return "pre-export"
      default:
        return null
    }
  }

  /**
   * Clear all registered hooks (useful for testing).
   */
  export function clear(): void {
    registry.clear()
  }

  let initialized = false

  export async function init(): Promise<void> {
    if (initialized) return
    initialized = true
    const { BuiltinHooks } = await import("./builtin")
    BuiltinHooks.register()
    log.info("built-in hooks registered")
  }
}
