import { QuestionTool } from "./question"
import { BashTool } from "./bash"
import { EditTool } from "./edit"
import { GlobTool } from "./glob"
import { GrepTool } from "./grep"
import { BatchTool } from "./batch"
import { ReadTool } from "./read"
import { TaskTool } from "./task"
import { TodoWriteTool, TodoReadTool } from "./todo"
import { WebFetchTool } from "./webfetch"
import { WriteTool } from "./write"
import { InvalidTool } from "./invalid"
import { SkillTool } from "./skill"
import type { Agent } from "../agent/agent"
import { Tool } from "./tool"
import { Instance } from "../project/instance"
import { Config } from "../config/config"
import path from "path"
import { type ToolContext as PluginToolContext, type ToolDefinition } from "@drc/plugin"
import z from "zod"
import { Plugin } from "../plugin"
import { WebSearchTool } from "./websearch"
import { CodeSearchTool } from "./codesearch"
import { Flag } from "@/flag/flag"
import { Log } from "@/util/log"
import { LspTool } from "./lsp"
import { Truncate } from "./truncation"
import { PlanExitTool, PlanEnterTool } from "./plan"
import { ApplyPatchTool } from "./apply_patch"
import { CsoundCompileTool } from "./csound_compile"
import { CsoundSmokeTool } from "./csound_smoke"
import { ErrorParseTool } from "./error_parse"
import { ApplyCsdPatchTool } from "./apply_csd_patch"
import { CsoundRenderTool } from "./csound_render"
import { CsoundInstallTool } from "./csound_install"
import { CsoundProposeAlternativesTool } from "./csound_propose_alternatives"
import { TaskParallelTool } from "./task_parallel"
import { CsoundExportHtmlTool } from "./csound_export_html"
import { AbletonSendClipTool } from "./ableton_send_clip"
import { AbletonSetParamTool } from "./ableton_set_param"
import { AbletonCreateTrackTool } from "./ableton_create_track"
import { SketchMoodPaletteTool } from "./sketch_mood_palette"
import { SketchBranchCompareTool } from "./sketch_branch_compare"
import { SketchSurpriseTool } from "./sketch_surprise"
import { SketchReferenceTool } from "./sketch_reference"
import { TechniqueLineageTool } from "./technique_lineage"
import { CsdWalkthroughTool } from "./csd_walkthrough"
import { CsoundChallengeTool } from "./csound_challenge"
import { LiveCodingStartStopTool } from "./live_coding_start_stop"
import { LiveCodingSetChannelTool } from "./live_coding_set_channel"
import { LiveCodingHotReloadTool } from "./live_coding_hot_reload"
import { EditByEarTool } from "./edit_by_ear"
import { SuggestParamsTool } from "./suggest_params"
import { AutoVariationTool } from "./auto_variation"
import { GestureToEnvelopeTool } from "./gesture_to_envelope"
import { ExportAbletonClipTool } from "./export_ableton_clip"
import { ExportStemsTool } from "./export_stems"
import { ExportPresetPackTool } from "./export_preset_pack"
import { ExportCabbageCompileTool } from "./export_cabbage_compile"
import { MemoryTool } from "./memory"
import { SystemPrompt } from "../session/system"

export namespace ToolRegistry {
  const log = Log.create({ service: "tool.registry" })

  // Tools included in sine mode (lightweight, cost-optimized)
  const SINE_MODE_TOOLS = new Set([
    "invalid", "question", "bash", "read", "glob", "grep",
    "edit", "write", "apply_csd_patch", "csound_compile", "csound_render", "csound_smoke",
  ])

  // Tools deferred from default loading — only included when contextually relevant
  const DEFERRED_TOOLS = new Set([
    "csound_install", "csound_export_html", "todowrite",
  ])

  export const state = Instance.state(async () => {
    const custom = [] as Tool.Info[]
    const glob = new Bun.Glob("{tool,tools}/*.{js,ts}")

    const matches = await Config.directories().then((dirs) =>
      dirs.flatMap((dir) => [...glob.scanSync({ cwd: dir, absolute: true, followSymlinks: true, dot: true })]),
    )
    if (matches.length) await Config.waitForDependencies()
    for (const match of matches) {
      const namespace = path.basename(match, path.extname(match))
      const mod = await import(match)
      for (const [id, def] of Object.entries<ToolDefinition>(mod)) {
        custom.push(fromPlugin(id === "default" ? namespace : `${namespace}_${id}`, def))
      }
    }

    const plugins = await Plugin.list()
    for (const plugin of plugins) {
      for (const [id, def] of Object.entries(plugin.tool ?? {})) {
        custom.push(fromPlugin(id, def))
      }
    }

    return { custom }
  })

  function fromPlugin(id: string, def: ToolDefinition): Tool.Info {
    return {
      id,
      init: async (initCtx) => ({
        parameters: z.object(def.args),
        description: def.description,
        execute: async (args, ctx) => {
          const pluginCtx = {
            ...ctx,
            directory: Instance.directory,
            worktree: Instance.worktree,
          } as unknown as PluginToolContext
          const result = await def.execute(args as any, pluginCtx)
          const out = await Truncate.output(result, {}, initCtx?.agent)
          return {
            title: "",
            output: out.truncated ? out.content : result,
            metadata: { truncated: out.truncated, outputPath: out.truncated ? out.outputPath : undefined },
          }
        },
      }),
    }
  }

  export async function register(tool: Tool.Info) {
    const { custom } = await state()
    const idx = custom.findIndex((t) => t.id === tool.id)
    if (idx >= 0) {
      custom.splice(idx, 1, tool)
      return
    }
    custom.push(tool)
  }

  async function all(agent?: Agent.Info): Promise<Tool.Info[]> {
    const custom = await state().then((x) => x.custom)
    const config = await Config.get()
    const isSineMode = agent?.options?.mode === "sine"

    const allTools: Tool.Info[] = [
      InvalidTool,
      ...(["app", "cli", "desktop"].includes(Flag.DRC_CLIENT) ? [QuestionTool] : []),
      BashTool,
      ReadTool,
      GlobTool,
      GrepTool,
      EditTool,
      WriteTool,
      ...(!isSineMode ? [TaskTool] : []),
      ...(!isSineMode ? [WebFetchTool] : []),
      ...(!isSineMode ? [TodoWriteTool] : []),
      // TodoReadTool,
      ...(!isSineMode ? [WebSearchTool] : []),
      ...(!isSineMode ? [CodeSearchTool] : []),
      ...(!isSineMode ? [SkillTool] : []),
      ApplyPatchTool,
      ...(Flag.DRC_EXPERIMENTAL_LSP_TOOL && !isSineMode ? [LspTool] : []),
      ...(config.experimental?.batch_tool === true && !isSineMode ? [BatchTool] : []),
      ...(Flag.DRC_EXPERIMENTAL_PLAN_MODE && Flag.DRC_CLIENT === "cli" && !isSineMode ? [PlanExitTool, PlanEnterTool] : []),
      CsoundCompileTool,
      CsoundSmokeTool,
      CsoundRenderTool,
      ApplyCsdPatchTool,
      ...(!isSineMode ? [ErrorParseTool] : []),
      ...(!isSineMode ? [CsoundProposeAlternativesTool] : []),
      ...(!isSineMode ? [TaskParallelTool] : []),
      ...(!isSineMode ? [CsoundExportHtmlTool] : []),
      ...(!isSineMode ? [AbletonSendClipTool] : []),
      ...(!isSineMode ? [AbletonSetParamTool] : []),
      ...(!isSineMode ? [AbletonCreateTrackTool] : []),
      ...(!isSineMode ? [SketchMoodPaletteTool] : []),
      ...(!isSineMode ? [SketchBranchCompareTool] : []),
      ...(!isSineMode ? [SketchSurpriseTool] : []),
      ...(!isSineMode ? [SketchReferenceTool] : []),
      ...(!isSineMode ? [TechniqueLineageTool] : []),
      ...(!isSineMode ? [CsdWalkthroughTool] : []),
      ...(!isSineMode ? [CsoundChallengeTool] : []),
      ...(!isSineMode ? [LiveCodingStartStopTool] : []),
      ...(!isSineMode ? [LiveCodingSetChannelTool] : []),
      ...(!isSineMode ? [LiveCodingHotReloadTool] : []),
      ...(!isSineMode ? [EditByEarTool] : []),
      ...(!isSineMode ? [SuggestParamsTool] : []),
      ...(!isSineMode ? [AutoVariationTool] : []),
      ...(!isSineMode ? [GestureToEnvelopeTool] : []),
      ...(!isSineMode ? [ExportAbletonClipTool] : []),
      ...(!isSineMode ? [ExportStemsTool] : []),
      ...(!isSineMode ? [ExportPresetPackTool] : []),
      ...(!isSineMode ? [ExportCabbageCompileTool] : []),
      ...(!isSineMode ? [MemoryTool] : []),
      ...custom,
    ]

    // In complex mode, defer rarely-used tools unless contextually needed
    if (!isSineMode && agent) {
      // Only include csound_install if Csound is not installed
      const versionInfo = await SystemPrompt.getCsoundVersionInfo()
      if (versionInfo.version !== "not installed") {
        // Csound is installed — skip the install tool
      } else {
        allTools.push(CsoundInstallTool)
      }
    } else if (!isSineMode) {
      // No agent context — include install tool as fallback
      allTools.push(CsoundInstallTool)
    }

    return allTools
  }

  export async function ids() {
    return all().then((x) => x.map((t) => t.id))
  }

  export async function tools(
    model: {
      providerID: string
      modelID: string
    },
    agent?: Agent.Info,
  ) {
    const tools = await all(agent)
    const result = await Promise.all(
      tools
        .filter((t) => {
          // Enable websearch/codesearch for zen users OR via enable flag
          if (t.id === "codesearch" || t.id === "websearch") {
            return model.providerID === "opencode" || Flag.DRC_ENABLE_EXA
          }

          // use apply tool in same format as codex
          const usePatch =
            model.modelID.includes("gpt-") && !model.modelID.includes("oss") && !model.modelID.includes("gpt-4")
          if (t.id === "apply_patch") return usePatch
          if (t.id === "edit" || t.id === "write") return !usePatch

          return true
        })
        .map(async (t) => {
          using _ = log.time(t.id)
          const tool = await t.init({ agent })
          const output = {
            description: tool.description,
            parameters: tool.parameters,
          }
          await Plugin.trigger("tool.definition", { toolID: t.id }, output)
          return {
            id: t.id,
            ...tool,
            description: output.description,
            parameters: output.parameters,
          }
        }),
    )
    return result
  }
}
