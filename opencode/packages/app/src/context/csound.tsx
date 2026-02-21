import { createStore, produce } from "solid-js/store"
import { createSimpleContext } from "@drc/ui/context"
import { createMemo } from "solid-js"
import { useSDK } from "@/context/sdk"

export type CsoundMode = "generate_new" | "patch_existing" | "fix_errors"

export interface CsoundMacro {
  name: string
  channel: string
  type: "continuous" | "discrete" | "toggle"
  range: [number, number, number]
  unit: string
  label: string
}

export interface CsoundDiagnostic {
  severity: "error" | "warning" | "info"
  line: number | null
  col: number | null
  message: string
  opcode: string | null
}

export interface CsoundSnapshot {
  hash: string
  filePath: string
  timestamp: number
  size: number
}

export interface CsoundConstraints {
  maxCpu: number | null
  ksmps: number
  autoCompile: boolean
  autoSmoke: boolean
}

export interface CsoundState {
  activeCsdPath: string | null
  activeCsdContent: string | null
  mode: CsoundMode
  compiling: boolean
  smoking: boolean
  diagnostics: CsoundDiagnostic[]
  macros: CsoundMacro[]
  snapshots: CsoundSnapshot[]
  lastCompileSuccess: boolean | null
  lastSmokeSuccess: boolean | null
  constraints: CsoundConstraints
}

export const { use: useCsound, provider: CsoundProvider } = createSimpleContext({
  name: "Csound",
  init: () => {
    const sdk = useSDK()

    const [store, setStore] = createStore<CsoundState>({
      activeCsdPath: null,
      activeCsdContent: null,
      mode: "generate_new",
      compiling: false,
      smoking: false,
      diagnostics: [],
      macros: [],
      snapshots: [],
      lastCompileSuccess: null,
      lastSmokeSuccess: null,
      constraints: {
        maxCpu: null,
        ksmps: 32,
        autoCompile: true,
        autoSmoke: true,
      },
    })

    const hasErrors = createMemo(() => store.diagnostics.some((d) => d.severity === "error"))
    const hasWarnings = createMemo(() => store.diagnostics.some((d) => d.severity === "warning"))
    const errorCount = createMemo(() => store.diagnostics.filter((d) => d.severity === "error").length)
    const warningCount = createMemo(() => store.diagnostics.filter((d) => d.severity === "warning").length)

    async function setActiveCsd(filePath: string) {
      setStore("activeCsdPath", filePath)
      try {
        const response = await fetch(`${sdk.url}/file?path=${encodeURIComponent(filePath)}`)
        if (response.ok) {
          const content = await response.text()
          setStore("activeCsdContent", content)
        }
      } catch {
        // File read error
      }
      await refreshSnapshots()
    }

    async function compile() {
      if (!store.activeCsdPath) return
      setStore("compiling", true)
      setStore("diagnostics", [])

      try {
        const response = await fetch(`${sdk.url}/csound/compile`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ filePath: store.activeCsdPath }),
        })

        const result = await response.json()
        setStore("diagnostics", result.diagnostics)
        setStore("lastCompileSuccess", result.exitCode === 0)
      } catch (err) {
        setStore("lastCompileSuccess", false)
      } finally {
        setStore("compiling", false)
      }
    }

    async function smokeRun(duration = 1) {
      if (!store.activeCsdPath) return
      setStore("smoking", true)

      try {
        const response = await fetch(`${sdk.url}/csound/smoke_run`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            filePath: store.activeCsdPath,
            durationSeconds: duration,
          }),
        })

        const result = await response.json()
        setStore("lastSmokeSuccess", result.passed)
      } catch {
        setStore("lastSmokeSuccess", false)
      } finally {
        setStore("smoking", false)
      }
    }

    async function refreshSnapshots() {
      if (!store.activeCsdPath) return

      try {
        const response = await fetch(
          `${sdk.url}/csound/history?filePath=${encodeURIComponent(store.activeCsdPath)}`,
        )
        if (response.ok) {
          const snapshots = await response.json()
          setStore("snapshots", snapshots)
        }
      } catch {
        // Ignore
      }
    }

    async function restoreSnapshot(hash: string) {
      if (!store.activeCsdPath) return

      try {
        await fetch(`${sdk.url}/csound/restore_snapshot`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ filePath: store.activeCsdPath, hash }),
        })
        await setActiveCsd(store.activeCsdPath)
      } catch {
        // Restore error
      }
    }

    function setMode(mode: CsoundMode) {
      setStore("mode", mode)
    }

    function setMacros(macros: CsoundMacro[]) {
      setStore("macros", macros)
    }

    function updateConstraints(updates: Partial<CsoundConstraints>) {
      setStore(
        produce((s) => {
          Object.assign(s.constraints, updates)
        }),
      )
    }

    return {
      get state() {
        return store
      },
      get hasErrors() {
        return hasErrors()
      },
      get hasWarnings() {
        return hasWarnings()
      },
      get errorCount() {
        return errorCount()
      },
      get warningCount() {
        return warningCount()
      },
      setActiveCsd,
      compile,
      smokeRun,
      refreshSnapshots,
      restoreSnapshot,
      setMode,
      setMacros,
      updateConstraints,
    }
  },
})
