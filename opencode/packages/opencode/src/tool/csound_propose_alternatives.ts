import z from "zod"
import { Tool } from "./tool"
import { Question } from "../question"
import { CsdSnapshot } from "../validation/snapshot"
import { DesignTree } from "../csound/design-tree"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.csound-propose-alternatives" })

const DESCRIPTION = `Present 2-4 design alternatives for the user to choose from during Csound sound design.

Use this tool when the user asks for a change and multiple valid approaches exist. Each alternative should vary along a different dimension (technique, character, complexity).

The user sees a multi-choice question with your alternatives. After they select one, you receive the chosen approach and should apply it.

Guidelines:
- Always provide at least 2 alternatives, up to 4
- Each alternative needs a short label (1-5 words) and a description explaining the sonic result
- Include an "approach" field describing the implementation strategy
- Include a "patch" field with the unified diff or code snippet to apply
- Vary alternatives along different axes: technique, timbre, complexity, CPU cost`

export const CsoundProposeAlternativesTool = Tool.define(
  "csound_propose_alternatives",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file being designed"),
      request: z.string().describe("What the user asked for (e.g., 'add reverb to this synth')"),
      alternatives: z
        .array(
          z.object({
            label: z.string().describe("Short name for this alternative (1-5 words, e.g., 'Warm Plate Reverb')"),
            description: z.string().describe("Sonic character description (what it sounds like)"),
            approach: z.string().describe("Implementation approach (what opcodes/techniques to use)"),
            patch: z.string().describe("The unified diff or code to apply if selected"),
          }),
        )
        .min(2)
        .max(4)
        .describe("Design alternatives to present to the user"),
    }),
    async execute(params, ctx) {
      const { filePath, request, alternatives } = params

      log.info("proposing alternatives", {
        filePath,
        request,
        count: alternatives.length,
      })

      // Present alternatives as a question to the user
      const answers = await Question.ask({
        sessionID: ctx.sessionID,
        questions: [
          {
            question: `How would you like to approach: "${request}"?`,
            header: "Design Choice",
            options: alternatives.map((alt) => ({
              label: alt.label,
              description: `${alt.description} — ${alt.approach}`,
            })),
          },
        ],
        tool: ctx.callID ? { messageID: ctx.messageID, callID: ctx.callID } : undefined,
      })

      const selectedLabels = answers[0] ?? []
      const selectedLabel = selectedLabels[0]

      // Find the selected alternative
      const selected = alternatives.find((a) => a.label === selectedLabel)

      if (!selected) {
        return {
          title: "No alternative selected",
          output: `The user did not select any of the proposed alternatives. Ask them what they'd like to do instead.`,
          metadata: {
            selected: undefined as string | undefined,
            request,
            snapshotHash: undefined as string | undefined,
            approach: undefined as string | undefined,
          },
        }
      }

      // Capture snapshot before changes
      let snapshotHash: string | undefined
      try {
        snapshotHash = await CsdSnapshot.capture(filePath)
      } catch (e) {
        log.warn("failed to capture pre-change snapshot", { error: e })
      }

      // Load or create design tree and add node
      try {
        let tree = await DesignTree.load(filePath)
        if (!tree) {
          // Create tree with initial state
          const initialHash = snapshotHash ?? "unknown"
          tree = DesignTree.create(filePath, initialHash, "Initial CSD")
        }

        const { state: updatedTree, nodeID } = DesignTree.addNode(tree, {
          snapshotHash: snapshotHash ?? "pending",
          description: selected.label,
          sonicCharacter: selected.description,
          sessionID: ctx.sessionID,
          metadata: { request, approach: selected.approach },
        })

        // Auto-name branch from selected alternative label
        DesignTree.renameBranch(updatedTree, nodeID, selected.label)

        DesignTree.selectNode(updatedTree, nodeID)
        // Fire-and-forget tree save — don't block the main pipeline
        DesignTree.save(updatedTree).catch((e) => log.warn("tree save failed", { error: e }))
      } catch (e) {
        log.warn("failed to update design tree", { error: e })
      }

      return {
        title: `Selected: ${selected.label}`,
        output: [
          `The user selected: "${selected.label}"`,
          `Sonic character: ${selected.description}`,
          `Approach: ${selected.approach}`,
          ``,
          `Now apply this patch to ${filePath}:`,
          ``,
          selected.patch,
          ``,
          `After applying, compile and smoke-test to verify.`,
        ].join("\n"),
        metadata: {
          selected: selected.label,
          request,
          snapshotHash,
          approach: selected.approach,
        },
      }
    },
  },
)
