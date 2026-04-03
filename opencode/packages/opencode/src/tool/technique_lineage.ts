import z from "zod"
import { Tool } from "./tool"
import { TECHNIQUE_LINEAGE } from "../educational/lineage-data"
import { FLOSS_LINKS } from "../educational/floss-links"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.technique-lineage" })

const DESCRIPTION = `Show the historical lineage of a synthesis technique — its origins, key figures, milestones, and connection to Csound opcodes.

Use this tool when the user asks about the history of a technique, wants to understand where a synthesis approach came from, or is curious about the people and institutions behind the sounds they're creating.

Supported techniques include: FM synthesis, subtractive synthesis, granular synthesis, additive synthesis, physical modeling, spectral processing, wavetable synthesis, stochastic synthesis, sample-based synthesis, ring modulation.`

export const TechniqueLineageTool = Tool.define(
  "technique_lineage",
  {
    description: DESCRIPTION,
    parameters: z.object({
      technique: z
        .string()
        .describe(
          "The synthesis technique to look up (e.g., 'fm synthesis', 'granular synthesis', 'physical modeling')",
        ),
    }),
    async execute(params, ctx) {
      const query = params.technique.toLowerCase().trim()

      log.info("looking up technique lineage", { technique: query })

      // Try exact match first, then fuzzy
      let lineage = TECHNIQUE_LINEAGE[query]
      if (!lineage) {
        // Try partial match
        const key = Object.keys(TECHNIQUE_LINEAGE).find(
          (k) => k.includes(query) || query.includes(k),
        )
        if (key) lineage = TECHNIQUE_LINEAGE[key]
      }

      if (!lineage) {
        const available = Object.keys(TECHNIQUE_LINEAGE).join(", ")
        return {
          title: "Technique not found",
          output: `No lineage data found for "${params.technique}". Available techniques: ${available}`,
          metadata: { technique: params.technique, found: false, eventCount: 0, opcodes: [] as string[] },
        }
      }

      // Format the lineage as a chronological chain
      const parts: string[] = []
      parts.push(`## ${params.technique} — Historical Lineage`)
      parts.push("")

      for (const event of lineage.events) {
        const opcodesStr =
          event.opcodes && event.opcodes.length > 0
            ? `  Csound opcodes: \`${event.opcodes.join("`, `")}\``
            : ""
        parts.push(`### ${event.year} — ${event.figure}`)
        parts.push(event.description)
        if (opcodesStr) parts.push(opcodesStr)
        parts.push("")
      }

      // Add FLOSS manual link if available
      const flossLink = FLOSS_LINKS[query]
      if (flossLink) {
        parts.push(`## Further Reading`)
        parts.push(`FLOSS Manual: ${flossLink}`)
      }

      // Add opcode-specific FLOSS links from the lineage events
      const allOpcodes = lineage.events
        .flatMap((e) => e.opcodes ?? [])
        .filter((v, i, a) => a.indexOf(v) === i)

      if (allOpcodes.length > 0) {
        const opcodeLinks = allOpcodes
          .filter((op) => FLOSS_LINKS[op])
          .map((op) => `- \`${op}\`: ${FLOSS_LINKS[op]}`)

        if (opcodeLinks.length > 0) {
          parts.push("")
          parts.push(`## Opcode References`)
          parts.push(...opcodeLinks)
        }
      }

      return {
        title: `Lineage: ${params.technique}`,
        output: parts.join("\n"),
        metadata: {
          technique: params.technique,
          found: true,
          eventCount: lineage.events.length,
          opcodes: allOpcodes,
        },
      }
    },
  },
)
