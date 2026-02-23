/**
 * Batched LLM enrichment for CSD metadata generation.
 *
 * Uses Claude Haiku for fast, cheap structured extraction:
 * - Sonic description (1-2 sentences)
 * - Primary technique classification
 * - Pedagogical value
 * - Signal flow chain
 * - Sonic character tags
 *
 * Processes CSDs in batches of 5-10 for efficiency.
 */

import type { CsdExample } from "../../src/retrieval/schema"

export interface EnrichmentInput {
  id: string
  filename: string
  source: string
  instrumentsSection: string // <CsInstruments> content
  opcodes: string[] // Already extracted opcodes
  ruleBasedTechnique: string // From technique-classifier
}

export interface EnrichmentOutput {
  id: string
  description: string
  primaryTechnique: string
  pedagogicalValue: string
  signalFlow: string
  sonicTags: string[]
}

const BATCH_SIZE = 5
const RATE_LIMIT_MS = 500

/**
 * Enrich a batch of CSD files with LLM-generated metadata.
 * Uses Anthropic API with Claude Haiku for speed and cost.
 */
export async function enrichBatch(
  inputs: EnrichmentInput[],
  apiKey: string,
): Promise<EnrichmentOutput[]> {
  const results: EnrichmentOutput[] = []

  for (let i = 0; i < inputs.length; i += BATCH_SIZE) {
    const batch = inputs.slice(i, i + BATCH_SIZE)
    const batchNum = Math.floor(i / BATCH_SIZE) + 1
    const totalBatches = Math.ceil(inputs.length / BATCH_SIZE)

    console.log(`  LLM enrichment batch ${batchNum}/${totalBatches} (${batch.length} CSDs)...`)

    try {
      const batchResults = await processBatch(batch, apiKey)
      results.push(...batchResults)
    } catch (e) {
      console.warn(`  Warning: Batch ${batchNum} failed: ${e}`)
      // Generate fallback results for failed batch
      for (const input of batch) {
        results.push(generateFallback(input))
      }
    }

    // Rate limit
    if (i + BATCH_SIZE < inputs.length) {
      await new Promise((r) => setTimeout(r, RATE_LIMIT_MS))
    }
  }

  return results
}

async function processBatch(
  batch: EnrichmentInput[],
  apiKey: string,
): Promise<EnrichmentOutput[]> {
  const csdDescriptions = batch
    .map((input, idx) => {
      // Truncate instruments section to ~800 chars for token efficiency
      const truncated = input.instrumentsSection.length > 800
        ? input.instrumentsSection.slice(0, 800) + "\n; ... (truncated)"
        : input.instrumentsSection
      return `--- CSD ${idx + 1}: ${input.filename} (source: ${input.source}) ---
Opcodes: ${input.opcodes.join(", ")}
Rule-based technique: ${input.ruleBasedTechnique}
<CsInstruments>
${truncated}
</CsInstruments>`
    })
    .join("\n\n")

  const prompt = `Analyze these Csound instrument definitions and provide structured metadata for each.

${csdDescriptions}

For each CSD, respond with a JSON array where each element has:
- "index": the CSD number (1-${batch.length})
- "description": 1-2 sentence description of the sonic character and what the instrument produces
- "primaryTechnique": the main synthesis/processing technique (e.g., "FM synthesis", "subtractive synthesis", "granular synthesis", "physical modeling", "spectral processing", "wavetable synthesis", "additive synthesis", "sample playback", "waveshaping", "reverb", "delay effects", "filter design", "noise synthesis")
- "pedagogicalValue": what concept this example best teaches (1 sentence)
- "signalFlow": human-readable signal chain (e.g., "FM oscillator -> lowpass filter -> reverb -> stereo out")
- "sonicTags": array of 3-5 adjective tags describing the sound (e.g., ["warm", "evolving", "pad-like", "resonant"])

Respond ONLY with the JSON array, no other text.`

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 2048,
      messages: [{ role: "user", content: prompt }],
    }),
  })

  if (!response.ok) {
    const err = await response.text()
    throw new Error(`Anthropic API error: ${response.status} ${err}`)
  }

  const data = (await response.json()) as {
    content: Array<{ type: string; text: string }>
  }

  const text = data.content.find((c) => c.type === "text")?.text ?? "[]"

  // Parse JSON from response (handle markdown code blocks)
  const jsonMatch = text.match(/\[[\s\S]*\]/)
  if (!jsonMatch) {
    throw new Error("No JSON array found in LLM response")
  }

  const parsed = JSON.parse(jsonMatch[0]) as Array<{
    index: number
    description: string
    primaryTechnique: string
    pedagogicalValue: string
    signalFlow: string
    sonicTags: string[]
  }>

  return batch.map((input, idx) => {
    const llmResult = parsed.find((p) => p.index === idx + 1)
    if (!llmResult) return generateFallback(input)

    return {
      id: input.id,
      description: llmResult.description || `${input.ruleBasedTechnique} instrument`,
      primaryTechnique: llmResult.primaryTechnique || input.ruleBasedTechnique,
      pedagogicalValue: llmResult.pedagogicalValue || `Demonstrates ${input.ruleBasedTechnique}`,
      signalFlow: llmResult.signalFlow || "signal -> output",
      sonicTags: Array.isArray(llmResult.sonicTags) ? llmResult.sonicTags : [],
    }
  })
}

/**
 * Generate fallback metadata when LLM enrichment fails.
 * Uses rule-based technique classification as the basis.
 */
function generateFallback(input: EnrichmentInput): EnrichmentOutput {
  return {
    id: input.id,
    description: `${input.ruleBasedTechnique} instrument using ${input.opcodes.slice(0, 3).join(", ")}`,
    primaryTechnique: input.ruleBasedTechnique,
    pedagogicalValue: `Demonstrates ${input.ruleBasedTechnique} techniques`,
    signalFlow: "signal -> output",
    sonicTags: [],
  }
}

/**
 * Estimate the cost of enriching N CSDs with Haiku.
 */
export function estimateCost(csdCount: number): { inputTokens: number; outputTokens: number; estimatedUSD: number } {
  const inputTokensPerCsd = 500
  const outputTokensPerCsd = 150
  const inputTokens = csdCount * inputTokensPerCsd
  const outputTokens = csdCount * outputTokensPerCsd
  // Haiku pricing: $1/M input, $5/M output (approximate)
  const estimatedUSD = (inputTokens / 1_000_000) * 1 + (outputTokens / 1_000_000) * 5
  return { inputTokens, outputTokens, estimatedUSD }
}
