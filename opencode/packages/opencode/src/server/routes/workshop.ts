import { Hono } from "hono"
import { describeRoute, resolver, validator } from "hono-openapi"
import z from "zod"
import { lazy } from "../../util/lazy"
import { Config } from "../../config/config"
import {
  applyWorkshopSideEffects,
  localLlmOpenAiBase,
  pickOllamaModel,
  probeLocalLlm,
  workshopStatus,
} from "../../util/workshop"

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
        const probe = await probeLocalLlm(workshop.ollama_base_url)
        if (workshop.ollama_enabled && probe.ok) {
          const baseURL = localLlmOpenAiBase(workshop.ollama_base_url)
          const model = workshop.ollama_model || pickOllamaModel(probe.models, workshop.ollama_model)
          merged.provider = {
            ...(merged.provider ?? {}),
            ollama: {
              name: "Local LLM (Ollama / LM Studio)",
              npm: "@ai-sdk/openai-compatible",
              options: { baseURL, apiKey: "local" },
              models: { [model]: { name: model, tool_call: true, temperature: true } },
            },
          }
          merged.model = `ollama/${model}`
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
        const probe = await probeLocalLlm(global.workshop?.ollama_base_url)
        if (!probe.ok) {
          return c.json({
            ok: false,
            message:
              probe.error ??
              "Local LLM server not running — Ollama (11434), LM Studio (1234), or set workshop.ollama_base_url",
            models: [],
          })
        }
        return c.json({
          ok: true,
          message: `Local LLM server reachable — ${probe.models.length} model(s)`,
          models: probe.models.map((m) => m.name),
        })
      },
    ),
)
