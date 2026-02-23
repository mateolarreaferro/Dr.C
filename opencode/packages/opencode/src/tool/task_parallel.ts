import { Tool } from "./tool"
import z from "zod"
import { Session } from "../session"
import { MessageV2 } from "../session/message-v2"
import { Identifier } from "../id/id"
import { Agent } from "../agent/agent"
import { SessionPrompt } from "../session/prompt"
import { iife } from "@/util/iife"
import { Config } from "../config/config"
import { PermissionNext } from "@/permission/next"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.task-parallel" })

const DESCRIPTION = `Launch 2-4 sub-agents in parallel for independent tasks.

Use this tool when the request involves multiple independent dimensions that can be worked on simultaneously (e.g., "warm pad with reverb, modulation, and EQ"). Each sub-task runs concurrently, dramatically reducing latency.

Guidelines:
- Each sub-task must be independent (changes don't share signal chain or modify the same code)
- Provide 2-4 tasks with clear descriptions and prompts
- Each task gets a focused sub-agent (csound-synthesis, csound-effects, csound-modulation, or general)
- Results are aggregated — if one sub-task fails, others still complete
- Default timeout: 60s per sub-task`

const parameters = z.object({
  tasks: z
    .array(
      z.object({
        description: z.string().describe("Short (3-5 word) description of the sub-task"),
        prompt: z.string().describe("Detailed prompt for the sub-agent"),
        subagent_type: z.string().describe("Which agent to use (csound-synthesis, csound-effects, csound-modulation, general, explore)"),
      }),
    )
    .min(2)
    .max(4)
    .describe("Array of independent tasks to run in parallel"),
  timeout_seconds: z
    .number()
    .min(10)
    .max(120)
    .optional()
    .describe("Timeout per sub-task in seconds (default 30)"),
})

export const TaskParallelTool = Tool.define(
  "task_parallel",
  {
    description: DESCRIPTION,
    parameters,
    async execute(params, ctx) {
      const config = await Config.get()
      const timeoutMs = (params.timeout_seconds ?? 30) * 1000

      // Verify all requested agents exist
      const agentConfigs: Array<{ agent: Agent.Info; task: (typeof params.tasks)[0] }> = []
      for (const task of params.tasks) {
        const agent = await Agent.get(task.subagent_type)
        if (!agent) {
          throw new Error(`Unknown agent type: ${task.subagent_type}`)
        }
        agentConfigs.push({ agent, task })
      }

      // Permission check for parallel task execution
      await ctx.ask({
        permission: "task",
        patterns: params.tasks.map((t) => t.subagent_type),
        always: ["*"],
        metadata: {
          description: `Parallel: ${params.tasks.map((t) => t.description).join(", ")}`,
          task_count: params.tasks.length,
        },
      })

      const msg = await MessageV2.get({ sessionID: ctx.sessionID, messageID: ctx.messageID })
      if (msg.info.role !== "assistant") throw new Error("Not an assistant message")

      ctx.metadata({
        title: `Parallel: ${params.tasks.length} sub-tasks`,
        metadata: {
          tasks: params.tasks.map((t) => ({ description: t.description, agent: t.subagent_type })),
        },
      })

      log.info("launching parallel tasks", {
        count: params.tasks.length,
        agents: params.tasks.map((t) => t.subagent_type),
      })

      // Launch all tasks concurrently
      const taskPromises = agentConfigs.map(async ({ agent, task }) => {
        const startTime = Date.now()

        try {
          const hasTaskPermission = agent.permission.some((rule) => rule.permission === "task")

          const session = await Session.create({
            parentID: ctx.sessionID,
            title: task.description + ` (@${agent.name} parallel subagent)`,
            permission: [
              {
                permission: "todowrite",
                pattern: "*",
                action: "deny",
              },
              {
                permission: "todoread",
                pattern: "*",
                action: "deny",
              },
              ...(hasTaskPermission
                ? []
                : [
                    {
                      permission: "task" as const,
                      pattern: "*" as const,
                      action: "deny" as const,
                    },
                  ]),
              ...(config.experimental?.primary_tools?.map((t) => ({
                pattern: "*",
                action: "allow" as const,
                permission: t,
              })) ?? []),
            ],
          })

          const model = agent.model ?? {
            modelID: msg.info.modelID,
            providerID: msg.info.providerID,
          }

          const messageID = Identifier.ascending("message")

          // Set up abort on timeout
          const abortController = new AbortController()
          const timer = setTimeout(() => {
            abortController.abort()
            SessionPrompt.cancel(session.id)
          }, timeoutMs)

          // Also abort on parent abort
          const parentAbortHandler = () => {
            clearTimeout(timer)
            abortController.abort()
            SessionPrompt.cancel(session.id)
          }
          ctx.abort.addEventListener("abort", parentAbortHandler)

          try {
            const promptParts = await SessionPrompt.resolvePromptParts(task.prompt)

            const result = await SessionPrompt.prompt({
              messageID,
              sessionID: session.id,
              model: {
                modelID: model.modelID,
                providerID: model.providerID,
              },
              agent: agent.name,
              tools: {
                todowrite: false,
                todoread: false,
                ...(hasTaskPermission ? {} : { task: false }),
                ...Object.fromEntries((config.experimental?.primary_tools ?? []).map((t) => [t, false])),
              },
              parts: promptParts,
            })

            const text = result.parts.findLast((x) => x.type === "text")?.text ?? ""
            const duration = Date.now() - startTime

            return {
              description: task.description,
              agent: task.subagent_type,
              sessionId: session.id,
              success: true,
              output: text,
              duration,
            }
          } finally {
            clearTimeout(timer)
            ctx.abort.removeEventListener("abort", parentAbortHandler)
          }
        } catch (e) {
          const duration = Date.now() - startTime
          log.warn("parallel sub-task failed", {
            description: task.description,
            error: String(e),
            duration,
          })

          return {
            description: task.description,
            agent: task.subagent_type,
            sessionId: undefined as string | undefined,
            success: false,
            output: `Error: ${String(e)}`,
            duration,
          }
        }
      })

      // Wait for all tasks
      const results = await Promise.allSettled(taskPromises)

      const taskResults = results.map((r) => {
        if (r.status === "fulfilled") return r.value
        return {
          description: "Unknown",
          agent: "unknown",
          sessionId: undefined as string | undefined,
          success: false,
          output: `Unexpected error: ${String(r.reason)}`,
          duration: 0,
        }
      })

      const successes = taskResults.filter((r) => r.success).length
      const failures = taskResults.filter((r) => !r.success).length
      const totalDuration = Math.max(...taskResults.map((r) => r.duration))

      log.info("parallel tasks completed", {
        successes,
        failures,
        totalDuration,
      })

      const outputParts: string[] = [
        `## Parallel Execution: ${successes}/${taskResults.length} succeeded (${totalDuration}ms wall-clock)`,
        "",
      ]

      for (const result of taskResults) {
        outputParts.push(
          `### ${result.success ? "\u2713" : "\u2717"} ${result.description} (@${result.agent}, ${result.duration}ms)`,
        )
        if (result.sessionId) {
          outputParts.push(`task_id: ${result.sessionId}`)
        }
        outputParts.push("")
        outputParts.push("<task_result>")
        outputParts.push(result.output)
        outputParts.push("</task_result>")
        outputParts.push("")
      }

      return {
        title: `Parallel: ${successes}/${taskResults.length} succeeded`,
        metadata: {
          successes,
          failures,
          totalDuration,
          tasks: taskResults.map((r) => ({
            description: r.description,
            agent: r.agent,
            success: r.success,
            sessionId: r.sessionId,
            duration: r.duration,
          })),
        },
        output: outputParts.join("\n"),
      }
    },
  },
)
