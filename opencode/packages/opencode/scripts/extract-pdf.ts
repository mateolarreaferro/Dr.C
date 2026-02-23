#!/usr/bin/env bun
/**
 * PDF-to-text extraction for knowledge sources.
 *
 * Extracts text from PDF books in knowledge/books/ and outputs cleaned .txt files
 * to resources/knowledge/sources/ for the prose chunking pipeline.
 *
 * Dependencies: pdf-parse (install via `bun add -d pdf-parse`)
 *
 * Usage:
 *   bun run scripts/extract-pdf.ts [--book name] [--all]
 */

import fs from "fs/promises"
import path from "path"
import { cleanPdfText, detectSections } from "./lib/pdf-cleaner"

const ROOT = path.resolve(import.meta.dir, "..")
const PROJECT_ROOT = path.resolve(ROOT, "..", "..", "..")
const BOOKS_DIR = path.join(PROJECT_ROOT, "knowledge", "books")
const OUTPUT_DIR = path.join(ROOT, "resources", "knowledge", "sources")

// Book definitions with PDF paths and output names
const BOOK_DEFS: Array<{
  id: string
  name: string
  pdfPath: string // Relative to BOOKS_DIR
  outputName: string
  type: "book" | "manual" | "reference"
}> = [
  {
    id: "floss-manual",
    name: "Csound FLOSS Manual 8.1.1",
    pdfPath: "_BOOK-MANUAL-Csound FLOSS Manual 8.1.1-PDF/csound-flossmanual-8.1.1.pdf",
    outputName: "floss_manual.txt",
    type: "manual",
  },
  {
    id: "canonical-manual",
    name: "Csound Canonical Manual 6.18",
    pdfPath: "_BOOK-MANUAL-Csound Canonical Manual 6.1.8 - PDF/Csound6.18.0_manual.pdf",
    outputName: "canonical_manual.txt",
    type: "reference",
  },
  {
    id: "zucco",
    name: "Sound Synthesis with Csound — Zucco",
    pdfPath: "_BOOK-Sound Synthesis with Csound - Zucco/SoundSynthesiswithCsound.pdf",
    outputName: "zucco_synthesis.txt",
    type: "book",
  },
  {
    id: "horner",
    name: "Cooking with Csound — Horner",
    pdfPath: "_BOOK-Cooking with Csound - Horner/Cooking with Csound.pdf",
    outputName: "horner_cooking.txt",
    type: "book",
  },
  {
    id: "lazzarini-csound",
    name: "Csound — Lazzarini",
    pdfPath: "_BOOK-Csound - Lazzarini/Victor Lazzarini - Csound.pdf",
    outputName: "lazzarini_csound.txt",
    type: "book",
  },
  {
    id: "lazzarini-instruments",
    name: "Computer Music Instruments — Lazzarini",
    pdfPath: "_BOOK-Computer Music Instruments I - Lazzarini/Victor Lazzarini - Computer Music Instruments.pdf",
    outputName: "lazzarini_instruments.txt",
    type: "book",
  },
  {
    id: "bianchini-cipriani",
    name: "Virtual Sound — Bianchini & Cipriani",
    pdfPath: "_BOOK-Virtual Sound - Bianchini & Cipriani/VirtualSound.pdf",
    outputName: "bianchini_virtual_sound.txt",
    type: "book",
  },
  {
    id: "boulanger",
    name: "The Csound Book — Boulanger (PDF)",
    pdfPath: "_BOOK-The Csound Book - Boulanger/The Csound Book - Perspectives in Software Synthesis, Sound Design, Signal Processing, and Programming.pdf",
    outputName: "boulanger_csound_book.txt",
    type: "book",
  },
]

// Parse CLI args
const args = process.argv.slice(2)
const bookFilter = args.indexOf("--book")
const specificBook = bookFilter >= 0 ? args[bookFilter + 1] : null
const processAll = args.includes("--all") || !specificBook

async function extractPdf(pdfPath: string): Promise<string> {
  // Dynamic import to handle optional dependency
  let pdfParse: any
  try {
    pdfParse = (await import("pdf-parse")).default
  } catch {
    console.error("Error: pdf-parse not installed. Run: bun add -d pdf-parse")
    process.exit(1)
  }

  const buffer = await fs.readFile(pdfPath)
  const data = await pdfParse(buffer, {
    // Use default page rendering
    max: 0, // No page limit
  })

  return data.text as string
}

async function processBook(bookDef: (typeof BOOK_DEFS)[0]): Promise<void> {
  const pdfPath = path.join(BOOKS_DIR, bookDef.pdfPath)

  // Check if PDF exists
  try {
    await fs.access(pdfPath)
  } catch {
    console.log(`  SKIP: PDF not found at ${pdfPath}`)
    return
  }

  // Check if output already exists
  const outputPath = path.join(OUTPUT_DIR, bookDef.outputName)
  try {
    const stat = await fs.stat(outputPath)
    if (stat.size > 0) {
      console.log(`  EXISTS: ${bookDef.outputName} (${(stat.size / 1024).toFixed(0)} KB) — skip (use --force to rebuild)`)
      if (!args.includes("--force")) return
    }
  } catch {
    // Output doesn't exist, proceed
  }

  console.log(`  Extracting: ${bookDef.name}...`)
  const startTime = Date.now()

  try {
    const rawText = await extractPdf(pdfPath)
    console.log(`    Raw: ${rawText.length.toLocaleString()} chars, ${rawText.split("\n").length.toLocaleString()} lines`)

    // Clean the text
    const cleaned = cleanPdfText(rawText)
    console.log(`    Cleaned: ${cleaned.length.toLocaleString()} chars, ${cleaned.split("\n").length.toLocaleString()} lines`)

    // Detect sections
    const sections = detectSections(cleaned)
    console.log(`    Sections detected: ${sections.length}`)

    // Add header
    const header = [
      `# ${bookDef.name}`,
      `# Source: ${bookDef.pdfPath}`,
      `# Extracted: ${new Date().toISOString()}`,
      `# Type: ${bookDef.type}`,
      `# Sections: ${sections.length}`,
      "",
      "",
    ].join("\n")

    await fs.writeFile(outputPath, header + cleaned, "utf-8")

    const elapsed = ((Date.now() - startTime) / 1000).toFixed(1)
    const outputSize = (await fs.stat(outputPath)).size
    console.log(`    Output: ${bookDef.outputName} (${(outputSize / 1024).toFixed(0)} KB) in ${elapsed}s`)
  } catch (e) {
    console.error(`    ERROR: ${e}`)
  }
}

async function main() {
  console.log("=== DrC PDF Extraction ===\n")

  // Ensure output directory exists
  await fs.mkdir(OUTPUT_DIR, { recursive: true })

  const booksToProcess = processAll
    ? BOOK_DEFS
    : BOOK_DEFS.filter((b) => b.id === specificBook || b.name.toLowerCase().includes(specificBook?.toLowerCase() ?? ""))

  if (booksToProcess.length === 0) {
    console.error(`No books matching "${specificBook}" found.`)
    console.log("Available books:")
    for (const b of BOOK_DEFS) {
      console.log(`  ${b.id}: ${b.name}`)
    }
    process.exit(1)
  }

  console.log(`Processing ${booksToProcess.length} book(s):\n`)

  for (const book of booksToProcess) {
    console.log(`[${book.id}] ${book.name}`)
    await processBook(book)
    console.log()
  }

  // Print summary
  console.log("=== Summary ===")
  const outputFiles = await fs.readdir(OUTPUT_DIR)
  for (const file of outputFiles.sort()) {
    if (file.endsWith(".txt") || file.endsWith(".md")) {
      const stat = await fs.stat(path.join(OUTPUT_DIR, file))
      console.log(`  ${file}: ${(stat.size / 1024).toFixed(0)} KB`)
    }
  }
}

main().catch((e) => {
  console.error("Extraction failed:", e)
  process.exit(1)
})
