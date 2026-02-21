import { Config } from "../config/config"
import z from "zod"
import { Provider } from "../provider/provider"
import { generateObject, streamObject, type ModelMessage } from "ai"
import { SystemPrompt } from "../session/system"
import { Instance } from "../project/instance"
import { Truncate } from "../tool/truncation"
import { Auth } from "../auth"
import { ProviderTransform } from "../provider/transform"

import PROMPT_GENERATE from "./generate.txt"
import PROMPT_COMPACTION from "./prompt/compaction.txt"
import PROMPT_EXPLORE from "./prompt/explore.txt"
import PROMPT_SUMMARY from "./prompt/summary.txt"
import PROMPT_TITLE from "./prompt/title.txt"
import PROMPT_CSOUND from "../session/prompt/csound.txt"
import { PermissionNext } from "@/permission/next"
import { mergeDeep, pipe, sortBy, values } from "remeda"
import { Global } from "@/global"
import path from "path"
import { Plugin } from "@/plugin"
import { Skill } from "../skill"

export namespace Agent {
  export const Info = z
    .object({
      name: z.string(),
      description: z.string().optional(),
      mode: z.enum(["subagent", "primary", "all"]),
      native: z.boolean().optional(),
      hidden: z.boolean().optional(),
      topP: z.number().optional(),
      temperature: z.number().optional(),
      color: z.string().optional(),
      permission: PermissionNext.Ruleset,
      model: z
        .object({
          modelID: z.string(),
          providerID: z.string(),
        })
        .optional(),
      variant: z.string().optional(),
      prompt: z.string().optional(),
      options: z.record(z.string(), z.any()),
      steps: z.number().int().positive().optional(),
    })
    .meta({
      ref: "Agent",
    })
  export type Info = z.infer<typeof Info>

  const state = Instance.state(async () => {
    const cfg = await Config.get()

    const skillDirs = await Skill.dirs()
    const defaults = PermissionNext.fromConfig({
      "*": "allow",
      doom_loop: "ask",
      external_directory: {
        "*": "ask",
        [Truncate.GLOB]: "allow",
        ...Object.fromEntries(skillDirs.map((dir) => [path.join(dir, "*"), "allow"])),
      },
      question: "deny",
      plan_enter: "deny",
      plan_exit: "deny",
      // mirrors github.com/github/gitignore Node.gitignore pattern for .env files
      read: {
        "*": "allow",
        "*.env": "ask",
        "*.env.*": "ask",
        "*.env.example": "allow",
      },
    })
    const user = PermissionNext.fromConfig(cfg.permission ?? {})

    const result: Record<string, Info> = {
      csound: {
        name: "csound",
        description: "DrC Csound sound design specialist. Translates musical ideas into synthesis code, generates and validates .csd files, renders audio, and guides iterative sound design.",
        prompt: PROMPT_CSOUND,
        model: { providerID: "anthropic", modelID: "claude-sonnet-4-5" },
        options: { designMode: true },
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            question: "allow",
            plan_enter: "allow",
            csound_install: "allow",
            csound_compile: "allow",
            csound_smoke: "allow",
            csound_render: "allow",
            error_parse: "allow",
            apply_csd_patch: "allow",
            csound_propose_alternatives: "allow",
            task_parallel: "allow",
            task: "allow",
          }),
          user,
        ),
        mode: "primary",
        native: true,
      },
      build: {
        name: "build",
        description: "General-purpose build agent. Executes tools based on configured permissions.",
        options: {},
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            question: "allow",
            plan_enter: "allow",
          }),
          user,
        ),
        mode: "primary",
        native: true,
        hidden: true,
      },
      plan: {
        name: "plan",
        description: "Plan mode. Disallows all edit tools.",
        options: {},
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            question: "allow",
            plan_exit: "allow",
            external_directory: {
              [path.join(Global.Path.data, "plans", "*")]: "allow",
            },
            edit: {
              "*": "deny",
              [path.join(".drc", "plans", "*.md")]: "allow",
              [path.relative(Instance.worktree, path.join(Global.Path.data, path.join("plans", "*.md")))]: "allow",
            },
          }),
          user,
        ),
        mode: "primary",
        native: true,
      },
      general: {
        name: "general",
        description: `General-purpose agent for researching complex questions and executing multi-step tasks. Use this agent to execute multiple units of work in parallel.`,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            todoread: "deny",
            todowrite: "deny",
          }),
          user,
        ),
        options: {},
        mode: "subagent",
        native: true,
      },
      explore: {
        name: "explore",
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
            grep: "allow",
            glob: "allow",
            list: "allow",
            bash: "allow",
            webfetch: "allow",
            websearch: "allow",
            codesearch: "allow",
            read: "allow",
            external_directory: {
              [Truncate.GLOB]: "allow",
            },
          }),
          user,
        ),
        description: `Fast agent specialized for exploring codebases. Use this when you need to quickly find files by patterns (eg. "src/components/**/*.tsx"), search code for keywords (eg. "API endpoints"), or answer questions about the codebase (eg. "how do API endpoints work?"). When calling this agent, specify the desired thoroughness level: "quick" for basic searches, "medium" for moderate exploration, or "very thorough" for comprehensive analysis across multiple locations and naming conventions.`,
        prompt: PROMPT_EXPLORE,
        options: {},
        mode: "subagent",
        native: true,
      },
      compaction: {
        name: "compaction",
        mode: "primary",
        native: true,
        hidden: true,
        prompt: PROMPT_COMPACTION,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
          }),
          user,
        ),
        options: {},
      },
      title: {
        name: "title",
        mode: "primary",
        options: {},
        native: true,
        hidden: true,
        temperature: 0.5,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
          }),
          user,
        ),
        prompt: PROMPT_TITLE,
      },
      summary: {
        name: "summary",
        mode: "primary",
        options: {},
        native: true,
        hidden: true,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
          }),
          user,
        ),
        prompt: PROMPT_SUMMARY,
      },
      "csound-synthesis": {
        name: "csound-synthesis",
        description:
          "Csound synthesis specialist. Handles oscillators, FM/AM synthesis, additive/subtractive synthesis, wavetable design, and sound generation. Use for tasks focused on creating or modifying the core sound source.",
        prompt: `You are a Csound synthesis specialist sub-agent. Your focus is exclusively on sound generation:
- Oscillators (oscili, poscil, vco2, buzz, gbuzz)
- FM/AM synthesis (foscili, cross modulation)
- Additive synthesis (multiple oscillators, partials)
- Subtractive synthesis (filtered noise, resonant filters on rich sources)
- Wavetable/table-based synthesis (tablei, oscili with custom GEN tables)
- Physical modeling basics (pluck, wgbow, wgflute)

Apply changes using apply_csd_patch. Always compile and smoke-test after changes.
Use Csound naming: kCamelCase for k-rate, aCamelCase for a-rate, iCamelCase for i-rate.`,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
            read: "allow",
            csound_compile: "allow",
            csound_smoke: "allow",
            apply_csd_patch: "allow",
            csound_render: "allow",
          }),
          user,
        ),
        options: {},
        mode: "subagent",
        native: true,
      },
      "csound-effects": {
        name: "csound-effects",
        description:
          "Csound effects specialist. Handles reverb, delay, filters, distortion, EQ, and signal routing. Use for tasks focused on processing and shaping existing sound.",
        prompt: `You are a Csound effects processing specialist sub-agent. Your focus is exclusively on signal processing:
- Reverb (reverbsc, freeverb, nreverb, alpass, comb)
- Delay (delay, vdelay3, flanger, chorus)
- Filters (moogladder, lpf18, butterlp/hp/bp, statevar, zdf_2pole)
- Distortion (distort1, clip, powershape, fold, decimator)
- EQ (pareq, rbjeq, eqfil, bqrez)
- Dynamics (compress2, dam, follow2)
- Routing (outch, pan2, vbap)

Apply changes using apply_csd_patch. Always compile and smoke-test after changes.
Use Csound naming: kCamelCase for k-rate, aCamelCase for a-rate, iCamelCase for i-rate.`,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
            read: "allow",
            csound_compile: "allow",
            csound_smoke: "allow",
            apply_csd_patch: "allow",
            csound_render: "allow",
          }),
          user,
        ),
        options: {},
        mode: "subagent",
        native: true,
      },
      "csound-modulation": {
        name: "csound-modulation",
        description:
          "Csound modulation specialist. Handles envelopes, LFOs, control signals, scheduling, and time-varying parameters. Use for tasks focused on movement and evolution in sound.",
        prompt: `You are a Csound modulation and control specialist sub-agent. Your focus is exclusively on time-varying control:
- Envelopes (madsr, linsegr, expsegr, transeg, jspline)
- LFOs (lfo, oscili at sub-audio rate, randi, randh)
- Control signals (jitter, rspline, dust2, gausstrig)
- Scheduling (event, scoreline_i, schedkwhen, metro)
- Parameter mapping and scaling (port, portk, limit, scale)
- MIDI/channel control (ctrl7, chnget, chnset)

Apply changes using apply_csd_patch. Always compile and smoke-test after changes.
Use Csound naming: kCamelCase for k-rate, aCamelCase for a-rate, iCamelCase for i-rate.`,
        permission: PermissionNext.merge(
          defaults,
          PermissionNext.fromConfig({
            "*": "deny",
            read: "allow",
            csound_compile: "allow",
            csound_smoke: "allow",
            apply_csd_patch: "allow",
            csound_render: "allow",
          }),
          user,
        ),
        options: {},
        mode: "subagent",
        native: true,
      },
    }

    for (const [key, value] of Object.entries(cfg.agent ?? {})) {
      if (value.disable) {
        delete result[key]
        continue
      }
      let item = result[key]
      if (!item)
        item = result[key] = {
          name: key,
          mode: "all",
          permission: PermissionNext.merge(defaults, user),
          options: {},
          native: false,
        }
      if (value.model) item.model = Provider.parseModel(value.model)
      item.variant = value.variant ?? item.variant
      item.prompt = value.prompt ?? item.prompt
      item.description = value.description ?? item.description
      item.temperature = value.temperature ?? item.temperature
      item.topP = value.top_p ?? item.topP
      item.mode = value.mode ?? item.mode
      item.color = value.color ?? item.color
      item.hidden = value.hidden ?? item.hidden
      item.name = value.name ?? item.name
      item.steps = value.steps ?? item.steps
      item.options = mergeDeep(item.options, value.options ?? {})
      item.permission = PermissionNext.merge(item.permission, PermissionNext.fromConfig(value.permission ?? {}))
    }

    // Ensure Truncate.GLOB is allowed unless explicitly configured
    for (const name in result) {
      const agent = result[name]
      const explicit = agent.permission.some((r) => {
        if (r.permission !== "external_directory") return false
        if (r.action !== "deny") return false
        return r.pattern === Truncate.GLOB
      })
      if (explicit) continue

      result[name].permission = PermissionNext.merge(
        result[name].permission,
        PermissionNext.fromConfig({ external_directory: { [Truncate.GLOB]: "allow" } }),
      )
    }

    return result
  })

  export async function get(agent: string) {
    return state().then((x) => x[agent])
  }

  export async function list() {
    const cfg = await Config.get()
    return pipe(
      await state(),
      values(),
      sortBy([(x) => (cfg.default_agent ? x.name === cfg.default_agent : x.name === "csound"), "desc"]),
    )
  }

  export async function defaultAgent() {
    const cfg = await Config.get()
    const agents = await state()

    if (cfg.default_agent) {
      const agent = agents[cfg.default_agent]
      if (!agent) throw new Error(`default agent "${cfg.default_agent}" not found`)
      if (agent.mode === "subagent") throw new Error(`default agent "${cfg.default_agent}" is a subagent`)
      if (agent.hidden === true) throw new Error(`default agent "${cfg.default_agent}" is hidden`)
      return agent.name
    }

    const primaryVisible = Object.values(agents).find((a) => a.mode !== "subagent" && a.hidden !== true)
    if (!primaryVisible) throw new Error("no primary visible agent found")
    return primaryVisible.name
  }

  export async function generate(input: { description: string; model?: { providerID: string; modelID: string } }) {
    const cfg = await Config.get()
    const defaultModel = input.model ?? (await Provider.defaultModel())
    const model = await Provider.getModel(defaultModel.providerID, defaultModel.modelID)
    const language = await Provider.getLanguage(model)

    const system = [PROMPT_GENERATE]
    await Plugin.trigger("experimental.chat.system.transform", { model }, { system })
    const existing = await list()

    const params = {
      experimental_telemetry: {
        isEnabled: cfg.experimental?.openTelemetry,
        metadata: {
          userId: cfg.username ?? "unknown",
        },
      },
      temperature: 0.3,
      messages: [
        ...system.map(
          (item): ModelMessage => ({
            role: "system",
            content: item,
          }),
        ),
        {
          role: "user",
          content: `Create an agent configuration based on this request: \"${input.description}\".\n\nIMPORTANT: The following identifiers already exist and must NOT be used: ${existing.map((i) => i.name).join(", ")}\n  Return ONLY the JSON object, no other text, do not wrap in backticks`,
        },
      ],
      model: language,
      schema: z.object({
        identifier: z.string(),
        whenToUse: z.string(),
        systemPrompt: z.string(),
      }),
    } satisfies Parameters<typeof generateObject>[0]

    if (defaultModel.providerID === "openai" && (await Auth.get(defaultModel.providerID))?.type === "oauth") {
      const result = streamObject({
        ...params,
        providerOptions: ProviderTransform.providerOptions(model, {
          instructions: SystemPrompt.instructions(),
          store: false,
        }),
        onError: () => {},
      })
      for await (const part of result.fullStream) {
        if (part.type === "error") throw part.error
      }
      return result.object
    }

    const result = await generateObject(params)
    return result.object
  }
}
