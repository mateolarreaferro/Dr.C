import { Log } from "../util/log"
import { CsdSnapshot } from "../validation/snapshot"

const log = Log.create({ service: "param-writer" })

export namespace ParamWriter {
  /**
   * Update a parameter value in a CSD file.
   *
   * Handles:
   * - `init kVar = value`  or  `kVar init value`
   * - `chnset value, "channel"`
   * - `#define MACRO #value#`
   * - `iVar = value` (simple assignment)
   */
  export async function updateParameter(
    filePath: string,
    paramName: string,
    newValue: number | string,
  ): Promise<{ success: boolean; line?: number }> {
    const content = await Bun.file(filePath).text()
    const lines = content.split("\n")
    let modified = false
    let modifiedLine: number | undefined

    const valStr = typeof newValue === "number" ? formatNumber(newValue) : newValue

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      const trimmed = line.trim()
      if (trimmed.startsWith(";") || !trimmed) continue

      // Pattern 1: #define MACRO #value#
      const defineMatch = trimmed.match(new RegExp(`^#define\\s+${escapeRegExp(paramName)}\\s+#\\s*[^#]*\\s*#`))
      if (defineMatch) {
        lines[i] = line.replace(
          new RegExp(`(#define\\s+${escapeRegExp(paramName)}\\s+#\\s*)[^#]*(\\s*#)`),
          `$1${valStr}$2`,
        )
        modified = true
        modifiedLine = i + 1
        break
      }

      // Pattern 2: iVar = value (simple init assignment)
      const initAssign = trimmed.match(new RegExp(`^(${escapeRegExp(paramName)})\\s*=\\s*[\\d.eE+-]+`))
      if (initAssign) {
        lines[i] = line.replace(
          new RegExp(`(${escapeRegExp(paramName)}\\s*=\\s*)[\\d.eE+-]+`),
          `$1${valStr}`,
        )
        modified = true
        modifiedLine = i + 1
        break
      }

      // Pattern 3: kVar init value
      const initKeyword = trimmed.match(new RegExp(`^(${escapeRegExp(paramName)})\\s+init\\s+[\\d.eE+-]+`))
      if (initKeyword) {
        lines[i] = line.replace(
          new RegExp(`(${escapeRegExp(paramName)}\\s+init\\s+)[\\d.eE+-]+`),
          `$1${valStr}`,
        )
        modified = true
        modifiedLine = i + 1
        break
      }

      // Pattern 4: chnset value, "channel"
      const chnsetMatch = trimmed.match(new RegExp(`chnset\\s+[\\d.eE+-]+\\s*,\\s*"${escapeRegExp(paramName)}"`))
      if (chnsetMatch) {
        lines[i] = line.replace(
          new RegExp(`(chnset\\s+)[\\d.eE+-]+(\\s*,\\s*"${escapeRegExp(paramName)}")`),
          `$1${valStr}$2`,
        )
        modified = true
        modifiedLine = i + 1
        break
      }
    }

    if (!modified) {
      log.warn("parameter not found", { paramName, filePath })
      return { success: false }
    }

    // Write back
    const newContent = lines.join("\n")
    await Bun.write(filePath, newContent)

    // Capture snapshot
    try {
      await CsdSnapshot.capture(filePath)
    } catch (e) {
      log.warn("failed to capture snapshot after param update", { error: e })
    }

    log.info("parameter updated", { paramName, newValue: valStr, line: modifiedLine })
    return { success: true, line: modifiedLine }
  }

  function formatNumber(n: number): string {
    if (Number.isInteger(n)) return n.toString()
    // Preserve reasonable precision
    const str = n.toPrecision(6)
    // Remove trailing zeros after decimal
    return str.replace(/\.?0+$/, "")
  }

  function escapeRegExp(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
  }
}
