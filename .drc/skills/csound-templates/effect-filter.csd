<CsoundSynthesizer>
<CsOptions>
-d -m0 -W
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

; ============================================================
; Multimode Filter with LFO Modulation Template
; Source → Filter (LP/HP/BP) with LFO → Output
; ============================================================

giSine ftgen 0, 0, 8192, 10, 1

; --- Source: rich sawtooth ---
instr Source
  iFreq = p4
  iAmp = p5
  kEnv madsr 0.01, 0.1, 0.8, 0.2

  ; Rich source signal
  aSaw1 vco2 0.5, iFreq
  aSaw2 vco2 0.5, iFreq * 2.001  ; octave up, slightly detuned
  aMix = (aSaw1 + aSaw2 * 0.3) * kEnv * iAmp

  chnset aMix, "filterIn"
endin

; --- Filter Effect ---
instr Filter
  ; <<< CUSTOMIZE: filter parameters
  kCutoffBase = 1500              ; base cutoff frequency (Hz)
  kResonance = 0.5                ; resonance (0-1, careful above 0.8)

  ; <<< CUSTOMIZE: LFO modulation
  kLfoRate = 0.3                  ; LFO speed (Hz) — 0.1=slow drift, 1-5=wobble, 5-20=fast
  kLfoDepth = 2000                ; LFO depth in Hz
  ; <<< CUSTOMIZE: LFO waveform — oscili for sine, lfo for multiple shapes
  kLfo oscili kLfoDepth, kLfoRate, giSine

  kCutoff = kCutoffBase + kLfo
  ; Clamp cutoff to safe range
  kCutoff limit kCutoff, 20, 18000

  aIn chnget "filterIn"

  ; <<< CUSTOMIZE: filter type — uncomment one:

  ; Low-pass (moogladder — warm, analog character)
  aFilt moogladder aIn, kCutoff, kResonance

  ; Low-pass (lpf18 — 303-style with distortion)
  ; aFilt lpf18 aIn, kCutoff, kResonance, 0.2

  ; Low-pass (zdf_2pole — clean, precise)
  ; aFilt zdf_2pole aIn, kCutoff, kResonance + 0.5, 0

  ; High-pass (zdf_2pole mode 1)
  ; aFilt zdf_2pole aIn, kCutoff, kResonance + 0.5, 1

  ; Band-pass (resonz)
  ; aFilt resonz aIn, kCutoff, kCutoff * 0.1

  aFilt limit aFilt, -1, 1
  outs aFilt, aFilt
endin

</CsInstruments>
<CsScore>
; Start filter effect for entire duration
i "Filter" 0 10

; Source notes
i "Source" 0    3   131   0.5
i "Source" 3    3   165   0.5
i "Source" 6    4   196   0.5
e 12
</CsScore>
</CsoundSynthesizer>
