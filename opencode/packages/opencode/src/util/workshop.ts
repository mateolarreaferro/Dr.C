import { Auth } from "../auth"
import { Config } from "../config/config"
import { Global } from "../global"
import { Log } from "../util/log"
import { isProPlus } from "./tier"

const DEFAULT_SERVER = "http://127.0.0.1:11434"
const DEFAULT_OLLAMA_MODEL = "qwen2.5-coder:7b"

export interface OllamaModel {
  name: string
  size?: number
}

export function localLlmServerUrl(configured?: string): string {
  const raw = (configured ?? process.env.LOCAL_LLM_URL ?? process.env.OLLAMA_HOST ?? "").trim()
  let url = !raw ? DEFAULT_SERVER : raw.startsWith("http") ? raw : `http://${raw}`
  return url.replace(/\/$/, "").replace(/\/v1$/, "")
}

export function localLlmOpenAiBase(configured?: string): string {
  return `${localLlmServerUrl(configured)}/v1`
}

/** @deprecated use localLlmServerUrl */
export function ollamaBaseUrl(configured?: string): string {
  return localLlmServerUrl(configured)
}

async function probeOpenAiModels(baseUrl?: string): Promise<{ ok: boolean; models: OllamaModel[]; error?: string }> {
  const url = `${localLlmOpenAiBase(baseUrl)}/models`
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(5000) })
    if (!res.ok) return { ok: false, models: [], error: `HTTP ${res.status}` }
    const data = (await res.json()) as { data?: { id: string }[] }
    const models = (data.data ?? []).map((m) => ({ name: m.id })).filter((m) => m.name)
    if (!models.length) return { ok: false, models: [], error: "No models listed" }
    return { ok: true, models }
  } catch (err: any) {
    return { ok: false, models: [], error: err?.message ?? "Server not reachable" }
  }
}

async function probeOllamaTags(baseUrl?: string): Promise<{ ok: boolean; models: OllamaModel[]; error?: string }> {
  const url = `${localLlmServerUrl(baseUrl)}/api/tags`
  try {
    const res = await fetch(url, { signal: AbortSignal.timeout(4000) })
    if (!res.ok) return { ok: false, models: [], error: `HTTP ${res.status}` }
    const data = (await res.json()) as { models?: { name: string; size?: number }[] }
    const models = (data.models ?? []).map((m) => ({ name: m.name, size: m.size }))
    if (!models.length) return { ok: false, models: [], error: "No models listed" }
    return { ok: true, models }
  } catch (err: any) {
    return { ok: false, models: [], error: err?.message ?? "Ollama tags API not reachable" }
  }
}

export async function probeLocalLlm(baseUrl?: string): Promise<{ ok: boolean; models: OllamaModel[]; error?: string }> {
  const openAi = await probeOpenAiModels(baseUrl)
  if (openAi.ok) return openAi
  const tags = await probeOllamaTags(baseUrl)
  if (tags.ok) return tags
  return { ok: false, models: [], error: openAi.error ?? tags.error ?? "Local LLM server not reachable" }
}

/** @deprecated use probeLocalLlm */
export async function probeOllama(baseUrl?: string) {
  return probeLocalLlm(baseUrl)
}

export function pickOllamaModel(models: OllamaModel[], configured?: string): string {
  const want = (configured ?? "").trim()
  if (want && models.some((m) => m.name === want || m.name.startsWith(`${want}:`))) return want
  const coder = models.find((m) => /coder|code|llama|qwen|mistral/i.test(m.name))
  if (coder) return coder.name
  if (models.length) return models[0].name
  return DEFAULT_OLLAMA_MODEL
}

/** Clear ollama_prefer when Groq is connected so free cloud keys are used. */
export async function migrateWorkshopAuth(): Promise<void> {
  const auth = await Auth.all()
  const hasGroq = auth.groq?.type === "api" || Boolean(process.env.GROQ_API_KEY)
  if (!hasGroq) return

  const global = await Config.getGlobal()
  const w = global.workshop ?? {}
  if (!w.ollama_prefer) return

  await Config.updateGlobal({
    ...global,
    workshop: { ...w, ollama_prefer: false },
  })
  Log.Default.info("Workshop: cleared ollama_prefer — Groq key takes priority")
}

/** Apply workshop side effects after config changes (local LLM auth + default model). */
export async function applyWorkshopSideEffects(workshop: Config.Workshop | undefined): Promise<void> {
  const w = workshop ?? {}
  const enabled = w.ollama_enabled === true

  if (enabled) {
    await Auth.set("ollama", { type: "api", key: "ollama" })
    Log.Default.info(`Workshop: local LLM enabled (${w.ollama_model ?? "default"})`)
  } else {
    await Auth.remove("ollama").catch(() => {})
  }
}

export async function workshopStatus() {
  const global = await Config.getGlobal()
  const w = global.workshop ?? {}
  const probe = await probeLocalLlm(w.ollama_base_url)
  const auth = await Auth.all()
  const connected: string[] = []
  if (auth.openrouter?.type === "api") connected.push("openrouter")
  if (auth.groq?.type === "api") connected.push("groq")
  if (auth.google?.type === "api") connected.push("google")
  if (auth.anthropic?.type === "api") connected.push("anthropic")
  if (auth.openai?.type === "api") connected.push("openai")
  if (auth.ollama?.type === "api" || w.ollama_enabled) connected.push("ollama")
  for (const id of ["openrouter", "google", "groq", "anthropic", "openai"] as const) {
    const envKey =
      id === "openrouter"
        ? process.env.OPENROUTER_API_KEY
        : id === "google"
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
    proPlus: isProPlus(),
    paths: {
      config: Global.Path.config,
      auth: `${Global.Path.data}/auth.json`,
      data: Global.Path.data,
    },
  }
}
