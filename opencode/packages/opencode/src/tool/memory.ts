import z from "zod"
import { Tool } from "./tool"
import { MemoryStore } from "../memory/store"
import { MemoryManager } from "../memory/manager"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.memory" })

const DESCRIPTION = `Interact with DrC's persistent memory system. Recall past sessions, save preferences, or look up technique journals.

Actions:
- "recall": Search across session summaries and technique journals. Provide a search query.
- "save": Save an explicit memory entry. Specify category: "preference" (sonic identity), "technique" (technique journal), "recipe" (successful CSD pattern), or "note" (general).
- "identity": Return the user's current sonic identity profile.
- "journal": Return the technique journal for a specific technique.

Use this when the user references past work, asks about their preferences, or wants to save something for later.`

export const MemoryTool = Tool.define(
  "memory",
  {
    description: DESCRIPTION,
    parameters: z.object({
      action: z.enum(["recall", "save", "identity", "journal"]).describe("The memory action to perform"),
      query: z.string().describe("Search term (for recall), content to remember (for save), or technique name (for journal)"),
      category: z.enum(["preference", "technique", "recipe", "note"]).optional().describe("Category for save action"),
    }),
    async execute(params, ctx): Promise<{ title: string; output: string; metadata: Record<string, any> }> {
      const { action, query, category } = params

      log.info("memory tool invoked", { action, query, category })

      switch (action) {
        case "recall": {
          const [summaries, techniques] = await Promise.all([
            MemoryStore.searchSummaries(query),
            MemoryStore.searchTechniques(query),
          ])

          const parts: string[] = []

          if (summaries.length > 0) {
            parts.push("## Session Matches")
            for (const s of summaries.slice(0, 5)) {
              const date = new Date(s.timestamp).toISOString().split("T")[0]
              parts.push(`- [${date}] ${s.summary}`)
              if (s.techniques.length > 0) {
                parts.push(`  Techniques: ${s.techniques.join(", ")}`)
              }
            }
          }

          if (techniques.length > 0) {
            parts.push("\n## Technique Matches")
            for (const t of techniques.slice(0, 5)) {
              const successCount = t.entries.filter((e) => e.outcome === "success").length
              parts.push(`- ${t.technique}: ${t.entries.length} entries, ${successCount} successful`)
              if (t.preferredPatterns.length > 0) {
                parts.push(`  Preferred patterns: ${t.preferredPatterns.join("; ")}`)
              }
              // Show most recent entry
              const lastEntry = t.entries[t.entries.length - 1]
              if (lastEntry) {
                const date = new Date(lastEntry.date).toISOString().split("T")[0]
                parts.push(`  Last: [${date}] ${lastEntry.description}`)
                if (lastEntry.csdSnippet) {
                  parts.push(`  Snippet:\n${lastEntry.csdSnippet}`)
                }
              }
            }
          }

          if (parts.length === 0) {
            return {
              title: "No memories found",
              output: `No memories found matching "${query}". The user may not have worked with this topic before.`,
              metadata: { action, query, resultCount: 0 },
            }
          }

          return {
            title: `Found ${summaries.length + techniques.length} memories`,
            output: parts.join("\n"),
            metadata: { action, query, resultCount: summaries.length + techniques.length },
          }
        }

        case "save": {
          const cat = category || "note"

          switch (cat) {
            case "preference": {
              // Parse the query as an aesthetic preference
              await MemoryStore.updateSonicIdentity({
                aestheticPreferences: [query],
              })
              return {
                title: "Saved preference",
                output: `Saved aesthetic preference: "${query}"`,
                metadata: { action, category: cat, saved: query },
              }
            }

            case "technique": {
              await MemoryStore.addTechniqueEntry(query, {
                date: Date.now(),
                sessionID: ctx.sessionID,
                description: `Manually saved technique note: ${query}`,
                outcome: "success",
              })
              return {
                title: "Saved technique",
                output: `Saved technique entry for: "${query}"`,
                metadata: { action, category: cat, saved: query },
              }
            }

            case "recipe": {
              // Save as a technique entry with the recipe as the snippet
              const [techniqueName, ...rest] = query.split(":")
              const description = rest.join(":").trim() || query
              await MemoryStore.addTechniqueEntry(techniqueName.trim(), {
                date: Date.now(),
                sessionID: ctx.sessionID,
                description: `Recipe: ${description}`,
                outcome: "success",
                csdSnippet: description,
                lesson: "Saved as successful recipe",
              })
              return {
                title: "Saved recipe",
                output: `Saved recipe for "${techniqueName.trim()}": ${description}`,
                metadata: { action, category: cat, saved: query },
              }
            }

            case "note": {
              // Save as a session summary note
              await MemoryStore.saveSessionSummary({
                sessionID: ctx.sessionID,
                timestamp: Date.now(),
                summary: `Note: ${query}`,
                techniques: [],
                renderCount: 0,
                exported: false,
                designTreeNodes: 0,
                duration: 0,
              })
              return {
                title: "Saved note",
                output: `Saved note: "${query}"`,
                metadata: { action, category: cat, saved: query },
              }
            }
          }
          break
        }

        case "identity": {
          const identity = await MemoryStore.getSonicIdentity()
          const parts: string[] = ["## Sonic Identity"]

          if (identity.aestheticPreferences.length > 0) {
            parts.push(`Aesthetic preferences: ${identity.aestheticPreferences.join(", ")}`)
          }
          if (identity.signatureChains.length > 0) {
            parts.push(`Signature chains: ${identity.signatureChains.join("; ")}`)
          }
          if (identity.referenceArtists.length > 0) {
            parts.push(`Reference artists: ${identity.referenceArtists.join(", ")}`)
          }
          if (identity.avoidances.length > 0) {
            parts.push(`Avoids: ${identity.avoidances.join(", ")}`)
          }

          const topOpcodes = Object.entries(identity.frequentOpcodes)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 10)
          if (topOpcodes.length > 0) {
            parts.push(`Top opcodes: ${topOpcodes.map(([op, ct]) => `${op}(${ct})`).join(", ")}`)
          }

          if (parts.length === 1) {
            parts.push("No sonic identity recorded yet. The profile builds up over sessions.")
          }

          return {
            title: "Sonic Identity",
            output: parts.join("\n"),
            metadata: { action, hasIdentity: identity.aestheticPreferences.length > 0 },
          }
        }

        case "journal": {
          const journal = await MemoryStore.getTechniqueJournal(query)

          if (!journal) {
            // Try searching
            const results = await MemoryStore.searchTechniques(query)
            if (results.length > 0) {
              const parts: string[] = [`No exact match for "${query}", but found related techniques:`]
              for (const t of results.slice(0, 3)) {
                parts.push(`- ${t.technique}: ${t.entries.length} entries`)
              }
              return {
                title: `Related techniques for "${query}"`,
                output: parts.join("\n"),
                metadata: { action, query, found: false, related: results.length },
              }
            }

            return {
              title: `No journal for "${query}"`,
              output: `No technique journal found for "${query}". Available techniques: ${(await MemoryStore.listTechniques()).join(", ") || "none yet"}`,
              metadata: { action, query, found: false },
            }
          }

          const parts: string[] = [`## ${journal.technique} Journal`]
          parts.push(`Entries: ${journal.entries.length}`)

          const successCount = journal.entries.filter((e) => e.outcome === "success").length
          parts.push(`Success rate: ${successCount}/${journal.entries.length}`)

          if (journal.preferredPatterns.length > 0) {
            parts.push(`Preferred patterns: ${journal.preferredPatterns.join("; ")}`)
          }

          parts.push("\n### Recent Entries")
          for (const entry of journal.entries.slice(-5)) {
            const date = new Date(entry.date).toISOString().split("T")[0]
            parts.push(`- [${date}] ${entry.description} (${entry.outcome})`)
            if (entry.csdSnippet) {
              parts.push(`  \`\`\`\n${entry.csdSnippet}\n  \`\`\``)
            }
            if (entry.lesson) {
              parts.push(`  Lesson: ${entry.lesson}`)
            }
          }

          return {
            title: `${journal.technique} Journal`,
            output: parts.join("\n"),
            metadata: { action, query, found: true, entryCount: journal.entries.length },
          }
        }
      }

      return {
        title: "Unknown action",
        output: `Unknown memory action: "${action}". Use recall, save, identity, or journal.`,
        metadata: { action, error: true },
      }
    },
  },
)
