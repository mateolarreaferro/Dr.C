import { DialogSelect } from "@tui/ui/dialog-select"
import { useDialog } from "@tui/ui/dialog"

export type BuildTarget = "web-minimal" | "web-full" | "web-scaffold" | "cabbage-vst" | "cabbage-standalone" | "tauri-standalone"

interface BuildTargetOption {
  target: BuildTarget
  title: string
  description: string
  category: string
}

const BUILD_TARGETS: BuildTargetOption[] = [
  {
    target: "web-minimal",
    title: "Web — Minimal Player",
    description: "Clean playback page with waveform, controls toggle, signal flow",
    category: "Web App",
  },
  {
    target: "web-full",
    title: "Web — Full Synth UI",
    description: "Interactive synth page with all parameters as knobs/sliders",
    category: "Web App",
  },
  {
    target: "web-scaffold",
    title: "Web — Project Scaffold",
    description: "Exports a folder with index.html + style.css + app.js for customization",
    category: "Web App",
  },
  {
    target: "cabbage-vst",
    title: "VST/AU Plugin",
    description: "Cabbage CSD with auto-generated widgets — open in Cabbage to compile",
    category: "Plugin",
  },
  {
    target: "cabbage-standalone",
    title: "Standalone App (Cabbage)",
    description: "Cabbage CSD configured for standalone export",
    category: "Plugin",
  },
  {
    target: "tauri-standalone",
    title: "Standalone App (Desktop)",
    description: "Tauri project wrapping the web player as a native app",
    category: "Standalone",
  },
]

export function DialogBuildTarget(props: {
  onSelect: (target: BuildTarget) => void
}) {
  const dialog = useDialog()

  const options = BUILD_TARGETS.map((t) => ({
    value: t.target,
    title: t.title,
    description: t.description,
    category: t.category,
  }))

  return (
    <DialogSelect
      title="Build target"
      options={options}
      onSelect={(option) => {
        dialog.clear()
        props.onSelect(option.value)
      }}
    />
  )
}
