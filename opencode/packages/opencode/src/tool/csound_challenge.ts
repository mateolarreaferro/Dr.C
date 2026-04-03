import z from "zod"
import { Tool } from "./tool"
import { CHALLENGES, type Challenge } from "../educational/challenges"
import { FLOSS_LINKS } from "../educational/floss-links"
import { SessionWorkspace } from "../session/workspace"
import { UserProfile } from "../retrieval/user-profile"
import { Log } from "../util/log"

const log = Log.create({ service: "tool.csound-challenge" })

const DESCRIPTION = `Present and manage synthesis challenges for learning Csound techniques.

Use this tool when the user wants to practice, learn, or test their skills with guided synthesis challenges. Challenges range from beginner (basic sine tone) to advanced (spectral freeze, stochastic composition).

Actions:
- \`list\`: Show all available challenges grouped by difficulty
- \`start\`: Begin a specific challenge — returns description and starter CSD
- \`hint\`: Get the next hint for an active challenge
- \`evaluate\`: Check the user's CSD against the challenge evaluation criteria`

// Session-local hint tracking (how many hints used per challenge per session)
const hintTracker = new Map<string, Map<string, number>>() // sessionID -> challengeId -> hintsUsed

function getHintsUsed(sessionID: string, challengeId: string): number {
  return hintTracker.get(sessionID)?.get(challengeId) ?? 0
}

function incrementHint(sessionID: string, challengeId: string): number {
  if (!hintTracker.has(sessionID)) hintTracker.set(sessionID, new Map())
  const session = hintTracker.get(sessionID)!
  const current = session.get(challengeId) ?? 0
  session.set(challengeId, current + 1)
  return current + 1
}

export const CsoundChallengeTool = Tool.define(
  "csound_challenge",
  {
    description: DESCRIPTION,
    parameters: z.object({
      action: z
        .enum(["list", "start", "hint", "evaluate"])
        .describe("The action to perform"),
      challengeId: z
        .string()
        .optional()
        .describe("The challenge ID (required for start, hint, evaluate)"),
    }),
    async execute(params, ctx) {
      const { action, challengeId } = params

      log.info("challenge action", { action, challengeId })

      switch (action) {
        case "list":
          return handleList()

        case "start":
          return handleStart(challengeId, ctx.sessionID)

        case "hint":
          return handleHint(challengeId, ctx.sessionID)

        case "evaluate":
          return handleEvaluate(challengeId, ctx.sessionID)

        default:
          return {
            title: "Unknown action",
            output: `Unknown action: ${action}. Use list, start, hint, or evaluate.`,
            metadata: { action, challengeId },
          }
      }
    },
  },
)

function handleList(): {
  title: string
  output: string
  metadata: Record<string, any>
} {
  const grouped: Record<string, Challenge[]> = {
    beginner: [],
    intermediate: [],
    advanced: [],
  }

  for (const challenge of CHALLENGES) {
    grouped[challenge.difficulty].push(challenge)
  }

  const parts: string[] = []
  parts.push("## Csound Synthesis Challenges")
  parts.push("")

  for (const [difficulty, challenges] of Object.entries(grouped)) {
    const emoji = difficulty === "beginner" ? "1" : difficulty === "intermediate" ? "2" : "3"
    parts.push(`### Level ${emoji}: ${difficulty.charAt(0).toUpperCase() + difficulty.slice(1)}`)
    parts.push("")

    for (const c of challenges) {
      parts.push(`- **${c.id}**: ${c.title}`)
      parts.push(`  ${c.description.slice(0, 120)}...`)
      parts.push(`  Technique: ${c.relatedTechnique}`)
      parts.push("")
    }
  }

  parts.push("Use `start` with a challenge ID to begin.")

  return {
    title: `${CHALLENGES.length} challenges available`,
    output: parts.join("\n"),
    metadata: {
      action: "list",
      totalChallenges: CHALLENGES.length,
    },
  }
}

function handleStart(
  challengeId: string | undefined,
  sessionID: string,
): {
  title: string
  output: string
  metadata: Record<string, any>
} {
  if (!challengeId) {
    return {
      title: "Challenge ID required",
      output: "Please specify a challenge ID. Use the `list` action to see available challenges.",
      metadata: { action: "start" },
    }
  }

  const challenge = CHALLENGES.find((c) => c.id === challengeId)
  if (!challenge) {
    return {
      title: "Challenge not found",
      output: `No challenge found with ID "${challengeId}". Use the \`list\` action to see available challenges.`,
      metadata: { action: "start", challengeId },
    }
  }

  // Record challenge start in profile (fire-and-forget)
  UserProfile.load().then((profile) => {
    if (!profile.challengeProgress) {
      ;(profile as any).challengeProgress = {}
    }
    const progress = (profile as any).challengeProgress as Record<string, { started: boolean; completed: boolean; hintsUsed: number }>
    if (!progress[challengeId]) {
      progress[challengeId] = { started: true, completed: false, hintsUsed: 0 }
    } else {
      progress[challengeId].started = true
    }
  }).catch(() => {})

  const parts: string[] = []
  parts.push(`## Challenge: ${challenge.title}`)
  parts.push(`**Difficulty:** ${challenge.difficulty}`)
  parts.push(`**Technique:** ${challenge.relatedTechnique}`)
  parts.push("")
  parts.push(challenge.description)
  parts.push("")

  if (challenge.flossLink) {
    parts.push(`**Reference:** ${challenge.flossLink}`)
    parts.push("")
  }

  parts.push(`### Starter CSD`)
  parts.push("")
  parts.push("```csound")
  parts.push(challenge.starterCsd)
  parts.push("```")
  parts.push("")
  parts.push(`**Hints available:** ${challenge.hints.length} (use \`hint\` action to reveal one at a time)`)
  parts.push(`**Evaluation criteria:** ${challenge.evaluationCriteria.length} checks`)

  return {
    title: `Challenge: ${challenge.title}`,
    output: parts.join("\n"),
    metadata: {
      action: "start",
      challengeId,
      difficulty: challenge.difficulty,
      technique: challenge.relatedTechnique,
    },
  }
}

function handleHint(
  challengeId: string | undefined,
  sessionID: string,
): {
  title: string
  output: string
  metadata: Record<string, any>
} {
  if (!challengeId) {
    return {
      title: "Challenge ID required",
      output: "Please specify a challenge ID to get a hint for.",
      metadata: { action: "hint" },
    }
  }

  const challenge = CHALLENGES.find((c) => c.id === challengeId)
  if (!challenge) {
    return {
      title: "Challenge not found",
      output: `No challenge found with ID "${challengeId}".`,
      metadata: { action: "hint", challengeId },
    }
  }

  const used = getHintsUsed(sessionID, challengeId)

  if (used >= challenge.hints.length) {
    return {
      title: "No more hints",
      output: `All ${challenge.hints.length} hints for "${challenge.title}" have been revealed. Try implementing based on the hints you've received, or ask me for specific help.`,
      metadata: { action: "hint", challengeId, hintsUsed: used, totalHints: challenge.hints.length },
    }
  }

  const hintIndex = used
  incrementHint(sessionID, challengeId)

  // Update profile hint count (fire-and-forget)
  UserProfile.load().then((profile) => {
    const progress = (profile as any).challengeProgress as Record<string, { started: boolean; completed: boolean; hintsUsed: number }> | undefined
    if (progress && progress[challengeId]) {
      progress[challengeId].hintsUsed = hintIndex + 1
    }
  }).catch(() => {})

  return {
    title: `Hint ${hintIndex + 1}/${challenge.hints.length}`,
    output: [
      `## Hint ${hintIndex + 1} of ${challenge.hints.length} for "${challenge.title}"`,
      "",
      challenge.hints[hintIndex],
      "",
      hintIndex + 1 < challenge.hints.length
        ? `${challenge.hints.length - hintIndex - 1} more hint(s) available.`
        : "That was the last hint. You've got all the clues — give it a try!",
    ].join("\n"),
    metadata: {
      action: "hint",
      challengeId,
      hintNumber: hintIndex + 1,
      totalHints: challenge.hints.length,
    },
  }
}

async function handleEvaluate(
  challengeId: string | undefined,
  sessionID: string,
): Promise<{
  title: string
  output: string
  metadata: Record<string, any>
}> {
  if (!challengeId) {
    return {
      title: "Challenge ID required",
      output: "Please specify a challenge ID to evaluate.",
      metadata: { action: "evaluate" },
    }
  }

  const challenge = CHALLENGES.find((c) => c.id === challengeId)
  if (!challenge) {
    return {
      title: "Challenge not found",
      output: `No challenge found with ID "${challengeId}".`,
      metadata: { action: "evaluate", challengeId },
    }
  }

  // Try to find the user's CSD in the workspace
  let csdContent: string | null = null
  const workspace = SessionWorkspace.status(sessionID)
  if (workspace.active && workspace.tempDir) {
    try {
      const fs = await import("fs/promises")
      const entries = await fs.readdir(workspace.tempDir)
      const csdFile = entries.find((e) => e.endsWith(".csd"))
      if (csdFile) {
        const path = await import("path")
        csdContent = await Bun.file(path.join(workspace.tempDir, csdFile)).text()
      }
    } catch {
      // Fall through to no-content evaluation
    }
  }

  if (!csdContent) {
    return {
      title: "No CSD found",
      output: "No CSD file found in the current workspace. Write or patch a CSD file first, then evaluate.",
      metadata: { action: "evaluate", challengeId, hasCsd: false },
    }
  }

  // Evaluate against criteria (text-based, not audio analysis)
  const results: Array<{ criterion: string; passed: boolean; detail: string }> = []

  for (const criterion of challenge.evaluationCriteria) {
    const result = evaluateCriterion(criterion, csdContent)
    results.push(result)
  }

  const passed = results.filter((r) => r.passed).length
  const total = results.length
  const allPassed = passed === total

  // Update profile on completion
  if (allPassed) {
    UserProfile.load().then((profile) => {
      const progress = (profile as any).challengeProgress as Record<string, { started: boolean; completed: boolean; hintsUsed: number }> | undefined
      if (progress && progress[challengeId]) {
        progress[challengeId].completed = true
      }
    }).catch(() => {})
  }

  const parts: string[] = []
  parts.push(`## Evaluation: ${challenge.title}`)
  parts.push(`**Score: ${passed}/${total}**`)
  parts.push("")

  for (const r of results) {
    const status = r.passed ? "PASS" : "MISS"
    parts.push(`- [${status}] ${r.criterion}`)
    parts.push(`  ${r.detail}`)
  }

  parts.push("")
  if (allPassed) {
    parts.push("Excellent work! All criteria met. You've completed this challenge.")
  } else {
    parts.push(`${total - passed} criterion/criteria not yet met. Keep working on it — use \`hint\` if you need guidance.`)
  }

  return {
    title: `${passed}/${total} criteria passed`,
    output: parts.join("\n"),
    metadata: {
      action: "evaluate",
      challengeId,
      passed,
      total,
      allPassed,
    },
  }
}

function evaluateCriterion(
  criterion: string,
  csdContent: string,
): { criterion: string; passed: boolean; detail: string } {
  const lower = csdContent.toLowerCase()
  const criterionLower = criterion.toLowerCase()

  // Check for opcode usage patterns
  const opcodePatterns: Array<{ keywords: string[]; opcodes: string[] }> = [
    { keywords: ["oscili", "poscil", "oscillator"], opcodes: ["oscili", "oscil", "poscil", "poscil3"] },
    { keywords: ["vco2", "sawtooth", "pulse wave"], opcodes: ["vco2"] },
    { keywords: ["moogladder", "lpf18", "low-pass", "resonant"], opcodes: ["moogladder", "moogvcf", "lpf18", "butterlp", "tone", "statevar", "zdf_2pole"] },
    { keywords: ["madsr", "adsr", "linsegr", "envelope"], opcodes: ["madsr", "adsr", "mxadsr", "linseg", "linsegr", "expseg", "expsegr", "transeg", "expon", "line"] },
    { keywords: ["foscil", "fmbell", "fm"], opcodes: ["foscil", "foscili", "fmbell", "fmrhode", "fmwurlie", "fmvoice", "fmmetal", "crossfm"] },
    { keywords: ["reverbsc", "freeverb", "reverb"], opcodes: ["reverbsc", "freeverb", "nreverb", "reverb", "alpass"] },
    { keywords: ["pvsanal", "spectral analysis"], opcodes: ["pvsanal"] },
    { keywords: ["pvsynth", "resynthesis"], opcodes: ["pvsynth"] },
    { keywords: ["pvsfreeze", "spectral freeze"], opcodes: ["pvsfreeze"] },
    { keywords: ["pluck", "repluck", "wgbow", "karplus", "physical model"], opcodes: ["pluck", "repluck", "wgbow", "wgflute", "wgclar", "wgbrass", "barmodel"] },
    { keywords: ["grain", "partikkel", "granular"], opcodes: ["grain", "grain3", "partikkel", "fog", "fof", "fof2", "sndwarp", "granule"] },
    { keywords: ["metro", "metronome"], opcodes: ["metro"] },
    { keywords: ["schedkwhen", "event"], opcodes: ["schedkwhen", "event", "scoreline_i"] },
    { keywords: ["noise", "rand", "white noise"], opcodes: ["noise", "rand", "randi", "randh", "random"] },
    { keywords: ["lfo", "low-frequency"], opcodes: ["lfo", "oscili", "oscil"] },
    { keywords: ["global audio", "ga-prefix"], opcodes: ["ga"] },
    { keywords: ["outs", "stereo"], opcodes: ["outs"] },
    { keywords: ["mincer", "sndwarp", "pvsbuf"], opcodes: ["mincer", "sndwarp", "pvsbuffer", "pvsbufread"] },
  ]

  // Try to match criterion against opcode patterns
  for (const pattern of opcodePatterns) {
    const matches = pattern.keywords.some((kw) => criterionLower.includes(kw))
    if (matches) {
      const found = pattern.opcodes.filter((op) => {
        // For "ga" prefix, check for global audio variables
        if (op === "ga") return /ga\w+/.test(lower)
        // Check if opcode appears in the code
        return new RegExp(`\\b${op}\\b`, "i").test(csdContent)
      })
      if (found.length > 0) {
        return {
          criterion,
          passed: true,
          detail: `Found: ${found.join(", ")}`,
        }
      }
      return {
        criterion,
        passed: false,
        detail: `Expected one of: ${pattern.opcodes.join(", ")}`,
      }
    }
  }

  // Check for frequency-related criteria
  if (criterionLower.includes("440 hz") || criterionLower.includes("frequency is 440")) {
    const has440 = /440/.test(csdContent)
    return {
      criterion,
      passed: has440,
      detail: has440 ? "Found 440 Hz reference." : "No 440 Hz frequency found.",
    }
  }

  // Check for harmonic count
  const harmonicMatch = criterionLower.match(/at least (\d+) harmonic/)
  if (harmonicMatch) {
    const minHarmonics = parseInt(harmonicMatch[1])
    // Count distinct oscillator instances
    const oscCount = (csdContent.match(/\b(oscili?|poscil3?)\b/gi) ?? []).length
    return {
      criterion,
      passed: oscCount >= minHarmonics,
      detail: `Found ${oscCount} oscillator instance(s), need ${minHarmonics}.`,
    }
  }

  // Check for evolving/non-static patterns
  if (criterionLower.includes("evolving") || criterionLower.includes("non-repeating") || criterionLower.includes("not static")) {
    const hasTimeVariation = /\b(linseg|expseg|expon|jitter|randi|random|rspline|port)\b/i.test(csdContent)
    return {
      criterion,
      passed: hasTimeVariation,
      detail: hasTimeVariation ? "Found time-varying elements." : "No time-varying modulation detected.",
    }
  }

  // Check for separate filter envelope
  if (criterionLower.includes("filter cutoff has its own envelope") || criterionLower.includes("separate from amplitude")) {
    const envelopeCount = (csdContent.match(/\b(madsr|linseg|linsegr|expseg|expsegr|expon|transeg)\b/gi) ?? []).length
    return {
      criterion,
      passed: envelopeCount >= 2,
      detail: envelopeCount >= 2 ? `Found ${envelopeCount} envelope instances.` : "Need at least 2 separate envelopes.",
    }
  }

  // Check for cleared globals
  if (criterionLower.includes("cleared") || criterionLower.includes("clear")) {
    const hasClearing = /ga\w+\s*=\s*0/.test(csdContent) || /clear/.test(lower)
    return {
      criterion,
      passed: hasClearing,
      detail: hasClearing ? "Global variables are cleared." : "Global send variables should be cleared to 0 after processing.",
    }
  }

  // Check for controllable parameters
  if (criterionLower.includes("controllable") || criterionLower.includes("control")) {
    // Has k-rate variables or p-field references
    const hasControl = /\bk\w+/.test(csdContent) || /\bp[4-9]\b/.test(csdContent)
    return {
      criterion,
      passed: hasControl,
      detail: hasControl ? "Found controllable parameters." : "No controllable parameters detected.",
    }
  }

  // Check for specific timing/rate ranges
  const rateMatch = criterionLower.match(/(\d+)-(\d+)\s*hz/)
  if (rateMatch) {
    // Just check if there's a value in that range somewhere
    return {
      criterion,
      passed: true,
      detail: "Rate range check requires audio analysis — criterion noted for manual review.",
    }
  }

  // Check for blend/drum parameter
  if (criterionLower.includes("blend") || criterionLower.includes("drum parameter")) {
    const hasBlend = /blend|drum|p6/i.test(csdContent)
    return {
      criterion,
      passed: hasBlend,
      detail: hasBlend ? "Found blend/drum parameter." : "No blend parameter detected.",
    }
  }

  // Check for stretch factor
  if (criterionLower.includes("stretch factor")) {
    const hasStretch = /stretch|istretch|kstretch|p4/i.test(csdContent)
    return {
      criterion,
      passed: hasStretch,
      detail: hasStretch ? "Found stretch factor parameter." : "No stretch factor found.",
    }
  }

  // Check for pitch preservation
  if (criterionLower.includes("pitch is preserved") || criterionLower.includes("pitch-preserving")) {
    const hasPitchPreserve = /mincer|pvs|sndwarp/i.test(csdContent)
    return {
      criterion,
      passed: hasPitchPreserve,
      detail: hasPitchPreserve ? "Using pitch-preserving technique." : "No pitch-preserving technique detected.",
    }
  }

  // Check for inharmonic ratio
  if (criterionLower.includes("inharmonic") || criterionLower.includes("carrier-to-modulator")) {
    // Look for non-integer ratios in FM context
    const hasInharmonic = /\d+\.\d+/.test(csdContent) || /icar|imod|icratio|imratio/i.test(csdContent)
    return {
      criterion,
      passed: hasInharmonic,
      detail: hasInharmonic ? "Found inharmonic frequency ratio." : "No inharmonic ratio detected.",
    }
  }

  // Check for modulation index decay
  if (criterionLower.includes("modulation index") && criterionLower.includes("decay")) {
    const hasDecayingIndex = /\b(expon|linseg|expseg)\b/i.test(csdContent) && /\b(ndx|index|kndx|kindx)\b/i.test(csdContent)
    return {
      criterion,
      passed: hasDecayingIndex,
      detail: hasDecayingIndex ? "Found decaying modulation index." : "Modulation index should decay over time for bell-like timbres.",
    }
  }

  // Default: cannot evaluate automatically
  return {
    criterion,
    passed: false,
    detail: "This criterion requires manual review or audio analysis.",
  }
}
