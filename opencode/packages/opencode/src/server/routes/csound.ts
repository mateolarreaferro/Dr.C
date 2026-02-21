import { Hono } from "hono"
import { describeRoute, validator, resolver } from "hono-openapi"
import z from "zod"
import { lazy } from "../../util/lazy"
import { Log } from "../../util/log"
import { ValidationPipeline } from "../../validation/pipeline"
import { CsdSnapshot } from "../../validation/snapshot"
import { ContractValidator } from "../../validation/contract"
import { CsdParser } from "../../csound/parser"
import { parseCsoundErrors } from "../../tool/error_parse"
import { spawn } from "child_process"

const log = Log.create({ service: "csound-routes" })

const DiagnosticSchema = z.object({
  severity: z.enum(["error", "warning", "info"]),
  line: z.number().nullable(),
  col: z.number().nullable(),
  message: z.string(),
  opcode: z.string().nullable(),
})

const CompileResultSchema = z.object({
  exitCode: z.number(),
  diagnostics: DiagnosticSchema.array(),
  stdout: z.string(),
  stderr: z.string(),
})

const SnapshotSchema = z.object({
  hash: z.string(),
  filePath: z.string(),
  timestamp: z.number(),
  size: z.number(),
})

const ViolationSchema = z.object({
  type: z.string(),
  severity: z.enum(["error", "warning"]),
  message: z.string(),
  channel: z.string().optional(),
  line: z.number().optional(),
  section: z.string().optional(),
})

export const CsoundRoutes = lazy(() =>
  new Hono()
    .post(
      "/compile",
      describeRoute({
        summary: "Compile CSD file",
        description: "Compile a Csound .csd file and return structured diagnostics.",
        operationId: "csound.compile",
        responses: {
          200: {
            description: "Compilation result",
            content: {
              "application/json": {
                schema: resolver(CompileResultSchema),
              },
            },
          },
        },
      }),
      validator(
        "json",
        z.object({
          filePath: z.string().meta({ description: "Absolute path to the .csd file" }),
        }),
      ),
      async (c) => {
        const { filePath } = c.req.valid("json")
        log.info("compile request", { filePath })

        const result = await compileFile(filePath)
        return c.json(result)
      },
    )
    .post(
      "/smoke_run",
      describeRoute({
        summary: "Smoke test CSD file",
        description: "Run a short smoke test on a .csd file to detect runtime crashes.",
        operationId: "csound.smoke_run",
        responses: {
          200: {
            description: "Smoke test result",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    exitCode: z.number(),
                    passed: z.boolean(),
                    timedOut: z.boolean(),
                    stderr: z.string(),
                  }),
                ),
              },
            },
          },
        },
      }),
      validator(
        "json",
        z.object({
          filePath: z.string().meta({ description: "Absolute path to the .csd file" }),
          durationSeconds: z.number().min(0.1).max(5).optional().meta({ description: "Duration in seconds (default 1)" }),
        }),
      ),
      async (c) => {
        const { filePath, durationSeconds = 1 } = c.req.valid("json")
        log.info("smoke run request", { filePath, durationSeconds })

        const result = await smokeRun(filePath, durationSeconds)
        return c.json(result)
      },
    )
    .post(
      "/propose_patch",
      describeRoute({
        summary: "Propose a patch",
        description: "Generate a patch proposal from a prompt and constraints.",
        operationId: "csound.propose_patch",
        responses: {
          200: {
            description: "Patch proposal",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    patch: z.string(),
                    description: z.string(),
                    targetSections: z.string().array(),
                  }),
                ),
              },
            },
          },
        },
      }),
      validator(
        "json",
        z.object({
          filePath: z.string().meta({ description: "Path to the .csd file to patch" }),
          prompt: z.string().meta({ description: "What to change" }),
          constraints: z
            .object({
              maxCpu: z.number().optional(),
              ksmps: z.number().optional(),
            })
            .optional(),
        }),
      ),
      async (c) => {
        const body = c.req.valid("json")
        log.info("propose patch request", { filePath: body.filePath })

        // In the full implementation, this would invoke the LLM to generate a patch.
        // For now, return a placeholder structure.
        return c.json({
          patch: "",
          description: `Patch proposal for: ${body.prompt}`,
          targetSections: ["CsInstruments"],
        })
      },
    )
    .post(
      "/apply_patch",
      describeRoute({
        summary: "Apply a patch",
        description: "Apply a validated patch to an active .csd file.",
        operationId: "csound.apply_patch",
        responses: {
          200: {
            description: "Apply result",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    success: z.boolean(),
                    compileResult: CompileResultSchema.optional(),
                    violations: ViolationSchema.array(),
                  }),
                ),
              },
            },
          },
        },
      }),
      validator(
        "json",
        z.object({
          filePath: z.string().meta({ description: "Path to the .csd file" }),
          patch: z.string().meta({ description: "Unified diff patch content" }),
          validate: z.boolean().optional().meta({ description: "Run compilation check after applying (default true)" }),
        }),
      ),
      async (c) => {
        const { filePath, patch, validate: shouldValidate = true } = c.req.valid("json")
        log.info("apply patch request", { filePath })

        // Snapshot before applying
        await CsdSnapshot.capture(filePath)

        // Apply patch (simplified — in full implementation uses the tool)
        const content = await Bun.file(filePath).text()
        // TODO: Apply unified diff patch
        // For now, this is a placeholder — the actual patch application
        // would use the ApplyCsdPatchTool logic

        let compileResult
        if (shouldValidate) {
          compileResult = await compileFile(filePath)
        }

        const violations = ContractValidator.validate(content)

        return c.json({
          success: !compileResult || compileResult.exitCode === 0,
          compileResult,
          violations,
        })
      },
    )
    .get(
      "/history",
      describeRoute({
        summary: "List snapshots",
        description: "List snapshot history for a .csd file.",
        operationId: "csound.history",
        responses: {
          200: {
            description: "Snapshot history",
            content: {
              "application/json": {
                schema: resolver(SnapshotSchema.array()),
              },
            },
          },
        },
      }),
      validator(
        "query",
        z.object({
          filePath: z.string().meta({ description: "Path to the .csd file" }),
        }),
      ),
      async (c) => {
        const { filePath } = c.req.valid("query")
        const history = await CsdSnapshot.listHistory(filePath)
        return c.json(history)
      },
    )
    .post(
      "/restore_snapshot",
      describeRoute({
        summary: "Restore snapshot",
        description: "Restore a previous snapshot of a .csd file.",
        operationId: "csound.restore_snapshot",
        responses: {
          200: {
            description: "Restore result",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    success: z.boolean(),
                  }),
                ),
              },
            },
          },
        },
      }),
      validator(
        "json",
        z.object({
          filePath: z.string().meta({ description: "Path to the .csd file" }),
          hash: z.string().meta({ description: "Snapshot hash to restore" }),
          sessionID: z.string().optional().meta({ description: "Session ID for workspace resolution" }),
        }),
      ),
      async (c) => {
        const { filePath, hash, sessionID } = c.req.valid("json")
        log.info("restore snapshot request", { filePath, hash, sessionID })

        // Capture current state before restoring
        await CsdSnapshot.capture(filePath, sessionID)
        await CsdSnapshot.restore(filePath, hash, sessionID)

        return c.json({ success: true })
      },
    )
    .get(
      "/parse",
      describeRoute({
        summary: "Parse CSD file",
        description: "Parse a CSD file and return its structure including parameters, instruments, and globals.",
        operationId: "csound.parse",
        responses: {
          200: {
            description: "Parsed CSD structure",
            content: {
              "application/json": {
                schema: resolver(
                  z.object({
                    parameters: z.array(
                      z.object({
                        name: z.string(),
                        rate: z.enum(["k", "a", "i", "S"]),
                        source: z.string(),
                        value: z.string().optional(),
                        line: z.number(),
                        instrument: z.string().optional(),
                        smoothed: z.boolean(),
                        channel: z.string().optional(),
                        range: z.tuple([z.number(), z.number()]).optional(),
                      }),
                    ),
                    instruments: z.array(
                      z.object({
                        id: z.string(),
                        startLine: z.number(),
                        endLine: z.number(),
                        description: z.string().optional(),
                        parameterCount: z.number(),
                      }),
                    ),
                    globals: z.object({
                      sr: z.number().optional(),
                      ksmps: z.number().optional(),
                      nchnls: z.number().optional(),
                      "0dbfs": z.number().optional(),
                    }),
                    macros: z.array(
                      z.object({
                        name: z.string(),
                        value: z.string(),
                        line: z.number(),
                      }),
                    ),
                  }),
                ),
              },
            },
          },
        },
      }),
      validator(
        "query",
        z.object({
          filePath: z.string().meta({ description: "Absolute path to the .csd file" }),
        }),
      ),
      async (c) => {
        const { filePath } = c.req.valid("query")
        log.info("parse request", { filePath })

        const content = await Bun.file(filePath).text()
        const structure = CsdParser.parse(content)

        return c.json({
          parameters: structure.parameters,
          instruments: structure.instruments.map((i) => ({
            id: i.id,
            startLine: i.startLine,
            endLine: i.endLine,
            description: i.description,
            parameterCount: i.parameters.length,
          })),
          globals: structure.globals,
          macros: structure.macros,
        })
      },
    ),
)

async function compileFile(
  filePath: string,
): Promise<{ exitCode: number; diagnostics: z.infer<typeof DiagnosticSchema>[]; stdout: string; stderr: string }> {
  return new Promise((resolve, reject) => {
    let stdout = ""
    let stderr = ""

    const proc = spawn("csound", ["-n", "-d", "-m0", "-W", "-o", "null", filePath], {
      stdio: ["ignore", "pipe", "pipe"],
    })

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString()
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    proc.once("exit", (code) => {
      resolve({
        exitCode: code ?? 1,
        diagnostics: parseCsoundErrors(stderr),
        stdout,
        stderr,
      })
    })

    proc.once("error", (err) => {
      reject(err)
    })
  })
}

async function smokeRun(
  filePath: string,
  durationSeconds: number,
): Promise<{ exitCode: number; passed: boolean; timedOut: boolean; stderr: string }> {
  return new Promise((resolve, reject) => {
    let stderr = ""
    let exited = false

    const proc = spawn("csound", ["-d", "-m0", "-W", "-o", "/dev/null", filePath], {
      stdio: ["ignore", "pipe", "pipe"],
      detached: process.platform !== "win32",
    })

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString()
    })

    const timer = setTimeout(() => {
      if (!exited) {
        try {
          if (proc.pid && process.platform !== "win32") process.kill(-proc.pid, "SIGTERM")
          else proc.kill("SIGTERM")
        } catch {}
      }
    }, durationSeconds * 1000 + 500)

    proc.once("exit", (code) => {
      exited = true
      clearTimeout(timer)
      const exitCode = code ?? 1
      resolve({
        exitCode,
        passed: exitCode === 0 || exitCode === 143 || exitCode === 137,
        timedOut: exitCode === 143 || exitCode === 137,
        stderr,
      })
    })

    proc.once("error", (err) => {
      exited = true
      clearTimeout(timer)
      reject(err)
    })
  })
}
