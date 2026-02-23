/**
 * PDF text cleanup heuristics.
 *
 * After raw text extraction from PDFs, this module cleans up common artifacts:
 * - Page headers and footers
 * - Page numbers
 * - Broken line wraps
 * - Excessive whitespace
 * - Table of contents fragments
 */

export interface CleanupOptions {
  removePageNumbers?: boolean
  removeHeaders?: boolean
  fixLineBreaks?: boolean
  removeBlankPages?: boolean
}

const DEFAULTS: Required<CleanupOptions> = {
  removePageNumbers: true,
  removeHeaders: true,
  fixLineBreaks: true,
  removeBlankPages: true,
}

/**
 * Clean extracted PDF text with configurable heuristics.
 */
export function cleanPdfText(raw: string, opts?: CleanupOptions): string {
  const options = { ...DEFAULTS, ...opts }
  let text = raw

  // Normalize line endings
  text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n")

  if (options.removePageNumbers) {
    text = removePageNumbers(text)
  }

  if (options.removeHeaders) {
    text = removeHeadersFooters(text)
  }

  if (options.fixLineBreaks) {
    text = fixBrokenLineBreaks(text)
  }

  if (options.removeBlankPages) {
    text = removeBlankPages(text)
  }

  // Collapse 3+ consecutive blank lines to 2
  text = text.replace(/\n{4,}/g, "\n\n\n")

  // Remove leading/trailing whitespace from each line (preserve indentation for code)
  text = text
    .split("\n")
    .map((line) => {
      // Preserve indentation for code-like lines (starting with spaces/tabs for CSD code)
      if (/^[\t ]+(instr|endin|opcode|endop|if|while|until|goto|kgoto|igoto|loop_|sr|ksmps|nchnls|0dbfs)/.test(line)) {
        return line.trimEnd()
      }
      return line.trim()
    })
    .join("\n")

  return text.trim()
}

/**
 * Remove standalone page numbers.
 * Common patterns: "42", "Chapter 1 42", "42 Chapter 1"
 */
function removePageNumbers(text: string): string {
  const lines = text.split("\n")
  const cleaned: string[] = []

  for (const line of lines) {
    const trimmed = line.trim()

    // Standalone number (page number)
    if (/^\d{1,4}$/.test(trimmed)) continue

    // Number at start/end of short line (header with page number)
    if (trimmed.length < 80 && /^(\d{1,4})\s+/.test(trimmed)) {
      const withoutNum = trimmed.replace(/^\d{1,4}\s+/, "")
      if (withoutNum.length < 60 && /^[A-Z]/.test(withoutNum)) {
        // Likely a header with page number — keep just the text
        cleaned.push(withoutNum)
        continue
      }
    }

    if (trimmed.length < 80 && /\s+(\d{1,4})$/.test(trimmed)) {
      const withoutNum = trimmed.replace(/\s+\d{1,4}$/, "")
      if (withoutNum.length < 60) {
        cleaned.push(withoutNum)
        continue
      }
    }

    cleaned.push(line)
  }

  return cleaned.join("\n")
}

/**
 * Remove repeating headers/footers that appear on every page.
 * Detects by finding short lines that repeat more than 5 times.
 */
function removeHeadersFooters(text: string): string {
  const lines = text.split("\n")
  const lineCounts = new Map<string, number>()

  // Count occurrences of short lines
  for (const line of lines) {
    const trimmed = line.trim()
    if (trimmed.length > 5 && trimmed.length < 80) {
      const normalized = trimmed.toLowerCase().replace(/\d+/g, "#")
      lineCounts.set(normalized, (lineCounts.get(normalized) ?? 0) + 1)
    }
  }

  // Find patterns that repeat too many times (likely headers/footers)
  const repeatingPatterns = new Set<string>()
  for (const [pattern, count] of lineCounts) {
    if (count > 5) {
      repeatingPatterns.add(pattern)
    }
  }

  if (repeatingPatterns.size === 0) return text

  // Remove matching lines
  const cleaned = lines.filter((line) => {
    const trimmed = line.trim()
    if (trimmed.length > 5 && trimmed.length < 80) {
      const normalized = trimmed.toLowerCase().replace(/\d+/g, "#")
      return !repeatingPatterns.has(normalized)
    }
    return true
  })

  return cleaned.join("\n")
}

/**
 * Fix broken line breaks from PDF extraction.
 * PDFs often break lines mid-sentence at column boundaries.
 */
function fixBrokenLineBreaks(text: string): string {
  const lines = text.split("\n")
  const result: string[] = []

  for (let i = 0; i < lines.length; i++) {
    const current = lines[i]
    const next = lines[i + 1]

    // Don't join blank lines
    if (!current.trim()) {
      result.push(current)
      continue
    }

    // Don't join if current line looks like a header
    if (current.trim().length < 80 && /^[A-Z][A-Z\s]+$/.test(current.trim())) {
      result.push(current)
      continue
    }

    // Don't join if current line looks like code
    if (/^[\t ]+(instr|endin|opcode|\w+\s+oscil|[aki]\w+\s+=)/.test(current)) {
      result.push(current)
      continue
    }

    // Join if: current doesn't end with sentence-ender, next starts lowercase
    if (
      next &&
      next.trim() &&
      !current.trim().match(/[.!?:;]$/) &&
      !current.trim().match(/^\s*[-*•]/) &&
      /^[a-z]/.test(next.trim()) &&
      current.trim().length > 30
    ) {
      // This looks like a broken line — join with space
      result.push(current.trimEnd() + " " + next.trim())
      i++ // Skip next line
      continue
    }

    result.push(current)
  }

  return result.join("\n")
}

/**
 * Remove pages that are mostly blank (< 20 chars of content).
 */
function removeBlankPages(text: string): string {
  // PDF page breaks often show as form feed characters or many blank lines
  const pages = text.split(/\f/)
  if (pages.length <= 1) return text

  const nonBlank = pages.filter((page) => {
    const content = page.replace(/\s/g, "")
    return content.length >= 20
  })

  return nonBlank.join("\n\n")
}

/**
 * Detect section boundaries in cleaned PDF text.
 * Returns array of { title, startLine, level }.
 */
export function detectSections(text: string): Array<{ title: string; startLine: number; level: number }> {
  const lines = text.split("\n")
  const sections: Array<{ title: string; startLine: number; level: number }> = []

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    if (!line) continue

    // Chapter header: "Chapter N" or "CHAPTER N"
    const chapterMatch = line.match(/^(Chapter|CHAPTER)\s+(\d+|[IVXLC]+)[.:]\s*(.*)/)
    if (chapterMatch) {
      sections.push({ title: line, startLine: i, level: 1 })
      continue
    }

    // Part header
    const partMatch = line.match(/^(Part|PART)\s+(\d+|[IVXLC]+)[.:]\s*(.*)/)
    if (partMatch) {
      sections.push({ title: line, startLine: i, level: 0 })
      continue
    }

    // Numbered section: "1.2 Section Title"
    const numberedMatch = line.match(/^(\d+\.\d+(?:\.\d+)?)\s+(.{5,80})/)
    if (numberedMatch && /^[A-Z]/.test(numberedMatch[2])) {
      const level = numberedMatch[1].split(".").length
      sections.push({ title: line, startLine: i, level })
      continue
    }

    // ALL CAPS header (short line)
    if (line.length > 5 && line.length < 60 && line === line.toUpperCase() && /[A-Z]{3,}/.test(line)) {
      sections.push({ title: line, startLine: i, level: 2 })
      continue
    }
  }

  return sections
}
