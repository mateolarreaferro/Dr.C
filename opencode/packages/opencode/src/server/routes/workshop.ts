import { Hono } from "hono"
import { describeRoute, resolver, validator } from "hono-openapi"
import z from "zod"
import { Auth } from "../../auth"
import { lazy } from "../../util/lazy"
import { Config } from "../../config/config"
import {
  applyWorkshopSideEffects,
  ollamaBaseUrl,
  pickOllamaModel,
  probeOllama,
  workshopStatus,
} from "../../util/workshop"

const GROQ_DEFAULT_MODEL = "llama-3.3-70b-versatile"

const PatchSchema = z.object({
  workshop: Config.Workshop,
})

export const WorkshopRoutes = lazy(() =>
  new Hono()
    .get(
      "/",
      describeRoute({
        summary: "Get Dr.C workshop settings",
        description: "API keys status, Ollama probe, config paths, and external tool paths.",
        operationId: "workshop.get",
        responses: {
          200: {
            description: "Workshop settings snapshot",
            content: {
              "application/json": {
                schema: resolver(z.any()),
              },
            },
          },
        },
      }),
      async (c) => c.json(await workshopStatus()),
    )
    .patch(
      "/",
      describeRoute({
        summary: "Update Dr.C workshop settings",
        operationId: "workshop.update",
        responses: {
          200: {
            description: "Updated workshop settings",
            content: {
              "application/json": {
                schema: resolver(z.any()),
              },
            },
          },
        },
      }),
      validator("json", PatchSchema),
      async (c) => {
        const { workshop } = c.req.valid("json")
        const global = await Config.getGlobal()
        const merged = { ...global, workshop }
        const auth = await Auth.all()
        const hasGroq = auth.groq?.type === "api" || Boolean(process.env.GROQ_API_KEY)
        if (hasGroq && !workshop.ollama_prefer) {
          merged.model = `groq/${GROQ_DEFAULT_MODEL}`
        }
        if (workshop.ollama_enabled) {
          const probe = await probeOllama(workshop.ollama_base_url)
          const base = ollamaBaseUrl(workshop.ollama_base_url)
          const model = workshop.ollama_model || pickOllamaModel(probe.models, workshop.ollama_model)
          merged.provider = {
            ...(merged.provider ?? {}),
            ollama: {
              name: "Ollama (local)",
              npm: "@ai-sdk/openai-compatible",
              options: { baseURL: `${base}/v1`, apiKey: "ollama" },
              models: { [model]: { name: model, tool_call: true, temperature: true } },
            },
          }
          if (workshop.ollama_prefer) merged.model = `ollama/${model}`
        }
        await Config.updateGlobal(merged)
        await applyWorkshopSideEffects(workshop)
        return c.json(await workshopStatus())
      },
    )
    .post(
      "/ollama/test",
      describeRoute({
        summary: "Test Ollama connection",
        operationId: "workshop.ollama.test",
        responses: {
          200: {
            description: "Ollama probe result",
            content: {
              "application/json": {
                schema: resolver(z.object({ ok: z.boolean(), message: z.string(), models: z.array(z.string()) })),
              },
            },
          },
        },
      }),
      async (c) => {
        const global = await Config.getGlobal()
        const probe = await probeOllama(global.workshop?.ollama_base_url)
        if (!probe.ok) {
          return c.json({
            ok: false,
            message: probe.error ?? "Ollama not running — install from ollama.com",
            models: [],
          })
        }
        return c.json({
          ok: true,
          message: `Ollama running — ${probe.models.length} model(s) installed`,
          models: probe.models.map((m) => m.name),
        })
      },
    ),
)
