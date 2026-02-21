import { Component, For, Show } from "solid-js"
import { useCsound } from "@/context/csound"

export const CompilePanel: Component = () => {
  const csound = useCsound()

  return (
    <div class="flex flex-col gap-3 p-4">
      <h3 class="text-14-medium text-text-strong">Compile & Run</h3>

      <div class="flex gap-2">
        <button
          class="px-3 py-1.5 rounded text-13-medium bg-surface-raised text-text-strong hover:bg-primary hover:text-text-invert-base transition-colors disabled:opacity-50"
          onClick={() => csound.compile()}
          disabled={csound.state.compiling || !csound.state.activeCsdPath}
        >
          {csound.state.compiling ? "Compiling..." : "Compile"}
        </button>

        <button
          class="px-3 py-1.5 rounded text-13-medium bg-surface-raised text-text-strong hover:bg-primary hover:text-text-invert-base transition-colors disabled:opacity-50"
          onClick={() => csound.smokeRun()}
          disabled={csound.state.smoking || !csound.state.activeCsdPath}
        >
          {csound.state.smoking ? "Running..." : "Smoke Test"}
        </button>
      </div>

      <Show when={csound.state.lastCompileSuccess !== null}>
        <div
          class={`px-3 py-2 rounded text-13-medium ${
            csound.state.lastCompileSuccess
              ? "bg-green-500/10 text-green-400"
              : "bg-red-500/10 text-red-400"
          }`}
        >
          {csound.state.lastCompileSuccess ? "Compilation successful" : "Compilation failed"}
          <Show when={csound.state.lastSmokeSuccess !== null}>
            {" | "}
            {csound.state.lastSmokeSuccess ? "Smoke passed" : "Smoke failed"}
          </Show>
        </div>
      </Show>

      <Show when={csound.state.diagnostics.length > 0}>
        <div class="flex flex-col gap-1">
          <h4 class="text-13-medium text-text-weak">
            Issues ({csound.errorCount} errors, {csound.warningCount} warnings)
          </h4>

          <div class="flex flex-col gap-1 max-h-[300px] overflow-y-auto">
            <For each={csound.state.diagnostics}>
              {(diag) => (
                <div
                  class={`px-2 py-1 rounded text-12-regular cursor-pointer hover:bg-surface-raised ${
                    diag.severity === "error"
                      ? "text-red-400"
                      : diag.severity === "warning"
                        ? "text-yellow-400"
                        : "text-text-weak"
                  }`}
                >
                  <span class="font-mono">
                    {diag.severity.toUpperCase()}
                    {diag.line ? ` (line ${diag.line})` : ""}
                    {diag.opcode ? ` [${diag.opcode}]` : ""}
                  </span>
                  : {diag.message}
                </div>
              )}
            </For>
          </div>
        </div>
      </Show>
    </div>
  )
}
