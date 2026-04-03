import z from "zod"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { UserProfile } from "../retrieval/user-profile"
import { RetrievalEngine } from "../retrieval/engine"

const log = Log.create({ service: "tool.sketch-surprise" })

const DESCRIPTION = `"Surprise me" generator — suggests an unexplored Csound technique with a starter CSD template.

Use this when the user seems stuck, uninspired, or explicitly asks to be surprised. Queries the user profile to find techniques they have NOT explored much, then retrieves knowledge about underexplored techniques and returns a suggestion with a ready-to-use CSD template.

The goal is to push the user's creative boundaries by introducing techniques outside their comfort zone.`

// Technique pool with CSD templates for quick sketching
const TECHNIQUE_POOL: Record<string, { description: string; template: string }> = {
  "granular synthesis": {
    description: "Clouds of micro-sounds creating evolving textures. Pioneered by Iannis Xenakis and Curtis Roads.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

giSine ftgen 0, 0, 8192, 10, 1

instr 1
  kDens = 40
  kDur = 0.05
  kPitch = 1
  kPitchVar = 0.1

  aSigL grain 0.3, cpspch(8.00)*kPitch, kDens, 0, kPitchVar, kDur, giSine, giSine, 1
  aSigR grain 0.3, cpspch(8.00)*kPitch, kDens, 0, kPitchVar, kDur, giSine, giSine, 1

  kEnv = madsr(0.5, 0.1, 0.8, 0.5)
  out(aSigL * kEnv, aSigR * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "spectral processing": {
    description: "Manipulating sound in the frequency domain using FFT. Think frozen spectra, spectral blur, cross-synthesis.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  aSource = vco2(0.5, 220)
  iFftSize = 1024
  iOverlap = 256
  iWinSize = 1024
  iWinType = 1

  fSig pvsanal aSource, iFftSize, iOverlap, iWinSize, iWinType
  fBlur pvsmooth fSig, 0.95, 0.95
  aOut pvsynth fBlur

  kEnv = madsr(0.3, 0.1, 0.7, 0.5)
  out(aOut * kEnv, aOut * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "physical modeling": {
    description: "Simulating real-world vibrating systems — strings, tubes, membranes. From Karplus-Strong to waveguide synthesis.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  iFreq = cpspch(8.07)
  iPickup = 0.5
  iRefl = 0.95

  aPluck pluck 0.7, iFreq, iFreq, 0, 1
  aBody = moogladder(aPluck, 3000, 0.2)

  kEnv = linsegr(1, p3 - 0.1, 0.8, 0.3, 0)
  out(aBody * kEnv, aBody * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 0.5
i 1 0.6 0.5
i 1 1.2 0.8
i 1 2.2 1.0
</CsScore>
</CsoundSynthesizer>`,
  },
  "feedback networks": {
    description: "Self-modifying audio circuits where outputs feed back into inputs. Creates emergent, living textures.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  kFbAmt = 0.6
  aIn = noise(0.01, 0)

  aBuf init 0
  aMix = aIn + aBuf * kFbAmt

  aFilt = moogladder(aMix, 800 + rspline:k(100, 2000, 0.3, 2) , 0.7)
  aDel vdelay3 aFilt, 15 + rspline:k(-5, 5, 0.5, 3), 50
  aBuf = clip(aDel, 0, 0.9)

  kEnv = madsr(0.5, 0.2, 0.7, 1.0)
  out(aFilt * kEnv, aDel * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "waveshaping": {
    description: "Nonlinear distortion using transfer functions. From subtle warmth to extreme timbral transformation.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

giTransfer ftgen 0, 0, 8193, 7, -0.8, 2048, -0.8, 0, 0, 0, 0.8, 2048, 0.8, 4096, 0.8

instr 1
  kDrive line 0.1, p3, 0.9
  aSig = oscili(kDrive, 220)
  aShaped distort1 aSig, kDrive * 50, 0.5, 0, 0, 1

  aFilt = moogladder(aShaped, 2000 + lfo:k(1000, 0.5), 0.3)

  kEnv = madsr(0.2, 0.1, 0.6, 0.4)
  out(aFilt * kEnv * 0.5, aFilt * kEnv * 0.5)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "stochastic synthesis": {
    description: "Probability-driven sound generation. Random walks, Markov chains, noise-sculpting. Rooted in Xenakis's formalized music.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  kFreq = rspline(200, 800, 1, 5)
  kAmp = rspline(0.1, 0.5, 0.5, 3)
  kFilt = rspline(500, 4000, 0.3, 2)

  aSig = vco2(kAmp, kFreq)
  aSig2 = vco2(kAmp * 0.7, kFreq * 1.01)
  aMix = aSig + aSig2

  aFilt = statevar(aMix, kFilt, 0.6)

  kEnv = madsr(0.3, 0.1, 0.7, 0.5)
  aL = aFilt * kEnv
  aR = aFilt * kEnv
  out(aL, aR)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "AM synthesis": {
    description: "Amplitude modulation — ring modulation and tremolo taken to extremes. Sideband-rich metallic tones.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  iCarr = 440
  iMod = 173
  kModDepth line 0.3, p3, 1.0

  aCarrier = oscili(0.5, iCarr)
  aMod = oscili(kModDepth, iMod)
  aRing = aCarrier * (1 + aMod)

  aFilt = butterlp(aRing, 6000)

  kEnv = madsr(0.1, 0.2, 0.5, 0.4)
  out(aFilt * kEnv, aFilt * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "FM synthesis": {
    description: "Frequency modulation — John Chowning's revolution. Harmonically rich tones from simple oscillators.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  iCarr = 220
  iMod = 3.01
  kIndex line 1, p3, 8

  aSig foscili 0.5, iCarr, 1, iMod, kIndex
  aFilt = moogladder(aSig, 5000, 0.1)

  kEnv = madsr(0.05, 0.3, 0.4, 0.5)
  out(aFilt * kEnv, aFilt * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "additive synthesis": {
    description: "Building complex tones from individual partials. The most transparent synthesis method — direct harmonic control.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  iFund = 220
  aSum init 0

  kSpread line 1.0, p3, 1.02

  iPartial = 1
  while iPartial <= 8 do
    kAmp = 0.5 / iPartial
    kFreq = iFund * iPartial * kSpread
    aSum += oscili(kAmp, kFreq)
    iPartial += 1
  od

  aFilt = butterlp(aSum, 8000)
  kEnv = madsr(0.3, 0.2, 0.6, 0.5)
  out(aFilt * kEnv * 0.5, aFilt * kEnv * 0.5)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
  "noise sculpting": {
    description: "Starting from noise and carving sound with filters and envelopes. Subtractive at its most elemental.",
    template: `<CsoundSynthesizer>
<CsOptions>
-n -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

instr 1
  aNoise = noise(0.7, 0)
  kCutoff expseg 8000, p3 * 0.3, 200, p3 * 0.7, 100
  kRes line 0.3, p3, 0.85

  aFilt = moogladder(aNoise, kCutoff, kRes)
  aFilt2 = statevar(aFilt, kCutoff * 0.5, kRes * 0.5)

  kEnv = madsr(0.01, 0.2, 0.5, 0.3)
  out(aFilt * kEnv, aFilt2 * kEnv)
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
  },
}

export const SketchSurpriseTool = Tool.define(
  "sketch_surprise",
  {
    description: DESCRIPTION,
    parameters: z.object({
      avoid: z
        .array(z.string())
        .optional()
        .describe("Techniques to skip (e.g., already explored this session)"),
    }),
    async execute(params, ctx) {
      const { avoid = [] } = params

      log.info("surprise generation", { avoid, sessionID: ctx.sessionID })

      // Load user profile to find underexplored techniques
      const profile = await UserProfile.load()
      const usedTechniques = profile.preferredTechniques

      // Score each technique: lower usage = higher surprise value
      const candidates = Object.entries(TECHNIQUE_POOL)
        .filter(([name]) => !avoid.map((a) => a.toLowerCase()).includes(name.toLowerCase()))
        .map(([name, info]) => {
          const usage = usedTechniques[name] ?? 0
          // Invert usage: less used = higher score
          const surpriseScore = 1 / (1 + usage)
          return { name, ...info, usage, surpriseScore }
        })
        .sort((a, b) => b.surpriseScore - a.surpriseScore)

      if (candidates.length === 0) {
        return {
          title: "No surprises available",
          output: "All techniques have been explored or excluded. Try removing some from the avoid list.",
          metadata: { technique: undefined as string | undefined, usage: 0 },
        }
      }

      // Pick the top candidate (least explored)
      const pick = candidates[0]

      // Try to enrich with retrieval context
      let retrievalContext = ""
      try {
        const results = await RetrievalEngine.searchChunks(pick.name, {
          sessionID: ctx.sessionID,
          domain: "synthesis",
        })
        if (results.length > 0) {
          retrievalContext = `\n\nRelated knowledge:\n${results[0].content.slice(0, 300)}`
        }
      } catch {
        // Retrieval not available — proceed without it
      }

      return {
        title: `Surprise: ${pick.name}`,
        output: [
          `## Suggested technique: ${pick.name}`,
          ``,
          pick.description,
          ``,
          `Your usage history: ${pick.usage === 0 ? "never tried" : `used ${pick.usage} time(s)`}`,
          retrievalContext,
          ``,
          `Here's a starter CSD template:`,
          ``,
          "```csd",
          pick.template,
          "```",
          ``,
          `Write this to a new branch, render it, then iterate from there.`,
        ].join("\n"),
        metadata: {
          technique: pick.name,
          usage: pick.usage,
        },
      }
    },
  },
)
