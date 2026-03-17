import z from "zod"
import path from "path"
import { Tool } from "./tool"
import DESCRIPTION from "./csound_export_html.txt"
import { generateCsoundHTML } from "./csound_export_html_template"
import { SessionWorkspace } from "../session/workspace"
import { Hook } from "@/hook"

export const CsoundExportHtmlTool = Tool.define(
  "csound_export_html",
  {
    description: DESCRIPTION,
    parameters: z.object({
      filePath: z.string().describe("Absolute path to the .csd file to export"),
      title: z.string().optional().describe("Display title for the HTML page (defaults to filename)"),
    }),
    async execute(params, ctx) {
      const filePath = SessionWorkspace.resolve(ctx.sessionID, params.filePath)

      const file = Bun.file(filePath)
      if (!(await file.exists())) {
        throw new Error(`File not found: ${filePath}`)
      }

      if (!filePath.endsWith(".csd")) {
        throw new Error(`Expected a .csd file, got: ${filePath}`)
      }

      ctx.metadata({
        metadata: {
          status: "exporting",
          filePath,
        },
      })

      // Trigger pre-export hook for validation
      await Hook.trigger("pre-export", {
        sessionID: ctx.sessionID,
        filePath: params.filePath,
        metadata: { title: params.title },
      })

      const csdContent = await file.text()
      const basename = path.basename(filePath, ".csd")
      const title = params.title || basename
      const html = generateCsoundHTML(csdContent, title)

      const htmlPath = path.join(path.dirname(filePath), `${basename}.html`)
      await Bun.write(htmlPath, html)

      ctx.metadata({
        metadata: {
          status: "success",
          filePath,
          htmlPath,
        },
      })

      return {
        title: `Exported ${basename}.html`,
        metadata: {
          htmlPath,
          filePath,
          status: "success",
        },
        output: [
          `## CSD to HTML Export: SUCCESS`,
          ``,
          `Output: ${htmlPath}`,
          `Title: ${title}`,
          `Size: ${html.length} bytes`,
          ``,
          `The HTML file is self-contained and can be opened in any modern browser.`,
          `It uses @csound/browser@7 from CDN for playback.`,
        ].join("\n"),
      }
    },
  },
)
