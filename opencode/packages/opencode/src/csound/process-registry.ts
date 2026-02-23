/**
 * Global registry for active Csound processes.
 *
 * Tracks spawned csound render/playback processes so they can be
 * killed on demand via the stop button in the CSD panel.
 */

import type { ChildProcess } from "child_process"

export namespace CsoundProcessRegistry {
  interface TrackedProcess {
    proc: ChildProcess
    type: "render" | "playback"
    startedAt: number
  }

  const active = new Map<number, TrackedProcess>()

  export function register(proc: ChildProcess, type: "render" | "playback"): void {
    if (!proc.pid) return
    active.set(proc.pid, { proc, type, startedAt: Date.now() })
    proc.once("exit", () => {
      if (proc.pid) active.delete(proc.pid)
    })
    proc.once("error", () => {
      if (proc.pid) active.delete(proc.pid)
    })
  }

  export function stopAll(): number {
    let killed = 0
    for (const [pid, entry] of active) {
      try {
        // Kill process group on Unix for clean cleanup
        if (process.platform !== "win32") {
          process.kill(-pid, "SIGTERM")
        } else {
          entry.proc.kill("SIGTERM")
        }
        killed++
      } catch {}
      active.delete(pid)
    }
    return killed
  }

  export function hasActive(): boolean {
    return active.size > 0
  }

  export function count(): number {
    return active.size
  }
}
