import { Component, For, Show } from "solid-js"
import { useCsound } from "@/context/csound"

function formatTimestamp(ts: number): string {
  const d = new Date(ts)
  return d.toLocaleString(undefined, {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  })
}

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes}B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`
  return `${(bytes / (1024 * 1024)).toFixed(1)}MB`
}

export const HistoryPanel: Component = () => {
  const csound = useCsound()

  return (
    <div class="flex flex-col gap-3 p-4">
      <div class="flex items-center justify-between">
        <h3 class="text-14-medium text-text-strong">History</h3>
        <button
          class="text-12-regular text-text-weak hover:text-text-strong"
          onClick={() => csound.refreshSnapshots()}
        >
          Refresh
        </button>
      </div>

      <Show
        when={csound.state.snapshots.length > 0}
        fallback={
          <p class="text-13-regular text-text-weak">
            No snapshots yet. Snapshots are created automatically before patches are applied.
          </p>
        }
      >
        <div class="flex flex-col gap-1 max-h-[300px] overflow-y-auto">
          <For each={csound.state.snapshots}>
            {(snapshot) => (
              <div class="flex items-center gap-3 px-3 py-2 rounded bg-surface-raised hover:bg-surface-raised/80 group">
                <div class="flex flex-col flex-1 min-w-0">
                  <span class="text-13-medium text-text-strong font-mono truncate">
                    {snapshot.hash}
                  </span>
                  <span class="text-12-regular text-text-weak">
                    {formatTimestamp(snapshot.timestamp)} | {formatSize(snapshot.size)}
                  </span>
                </div>

                <button
                  class="text-12-medium text-text-weak hover:text-primary opacity-0 group-hover:opacity-100 transition-opacity shrink-0"
                  onClick={() => csound.restoreSnapshot(snapshot.hash)}
                >
                  Restore
                </button>
              </div>
            )}
          </For>
        </div>
      </Show>
    </div>
  )
}
