import { Auth } from "../auth"
import { Config } from "../config/config"
import { Global } from "../global"
import { Log } from "../util/log"

const DEFAULT_OLLAMA_BASE = "http://127.0.0.1:11434"
const DEFAULT_OLLAMA_MODEL = "qwen2.5-coder:7b"

export interface OllamaModel {
  name: string
  size?: number
}

export function ollamaBaseUrl(configured?: string): string {
  const raw = (configured ?? process.env.OLLAMA_HOST ?? "").trim()
  if (!raw) return DEFAULT_OLLAMA_BASE
  if (raw.startsWith("http")) return raw.replace(/\/$/, "")
  return `http://${raw.replace(/\/$/, "")}`
}

export async function probeOllama(baseUrl?: string): Promise<{ ok: boolean; models: OllamaModel[]; error?: string }> {
  const url = `${ollamaBaseUrl(baseUrl)}/api/tags`
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(4000) })
    if (!res.ok) return { ok: false, models: [], error: `HTTP ${res.status}` }
    const data = (await res.json()) as { models?: { name: string; size?: number }[] }
    return { ok: true, models: (data.models ?? []).map((m) => ({ name: m.name, size: m.size })) }
  } catch (err: any) {
    return { ok: false, models: [], error: err?.message ?? "Ollama not reachable" }
  }
}

export function pickOllamaModel(models: OllamaModel[], configured?: string): string {
  const want = (configured ?? "").trim()
  if (want && models.some((m) => m.name === want || m.name.startsWith(`${want}:`))) return want
  const coder = models.find((m) => /coder|code|llama|qwen|mistral/i.test(m.name))
  if (coder) return coder.name
  if (models.length) return models[0].name
  return DEFAULT_OLLAMA_MODEL
}

/** Apply workshop side effects after config changes (Ollama auth + default model). */
export async function applyWorkshopSideEffects(workshop: Config.Workshop | undefined): Promise<void> {
  const w = workshop ?? {}
  const enabled = w.ollama_enabled === true

  if (enabled) {
    await Auth.set("ollama", { type: "api", key: "ollama" })
    Log.Default.info(`Workshop: Ollama enabled (${w.ollama_model ?? "default"})`)
  } else {
    await Auth.remove("ollama").catch(() => {})
  }
}

export async function workshopStatus() {
  const global = await Config.getGlobal()
  const w = global.workshop ?? {}
  const probe = await probeOllama(w.ollama_base_url)
  const auth = await Auth.all()
  const connected: string[] = []
  if (auth.google?.type === "api") connected.push("google")
  if (auth.groq?.type === "api") connected.push("groq")
  if (auth.anthropic?.type === "api") connected.push("anthropic")
  if (auth.openai?.type === "api") connected.push("openai")
  if (auth.ollama?.type === "api" || w.ollama_enabled) connected.push("ollama")
  for (const id of ["google", "groq", "anthropic", "openai"] as const) {
    const envKey =
      id === "google"
        ? process.env.GOOGLE_GENERATIVE_AI_API_KEY || process.env.GEMINI_API_KEY
        : id === "groq"
          ? process.env.GROQ_API_KEY
          : id === "anthropic"
            ? process.env.ANTHROPIC_API_KEY
            : process.env.OPENAI_API_KEY
    if (envKey && !connected.includes(id)) connected.push(`${id} (env)`)
  }

  return {
    workshop: w,
    ollama: {
      running: probe.ok,
      models: probe.models.map((m) => m.name),
      error: probe.error,
    },
    connected,
    paths: {
      config: Global.Path.config,
      auth: `${Global.Path.data}/auth.json`,
      data: Global.Path.data,
    },
  }
}
