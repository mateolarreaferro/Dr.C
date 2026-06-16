import { TextAttributes } from "@opentui/core"
import { createMemo, createSignal, For, onMount, Show } from "solid-js"
import { useTheme } from "../context/theme"
import { useDialog } from "@tui/ui/dialog"
import { useSync } from "@tui/context/sync"
import { useSDK } from "../context/sdk"
import { useToast } from "../ui/toast"
import { DialogProvider as DialogProviderList } from "./dialog-provider"
import { DialogPrompt } from "../ui/dialog-prompt"
import type { Config } from "@/config/config"
import { Global } from "@/global"
import type { OpencodeClient } from "@drc/sdk/v2"

type WorkshopSnapshot = {
  workshop: Config.Workshop
  ollama: { running: boolean; models: string[]; error?: string }
  connected: string[]
  paths: { config: string; auth: string; data: string }
}

const FREE_TIER_NOTE =
  "Groq is recommended for workshops (~30 requests/min on the free tier). " +
  "If Dr.C pauses with no output, wait and try again. Free Gemini is disabled for Agent. " +
  "Web Apps need no key. Or enable Ollama below for a local model with no limits."

async function workshopRequest<T>(sdk: OpencodeClient, path: string, init?: RequestInit): Promise<T> {
  const client = (sdk as unknown as { client: { request: (o: object) => Promise<{ data?: T; error?: unknown }> } }).client
  const res = await client.request({
    url: path,
    method: init?.method ?? "GET",
    body: init?.body,
    headers: init?.headers as Record<string, string> | undefined,
  })
  if (res.error) throw res.error
  return res.data as T
}

export function DialogSettings() {
  const { theme } = useTheme()
  const dialog = useDialog()
  const sync = useSync()
  const sdk = useSDK()
  const toast = useToast()
  const [snap, setSnap] = createSignal<WorkshopSnapshot | null>(null)
  const [busy, setBusy] = createSignal(false)
  const [testMsg, setTestMsg] = createSignal("")

  const w = createMemo(() => snap()?.workshop ?? {})

  async function reload() {
    try {
      const data = await workshopRequest<WorkshopSnapshot>(sdk.client, "/workshop")
      setSnap(data)
    } catch {
      toast.show({ variant: "error", message: "Could not load settings" })
    }
  }

  onMount(() => void reload())

  async function patch(partial: Partial<Config.Workshop>) {
    setBusy(true)
    try {
      const current = snap()?.workshop ?? {}
      const data = await workshopRequest<WorkshopSnapshot>(sdk.client, "/workshop", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ workshop: { ...current, ...partial } }),
      })
      setSnap(data)
      await sdk.client.instance.dispose()
      await sync.bootstrap()
      toast.show({ variant: "success", message: "Settings saved" })
    } catch {
      toast.show({ variant: "error", message: "Could not save settings" })
    } finally {
      setBusy(false)
    }
  }

  async function testOllama() {
    setTestMsg("Testing…")
    try {
      const data = await workshopRequest<{ ok: boolean; message: string }>(sdk.client, "/workshop/ollama/test", {
        method: "POST",
      })
      setTestMsg(data.message)
      if (data.ok) await reload()
    } catch {
      setTestMsg("Test failed")
    }
  }

  async function editPath(field: "csoundqt_path" | "cabbage_path", label: string) {
    const value = await new Promise<string | null>((resolve) => {
      dialog.replace(
        () => (
          <DialogPrompt
            title={label}
            description={() => (
              <text fg={theme.textMuted} wrapMode="word">
                Leave blank to auto-detect on this machine.
              </text>
            )}
            placeholder="/Applications/CsoundQt.app"
            onConfirm={(v) => resolve(v)}
            onCancel={() => resolve(null)}
          />
        ),
        () => resolve(null),
      )
    })
    if (value == null) return
    await patch({ [field]: value.trim() })
    dialog.replace(() => <DialogSettings />)
  }

  return (
    <box paddingLeft={2} paddingRight={2} gap={1} paddingBottom={1} maxHeight={28}>
      <box flexDirection="row" justifyContent="space-between">
        <text fg={theme.text} attributes={TextAttributes.BOLD}>
          Dr.C Settings
        </text>
        <text fg={theme.textMuted} onMouseUp={() => dialog.clear()}>
          esc
        </text>
      </box>

      <text fg={theme.textMuted} wrapMode="word">
        API keys, local models, and external tools · /settings · saved to ~/.config/drc/drc.json
      </text>

      <box gap={0}>
        <text fg={theme.accent} attributes={TextAttributes.BOLD}>
          API providers
        </text>
        <Show when={snap()} fallback={<text fg={theme.textMuted}>Loading…</text>}>
          {(s) => (
            <>
              <For each={["groq", "google", "anthropic", "openai", "ollama"]}>
                {(id) => {
                  const on = s().connected.some((c) => c.startsWith(id))
                  return (
                    <text fg={theme.text} wrapMode="word">
                      <span style={{ fg: on ? theme.success : theme.textMuted }}>{on ? "✓" : "○"}</span>{" "}
                      {providerLabel(id)}
                      {on ? "" : " — not connected"}
                    </text>
                  )
                }}
              </For>
              <box flexDirection="row" gap={2} marginTop={1}>
                <text fg={theme.accent} onMouseUp={() => dialog.replace(() => <DialogProviderList />)}>
                  connect provider
                </text>
                <text fg={theme.textMuted}>·</text>
                <text
                  fg={theme.accent}
                  onMouseUp={() => {
                    toast.show({
                      variant: "info",
                      message: `Keys: ${Global.Path.data}/auth.json · CLI: drc auth login`,
                    })
                  }}
                >
                  where keys live
                </text>
              </box>
            </>
          )}
        </Show>
      </box>

      <box gap={0}>
        <text fg={theme.accent} attributes={TextAttributes.BOLD}>
          Free API tier
        </text>
        <text fg={theme.textMuted} wrapMode="word">
          {FREE_TIER_NOTE}
        </text>
      </box>

      <box gap={0}>
        <text fg={theme.accent} attributes={TextAttributes.BOLD}>
          Local model (Ollama)
        </text>
        <text fg={theme.textMuted} wrapMode="word">
          ollama.com · ollama pull qwen2.5-coder:7b
        </text>
        <Show when={snap()}>
          {(s) => (
            <>
              <text fg={theme.text}>
                Status:{" "}
                <span style={{ fg: s().ollama.running ? theme.success : theme.warning }}>
                  {s().ollama.running ? "running" : "not detected"}
                </span>
                {s().ollama.models.length ? ` · ${s().ollama.models.length} model(s)` : ""}
              </text>
              <box flexDirection="row" gap={2} flexWrap="wrap">
                <text
                  fg={w().ollama_enabled ? theme.success : theme.accent}
                  onMouseUp={() => !busy() && void patch({ ollama_enabled: !w().ollama_enabled })}
                >
                  [{w().ollama_enabled ? "x" : " "}] use Ollama
                </text>
                <text
                  fg={w().ollama_prefer ? theme.success : theme.accent}
                  onMouseUp={() => !busy() && void patch({ ollama_prefer: !w().ollama_prefer })}
                >
                  [{w().ollama_prefer ? "x" : " "}] prefer over cloud
                </text>
                <text fg={theme.accent} onMouseUp={() => void testOllama()}>
                  test
                </text>
                <text fg={theme.accent} onMouseUp={() => void reload()}>
                  refresh
                </text>
              </box>
              <Show when={testMsg()}>
                <text fg={theme.textMuted} wrapMode="word">
                  {testMsg()}
                </text>
              </Show>
              <Show when={s().ollama.models.length > 0}>
                <text fg={theme.textMuted}>
                  Model: {w().ollama_model || s().ollama.models[0]}{" "}
                  <span
                    style={{ fg: theme.accent }}
                    onMouseUp={() => {
                      const models = s().ollama.models
                      const idx = models.indexOf(w().ollama_model ?? "")
                      const next = models[(idx + 1) % models.length]
                      void patch({ ollama_model: next })
                    }}
                  >
                    cycle
                  </span>
                </text>
              </Show>
            </>
          )}
        </Show>
      </box>

      <box gap={0}>
        <text fg={theme.accent} attributes={TextAttributes.BOLD}>
          External tools
        </text>
        <text fg={theme.textMuted} wrapMode="word">
          CsoundQt: {w().csoundqt_path || "(auto)"}{" "}
          <span style={{ fg: theme.accent }} onMouseUp={() => void editPath("csoundqt_path", "CsoundQt path")}>
            set
          </span>
        </text>
        <text fg={theme.textMuted} wrapMode="word">
          Cabbage: {w().cabbage_path || "(auto)"}{" "}
          <span style={{ fg: theme.accent }} onMouseUp={() => void editPath("cabbage_path", "Cabbage path")}>
            set
          </span>
        </text>
      </box>

      <Show when={snap()?.paths}>
        {(p) => (
          <box gap={0}>
            <text fg={theme.accent} attributes={TextAttributes.BOLD}>
              Config files
            </text>
            <text fg={theme.textMuted} wrapMode="word">
              {p().config} · {p().auth}
            </text>
          </box>
        )}
      </Show>
    </box>
  )
}

function providerLabel(id: string): string {
  return (
    {
      groq: "Groq — recommended (free tier)",
      google: "Google AI (Gemini) — Pro+ optional",
      anthropic: "Anthropic (Claude)",
      openai: "OpenAI",
      ollama: "Ollama (local)",
    }[id] ?? id
  )
}
