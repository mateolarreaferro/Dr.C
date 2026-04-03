/**
 * Challenge registry for the educational layer.
 * Each challenge includes a compilable Csound 7 starter CSD.
 */

export interface Challenge {
  id: string
  title: string
  difficulty: "beginner" | "intermediate" | "advanced"
  description: string
  starterCsd: string
  hints: string[]
  evaluationCriteria: string[]
  relatedTechnique: string
  flossLink?: string
}

export const CHALLENGES: Challenge[] = [
  // =====================
  // BEGINNER (5)
  // =====================
  {
    id: "beginner-sine-tone",
    title: "Pure Sine Tone",
    difficulty: "beginner",
    description:
      "Create a simple sine wave oscillator that plays a 440 Hz tone for 3 seconds. This is the \"hello world\" of sound synthesis — every synthesizer begins with an oscillator. Your goal: produce a clean sine wave at concert A (440 Hz) with a smooth amplitude envelope to avoid clicks at the start and end.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  ; TODO: Create a sine oscillator at 440 Hz
  ; TODO: Add a simple envelope to avoid clicks
  ; TODO: Output to both channels
  aSig = 0
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 3
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Use the oscili opcode: aSig oscili iAmp, iFreq",
      "For a click-free envelope, try: kEnv linseg 0, 0.01, 1, p3-0.02, 1, 0.01, 0",
      "Multiply the oscillator output by the envelope: aSig = aSig * kEnv",
    ],
    evaluationCriteria: [
      "Uses oscili or poscil opcode",
      "Frequency is 440 Hz",
      "Has an amplitude envelope (linseg, madsr, or similar)",
      "Outputs to stereo with outs",
    ],
    relatedTechnique: "additive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  },
  {
    id: "beginner-envelope",
    title: "Simple ADSR Envelope",
    difficulty: "beginner",
    description:
      "Shape a tone with an Attack-Decay-Sustain-Release envelope. Raw oscillators sound static and lifeless — envelopes give sounds their dynamic character. Create a tone that swells in (attack), drops slightly (decay), holds steady (sustain), and fades out (release).",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = 330
  ; TODO: Create an ADSR envelope
  ; Attack: 0.1s, Decay: 0.2s, Sustain: 0.6, Release: 0.3s
  kEnv = 1

  aSig oscili kEnv * 0.5, iFreq
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 2
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Try madsr: kEnv madsr iAttack, iDecay, iSustain, iRelease",
      "The sustain parameter is a level (0-1), not a time. The note holds at this level until release.",
      "You can also use linsegr for more control: kEnv linsegr 0, 0.1, 1, 0.2, 0.6, 0.3, 0",
    ],
    evaluationCriteria: [
      "Uses madsr, adsr, linsegr, or similar envelope opcode",
      "Envelope has distinct attack, decay, sustain, and release phases",
      "Envelope is applied to the oscillator amplitude",
    ],
    relatedTechnique: "additive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/envelopes",
  },
  {
    id: "beginner-vibrato",
    title: "Vibrato Effect",
    difficulty: "beginner",
    description:
      "Add vibrato to a sustained tone. Vibrato is a periodic variation in pitch — typically 5-7 Hz with a depth of a few Hz. Violinists, singers, and wind players all use vibrato to add warmth and expressiveness. Implement vibrato by modulating the frequency of your main oscillator with a slow LFO.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = 440
  iVibratoRate = 6
  iVibratoDepth = 5
  ; TODO: Create an LFO for vibrato
  ; TODO: Add the LFO to the base frequency
  ; TODO: Use the modulated frequency in the oscillator

  aSig oscili 0.5, iFreq
  kEnv linseg 0, 0.05, 1, p3-0.1, 1, 0.05, 0
  outs aSig * kEnv, aSig * kEnv
endin
</CsInstruments>
<CsScore>
i 1 0 4
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Create an LFO: kVibrato oscili iVibratoDepth, iVibratoRate",
      "Add the LFO to the base frequency: kFreq = iFreq + kVibrato",
      "Use kFreq instead of iFreq in your main oscillator",
    ],
    evaluationCriteria: [
      "Has a low-frequency oscillator (oscili, lfo, or similar) for vibrato",
      "LFO rate is in the 4-8 Hz range",
      "LFO output modulates the frequency of the main oscillator",
    ],
    relatedTechnique: "additive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/modulation",
  },
  {
    id: "beginner-tremolo",
    title: "Tremolo Effect",
    difficulty: "beginner",
    description:
      "Add tremolo to a tone. While vibrato varies pitch, tremolo varies amplitude — a pulsating volume effect. Tremolo rates are typically 4-10 Hz. Create a tone with a smooth tremolo that makes it sound like it's gently breathing.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = 440
  iTremRate = 5
  iTremDepth = 0.3
  ; TODO: Create a tremolo LFO
  ; TODO: Apply tremolo to the amplitude

  aSig oscili 0.5, iFreq
  kEnv linseg 0, 0.05, 1, p3-0.1, 1, 0.05, 0
  outs aSig * kEnv, aSig * kEnv
endin
</CsInstruments>
<CsScore>
i 1 0 4
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Create a unipolar LFO for amplitude: kTrem oscili iTremDepth, iTremRate",
      "Make it unipolar (0 to depth instead of -depth to +depth): kAmp = 1 - (iTremDepth * 0.5) + kTrem * 0.5",
      "A simpler approach: kTrem lfo iTremDepth, iTremRate, 0 then kAmp = 1 - iTremDepth + kTrem",
    ],
    evaluationCriteria: [
      "Has a low-frequency oscillator for tremolo modulation",
      "Tremolo rate is in the 3-12 Hz range",
      "LFO modulates the amplitude (not frequency) of the sound",
    ],
    relatedTechnique: "additive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/modulation",
  },
  {
    id: "beginner-noise-filter",
    title: "White Noise Filter Sweep",
    difficulty: "beginner",
    description:
      "Create a white noise source and sweep a low-pass filter across it. This is the foundation of subtractive synthesis — start with a harmonically rich source (noise) and sculpt it with a filter. Automate the filter cutoff frequency from low to high over the duration of the note to create a classic \"sweep\" effect.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  ; TODO: Generate white noise
  ; TODO: Create a filter cutoff envelope that sweeps from low to high
  ; TODO: Apply a low-pass filter to the noise

  aNoise noise 0.5, 0
  aFilt = aNoise ; Replace with filtered signal
  kEnv linseg 0, 0.01, 1, p3-0.02, 1, 0.01, 0
  outs aFilt * kEnv, aFilt * kEnv
endin
</CsInstruments>
<CsScore>
i 1 0 4
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Use moogladder for a warm resonant filter: aFilt moogladder aNoise, kCutoff, kResonance",
      "Sweep the cutoff with an envelope: kCutoff expseg 200, p3, 8000",
      "Try adding some resonance (0.0 to 0.9) for a more dramatic sweep",
    ],
    evaluationCriteria: [
      "Generates white noise using noise, rand, or similar opcode",
      "Applies a low-pass filter (moogladder, butterlp, tone, or similar)",
      "Filter cutoff frequency changes over time (envelope or LFO)",
    ],
    relatedTechnique: "subtractive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  },

  // =====================
  // INTERMEDIATE (5)
  // =====================
  {
    id: "intermediate-fm-bell",
    title: "FM Bell (Risset Style)",
    difficulty: "intermediate",
    description:
      "Create an FM synthesis bell inspired by Jean-Claude Risset's classic computer music timbres. FM bells use inharmonic carrier-to-modulator ratios (like 1:1.4) and decaying modulation index to produce metallic, shimmering tones. The key insight: as the modulation index decays, the spectrum simplifies — mimicking how real bell partials decay at different rates.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = p4
  iAmp = p5
  ; TODO: Set carrier and modulator frequencies with inharmonic ratio
  ; TODO: Create a decaying modulation index envelope
  ; TODO: Use foscili for FM synthesis
  ; TODO: Add amplitude envelope with long decay

  aSig = 0
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 5 440 0.4
i 1 0.5 5 660 0.3
i 1 1.0 5 550 0.35
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Set carrier:modulator ratio for bell-like inharmonicity: iCar = 1, iMod = 1.4 (or try 1:2.76 for a different bell)",
      "Decaying mod index creates time-varying spectrum: kNdx expon 8, p3, 0.5",
      "Use foscili: aSig foscili iAmp, iFreq, iCar, iMod, kNdx",
      "Add a decaying amplitude envelope: kEnv expon 1, p3, 0.001",
    ],
    evaluationCriteria: [
      "Uses foscil, foscili, or fmbell opcode",
      "Has an inharmonic carrier-to-modulator frequency ratio",
      "Modulation index decays over time",
      "Amplitude envelope has a long decay characteristic of bells",
    ],
    relatedTechnique: "FM synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/frequency-modulation",
  },
  {
    id: "intermediate-subtractive-bass",
    title: "Subtractive Bass Synth",
    difficulty: "intermediate",
    description:
      "Build a classic subtractive bass synthesizer: a harmonically rich oscillator (sawtooth or pulse) shaped by a resonant low-pass filter with its own envelope. This is the architecture of every Moog, Prophet, and Juno bass patch. The filter envelope is key — a snappy filter attack with moderate decay gives the bass its punch and character.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = p4
  iAmp = p5
  ; TODO: Generate a sawtooth wave using vco2
  ; TODO: Create a filter envelope (fast attack, medium decay)
  ; TODO: Apply moogladder filter with resonance
  ; TODO: Add amplitude envelope

  aSig = 0
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 0.5 55 0.5
i 1 0.5 0.5 55 0.5
i 1 1.0 0.5 82.4 0.5
i 1 1.5 1.0 55 0.5
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Generate a sawtooth: aSaw vco2 iAmp, iFreq, 0",
      "Create a filter envelope: kFiltEnv madsr 0.01, 0.3, 0.2, 0.1 then kCutoff = 200 + (kFiltEnv * 4000)",
      "Apply the Moog filter: aFilt moogladder aSaw, kCutoff, 0.4",
      "Add amplitude envelope: kAmpEnv madsr 0.005, 0.1, 0.7, 0.05",
    ],
    evaluationCriteria: [
      "Uses vco2, sawtooth, or pulse wave as source",
      "Has a resonant low-pass filter (moogladder, lpf18, or similar)",
      "Filter cutoff has its own envelope (separate from amplitude)",
      "Has an amplitude envelope",
    ],
    relatedTechnique: "subtractive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/subtractive-synthesis",
  },
  {
    id: "intermediate-granular-cloud",
    title: "Granular Cloud Texture",
    difficulty: "intermediate",
    description:
      "Create a granular synthesis cloud — a texture built from hundreds of tiny overlapping grains of sound. Use a sine wave or simple waveform as the grain source. Control grain density, duration, and pitch randomization to create an evolving, cloud-like texture that hovers and shifts. This is the sound world of Xenakis and Curtis Roads.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 8192, 10, 1
giEnv  ftgen 0, 0, 8192, 20, 2 ; Hanning window for grain envelope

instr 1
  ; TODO: Set grain parameters (density, duration, pitch)
  ; TODO: Use grain or grain3 opcode to create granular texture
  ; TODO: Add some randomization for organic feel

  aSig = 0
  kEnv linseg 0, 0.5, 1, p3-1, 1, 0.5, 0
  outs aSig * kEnv, aSig * kEnv
endin
</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Use grain3 for synthesis grains: aSig grain3 kFreq, 0, kGrainFreq, 0, kGrainDur, giSine, giEnv, 0.1, iMaxOverlaps",
      "Try: kFreq = 440, kGrainFreq = 50 (grains per second), kGrainDur around 0.04 (40ms grains)",
      "Add pitch variation with random: kFreq = 440 + randi:k(50, 3) for subtle pitch wandering",
      "Experiment with grain density (kGrainFreq) between 10-200 for sparse to dense textures",
    ],
    evaluationCriteria: [
      "Uses grain, grain3, partikkel, fog, or similar granular opcode",
      "Has controllable grain density/rate",
      "Has controllable grain duration",
      "Produces an evolving texture (not static)",
    ],
    relatedTechnique: "granular synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/granular-synthesis",
  },
  {
    id: "intermediate-additive-harmonics",
    title: "Additive Harmonic Series",
    difficulty: "intermediate",
    description:
      "Build a complex tone by layering individual harmonic partials, each with its own amplitude and envelope. Start with 8-12 harmonics of a fundamental frequency. Give each partial a slightly different decay rate — higher partials should decay faster, mimicking natural acoustic behavior. This is the technique Risset used to analyze and resynthesize brass timbres at Bell Labs.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = p4
  iAmp = p5
  iNumPartials = 8
  ; TODO: Create a loop or sum of oscillators for each harmonic
  ; TODO: Each partial at frequency = iFreq * harmonic_number
  ; TODO: Higher partials should be quieter and decay faster
  ; TODO: Sum all partials together

  aSig = 0
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 4 220 0.3
i 1 2 4 330 0.25
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "You can sum oscillators directly without a loop: a1 oscili kAmp1, iFreq then a2 oscili kAmp2, iFreq*2, etc.",
      "Scale amplitude by 1/n for each partial n: iAmpN = iAmp / iN",
      "Give each partial its own decay: kEnvN expon 1, p3 * (1/iN), 0.001 — higher partials decay faster",
      "Sum all partials: aSig = a1 + a2 + a3 + ... (normalize the total amplitude)",
    ],
    evaluationCriteria: [
      "Has multiple oscili/poscil instances at harmonic frequencies",
      "At least 6 harmonics present",
      "Higher harmonics have lower amplitude",
      "Each partial has some kind of envelope or time variation",
    ],
    relatedTechnique: "additive synthesis",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/additive-synthesis",
  },
  {
    id: "intermediate-reverb-chain",
    title: "Simple Reverb Chain",
    difficulty: "intermediate",
    description:
      "Create a dry sound source and process it through a reverb effect using a send/return architecture. Use a separate instrument for the reverb processor and global audio variables to route signal from the source to the reverb. This is how professional mixing works — the reverb is shared across multiple sources via a send bus.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; TODO: Declare global audio variables for reverb send
; gaRevSendL init 0
; gaRevSendR init 0

instr 1 ; Sound source
  iFreq = p4
  aSig oscili 0.4, iFreq
  kEnv madsr 0.01, 0.1, 0.5, 0.2
  aSig = aSig * kEnv
  ; TODO: Send a portion of the signal to the reverb bus
  ; TODO: Output the dry signal
  outs aSig, aSig
endin

; TODO: Create instrument 99 for reverb processing
; It should read from global send variables, apply reverb, and output

</CsInstruments>
<CsScore>
i 1 0 1 440
i 1 0.5 1 550
i 1 1.0 1 660
i 1 1.5 1 880
; TODO: Start the reverb instrument for the entire duration
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Declare global sends: gaRevSendL init 0 / gaRevSendR init 0 before instruments",
      "In the source instrument, add to send: gaRevSendL += aSig * 0.3",
      "Create instr 99 that reads gaRevSendL/R, applies reverbsc, outputs, and clears the globals",
      "In instr 99: aRevL, aRevR reverbsc gaRevSendL, gaRevSendR, 0.85, 12000 then clear globals to 0",
    ],
    evaluationCriteria: [
      "Uses global audio variables (ga-prefix) for reverb send",
      "Has a separate reverb instrument (send/return architecture)",
      "Uses reverbsc, freeverb, or similar reverb opcode",
      "Global send variables are cleared after processing to prevent feedback buildup",
    ],
    relatedTechnique: "reverb",
    flossLink: "https://flossmanual.csound.com/sound-modification/reverberation",
  },

  // =====================
  // ADVANCED (5)
  // =====================
  {
    id: "advanced-physical-string",
    title: "Physical Model String",
    difficulty: "advanced",
    description:
      "Create a realistic plucked string using physical modeling. Go beyond the basic pluck opcode — use waveguide synthesis (wgbow or repluck) or build a Karplus-Strong model from delay lines and filtering. Add body resonance and sympathetic string vibration for realism. The goal is a string that responds dynamically to excitation strength.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = p4
  iAmp = p5
  ; TODO: Create a plucked string using physical modeling
  ; TODO: Consider excitation signal (noise burst or impulse)
  ; TODO: Add body resonance filtering
  ; TODO: Implement amplitude-dependent brightness

  aSig = 0
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 2 220 0.7
i 1 0.3 2 330 0.5
i 1 0.6 2 440 0.6
i 1 1.0 3 110 0.8
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Try repluck for a waveguide string: aSig repluck iPick, iAmp, iFreq, iPick, iReflect",
      "For manual Karplus-Strong: excite a delay line (delayr/delayw) of length 1/iFreq with filtered noise, apply tone filter in feedback",
      "Add body resonance: aBody reson aSig, 200, 50, 1 then mix: aSig = aSig + aBody * 0.2",
      "Brightness from amplitude: iFiltFreq = 2000 + (iAmp * 8000) — louder plucks are brighter",
    ],
    evaluationCriteria: [
      "Uses pluck, repluck, wgbow, or custom delay-line Karplus-Strong",
      "Has excitation control (amplitude affects timbre or brightness)",
      "Includes some form of body resonance or secondary filtering",
      "Produces different timbres for different excitation strengths",
    ],
    relatedTechnique: "physical modeling",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  },
  {
    id: "advanced-spectral-freeze",
    title: "Spectral Freeze Effect",
    difficulty: "advanced",
    description:
      "Implement a spectral freeze effect using the phase vocoder opcodes (pvs family). Analyze an input signal into its spectral representation, then freeze the spectrum at a specific moment — holding the frequency content static while the world moves on. Add controls for freeze point, spectral blur, and cross-fade. This is the technique behind the \"frozen sound\" textures used by composers at IRCAM.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  ; Source signal — a rich evolving tone to freeze
  kFreq expseg 200, p3, 800
  aSrc vco2 0.4, kFreq
  aSrc = aSrc + oscili:a(0.2, kFreq * 1.5)

  ; TODO: Analyze source into spectral domain with pvsanal
  ; TODO: Apply pvsfreeze at a controllable moment
  ; TODO: Resynthesize with pvsynth
  ; TODO: Cross-fade between live and frozen signal

  aSig = aSrc
  kEnv linseg 0, 0.05, 1, p3-0.1, 1, 0.05, 0
  outs aSig * kEnv, aSig * kEnv
endin
</CsInstruments>
<CsScore>
i 1 0 10
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Analyze: fSrc pvsanal aSrc, 1024, 256, 1024, 1",
      "Freeze control: kFreeze = (timeinsts:k() > 3 ? 1 : 0) — freeze after 3 seconds",
      "Apply freeze: fFrozen pvsfreeze fSrc, kFreeze, kFreeze",
      "Resynthesize: aFrozen pvsynth fFrozen. Try adding pvsmooth before pvsynth for spectral blur.",
    ],
    evaluationCriteria: [
      "Uses pvsanal for spectral analysis",
      "Uses pvsfreeze for spectral freezing",
      "Uses pvsynth for resynthesis",
      "Has a controllable freeze trigger or time point",
    ],
    relatedTechnique: "spectral processing",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  },
  {
    id: "advanced-karplus-drum",
    title: "Karplus-Strong Drum",
    difficulty: "advanced",
    description:
      "Build a drum synthesizer using the Karplus-Strong algorithm. While the original algorithm simulates plucked strings, a modification by Jaffe and Smith (1983) produces convincing drum sounds by mixing the delay line's feedback signal with its inverted version probabilistically. The \"blend factor\" controls whether the result sounds like a string (blend=1) or a drum (blend=0.5). Build this from raw delay line primitives.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iFreq = p4
  iAmp = p5
  iBlend = p6 ; 0.5 = drum, 1.0 = string
  iDelTime = 1 / iFreq
  ; TODO: Create a noise burst excitation (very short, ~2ms)
  ; TODO: Set up a delay line of length 1/iFreq
  ; TODO: In the feedback path, apply averaging filter
  ; TODO: Apply the blend factor (probabilistic sign flip)
  ; TODO: Feed the result back into the delay line

  aSig = 0
  outs aSig * iAmp, aSig * iAmp
endin
</CsInstruments>
<CsScore>
; Drum sounds (blend = 0.5)
i 1 0 1 80 0.7 0.5
i 1 0.5 1 120 0.6 0.5
i 1 1.0 1 60 0.8 0.5
; String-like (blend = 1.0)
i 1 2.0 2 220 0.5 1.0
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Noise burst: aBurst noise iAmp, 0 then gate it: aBurst = aBurst * (timeinsts:k() < 0.002 ? 1 : 0)",
      "Set up delay: aDel delayr iDelTime + 0.001 then aRead deltapi iDelTime",
      "Averaging filter: aFilt = (aRead + aReadPrev) * 0.5 where aReadPrev is the previous sample (use delay1)",
      "Blend: randomly flip sign with iBlend probability. For simplicity, use pluck opcode with iMeth=1 for drum mode.",
    ],
    evaluationCriteria: [
      "Implements Karplus-Strong using delay primitives (delayr/delayw) or pluck opcode",
      "Has a short noise burst as excitation",
      "Includes a blend/drum parameter that affects the timbre",
      "Produces distinctly different timbres for drum vs string settings",
    ],
    relatedTechnique: "physical modeling",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/physical-modelling",
  },
  {
    id: "advanced-stochastic-melody",
    title: "Stochastic Melody Generator",
    difficulty: "advanced",
    description:
      "Create a self-generating melodic instrument using stochastic processes, inspired by Xenakis. Use probability distributions to determine pitch, rhythm, and dynamics. Implement a weighted random walk on a pitch set (e.g., pentatonic scale) where each note's probability depends on the previous note. Use metro for timing and schedkwhen or event for note triggering.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; Pentatonic scale frequencies (C, D, E, G, A across 2 octaves)
giScale ftgen 0, 0, -10, -2, 261.6, 293.7, 329.6, 392.0, 440.0, 523.3, 587.3, 659.3, 784.0, 880.0

instr 1 ; Melody generator
  ; TODO: Use metro for rhythmic trigger
  ; TODO: Select pitch stochastically from giScale
  ; TODO: Use event or schedkwhen to trigger note instrument
  ; TODO: Vary density and register over time
endin

instr 2 ; Note instrument
  iFreq = p4
  iAmp = p5
  ; TODO: Create a musical tone with envelope
  aSig oscili iAmp, iFreq
  kEnv expon 1, p3, 0.01
  aSig = aSig * kEnv
  outs aSig, aSig
endin
</CsInstruments>
<CsScore>
i 1 0 20
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Use metro with varying rate: kTrig metro kDensity where kDensity jitters between 2-8 Hz",
      "Select from table: kNdx = int(random:k(0, 10)) then kFreq table kNdx, giScale",
      "Trigger notes: schedkwhen kTrig, 0, 5, 2, 0, kDur, kFreq, kAmp",
      "Add weighted walk: bias kNdx toward neighbors of previous note using port or conditional logic",
    ],
    evaluationCriteria: [
      "Uses metro or similar for rhythmic triggering",
      "Pitch selection involves randomness (random, randi, etc.)",
      "Uses event, schedkwhen, or scoreline_i to trigger note events",
      "Produces an evolving, non-repeating melodic pattern",
    ],
    relatedTechnique: "stochastic synthesis",
    flossLink: "https://flossmanual.csound.com/csound-language/control-structures",
  },
  {
    id: "advanced-pvs-timestretch",
    title: "Phase Vocoder Time Stretch",
    difficulty: "advanced",
    description:
      "Implement time-stretching of an audio signal using the phase vocoder. Read a sound file, analyze it spectrally, and resynthesize it at a different time scale without changing pitch. This is the technique that enables slow-motion audio — stretching a 1-second sound to 10 seconds while preserving its spectral character. Add controls for stretch factor and spectral smoothing.",
    starterCsd: `<CsoundSynthesizer>
<CsOptions>
-o dac -d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  ; First, create a source sound in a table
  ; (In practice you'd use diskin2, but we'll generate one)
  iDur = 1
  iStretch = p4 ; stretch factor (2.0 = twice as slow)

  ; TODO: Generate or load a source signal
  ; TODO: Analyze with pvsanal
  ; TODO: Use pvsbufread or mincer for time-stretching
  ; TODO: Control read pointer speed for stretch factor
  ; TODO: Resynthesize with pvsynth

  aSig = 0
  kEnv linseg 0, 0.05, 1, p3-0.1, 1, 0.05, 0
  outs aSig * kEnv, aSig * kEnv
endin
</CsInstruments>
<CsScore>
i 1 0 10 4.0 ; 4x time stretch
</CsScore>
</CsoundSynthesizer>`,
    hints: [
      "Use mincer for pitch-preserving time stretch: aSig mincer aTimePtr, iAmp, iPitch, giSndTable, 0, 2048",
      "Control time pointer: aTimePtr phasor (1 / (iOrigDur * iStretch)) then scale to table length",
      "Alternative: use sndwarp for granular time stretch: aSig sndwarp iAmp, kTimeScale, kPitch, giTable, ...",
      "For pure pvs approach: analyze with pvsanal, write to buffer with pvsbuffer, read with pvsbufread at scaled rate",
    ],
    evaluationCriteria: [
      "Uses phase vocoder (pvsanal/pvsynth) or mincer/sndwarp for time stretching",
      "Has a controllable stretch factor",
      "Pitch is preserved during time stretching",
      "Output is longer than the original signal duration",
    ],
    relatedTechnique: "spectral processing",
    flossLink: "https://flossmanual.csound.com/sound-synthesis/spectral-processing",
  },
]
