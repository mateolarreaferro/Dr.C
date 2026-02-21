import { Component, For, Show } from "solid-js"
import { useCsound } from "@/context/csound"

export const MacrosPanel: Component = () => {
  const csound = useCsound()

  return (
    <div class="flex flex-col gap-3 p-4">
      <h3 class="text-14-medium text-text-strong">Macros / Controls</h3>

      <Show
        when={csound.state.macros.length > 0}
        fallback={
          <p class="text-13-regular text-text-weak">
            No macros defined. Generate an instrument to populate controls.
          </p>
        }
      >
        <div class="flex flex-col gap-2">
          <For each={csound.state.macros}>
            {(macro) => (
              <div class="flex items-center gap-3 px-3 py-2 rounded bg-surface-raised">
                <div class="flex flex-col flex-1 min-w-0">
                  <span class="text-13-medium text-text-strong truncate">{macro.label}</span>
                  <span class="text-12-regular text-text-weak font-mono truncate">
                    {macro.channel} ({macro.name})
                  </span>
                </div>

                <div class="flex items-center gap-2 shrink-0">
                  <Show when={macro.type === "continuous"}>
                    <span class="text-12-regular text-text-weak">
                      {macro.range[0]}-{macro.range[1]}
                    </span>
                    <span class="text-12-regular text-primary font-mono">{macro.range[2]}</span>
                    <Show when={macro.unit}>
                      <span class="text-12-regular text-text-weak">{macro.unit}</span>
                    </Show>
                  </Show>

                  <Show when={macro.type === "toggle"}>
                    <span class="text-12-regular text-text-weak">toggle</span>
                  </Show>

                  <Show when={macro.type === "discrete"}>
                    <span class="text-12-regular text-text-weak">discrete</span>
                  </Show>
                </div>
              </div>
            )}
          </For>
        </div>
      </Show>
    </div>
  )
}
