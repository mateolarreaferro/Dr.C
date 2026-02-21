import { Component, For } from "solid-js"
import { useCsound, type CsoundMode } from "@/context/csound"

const modes: { value: CsoundMode; label: string; description: string }[] = [
  { value: "generate_new", label: "Generate", description: "Create a new instrument from scratch" },
  { value: "patch_existing", label: "Patch", description: "Modify an existing .csd file" },
  { value: "fix_errors", label: "Fix", description: "Auto-fix compilation errors" },
]

export const PromptPanel: Component = () => {
  const csound = useCsound()

  return (
    <div class="flex flex-col gap-4 p-4">
      <h3 class="text-14-medium text-text-strong">Mode</h3>
      <div class="flex gap-2">
        <For each={modes}>
          {(mode) => (
            <button
              class={`px-3 py-1.5 rounded text-13-medium transition-colors ${
                csound.state.mode === mode.value
                  ? "bg-primary text-text-invert-base"
                  : "bg-surface-raised text-text-weak hover:text-text-strong"
              }`}
              onClick={() => csound.setMode(mode.value)}
              title={mode.description}
            >
              {mode.label}
            </button>
          )}
        </For>
      </div>

      <div class="flex flex-col gap-3">
        <h3 class="text-14-medium text-text-strong">Constraints</h3>

        <div class="flex items-center gap-2">
          <label class="text-13-regular text-text-weak w-20">ksmps</label>
          <select
            class="bg-surface-raised text-text-strong rounded px-2 py-1 text-13-regular"
            value={csound.state.constraints.ksmps}
            onChange={(e) => csound.updateConstraints({ ksmps: parseInt(e.currentTarget.value) })}
          >
            <option value="16">16 (low latency)</option>
            <option value="32">32 (default)</option>
            <option value="64">64 (balanced)</option>
            <option value="128">128 (low CPU)</option>
          </select>
        </div>

        <div class="flex items-center gap-2">
          <label class="text-13-regular text-text-weak">
            <input
              type="checkbox"
              checked={csound.state.constraints.autoCompile}
              onChange={(e) => csound.updateConstraints({ autoCompile: e.currentTarget.checked })}
              class="mr-2"
            />
            Auto-compile after changes
          </label>
        </div>

        <div class="flex items-center gap-2">
          <label class="text-13-regular text-text-weak">
            <input
              type="checkbox"
              checked={csound.state.constraints.autoSmoke}
              onChange={(e) => csound.updateConstraints({ autoSmoke: e.currentTarget.checked })}
              class="mr-2"
            />
            Auto smoke-test after compile
          </label>
        </div>
      </div>
    </div>
  )
}
