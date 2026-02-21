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
; Granular Synthesis Template
; Generates texture from a waveform table using grain3
; ============================================================

; Source waveform — using a rich waveform as grain source
; <<< CUSTOMIZE: replace with file-loaded table for sample-based granular:
;   giSource ftgen 0, 0, 0, 1, "sample.wav", 0, 0, 0
giSource ftgen 0, 0, 8192, 10, 1, 0.5, 0.3, 0.2, 0.15, 0.1, 0.08, 0.05

; Window function for grain envelope
; <<< CUSTOMIZE: GEN20 type — 2=Hanning(smooth), 1=Hamming, 3=Bartlett(triangle), 6=Gaussian
giWindow ftgen 0, 0, 8192, 20, 2

instr GranularTexture
  iAmp = p4                       ; <<< CUSTOMIZE: amplitude (0-1)
  iPitch = p5                     ; <<< CUSTOMIZE: pitch ratio (1=normal, 0.5=octave down)

  ; --- Grain Parameters ---
  ; <<< CUSTOMIZE: grain density (grains per second)
  ;   Sparse: 10-20, Smooth: 40-80, Dense: 80-200
  kDensity = 60

  ; <<< CUSTOMIZE: grain duration (seconds)
  ;   Clicky: 0.005-0.015, Short: 0.015-0.03, Medium: 0.03-0.06, Long: 0.06-0.15
  kGrainDur = 0.04

  ; <<< CUSTOMIZE: frequency scatter (pitch variation between grains)
  ;   None: 0, Subtle: 0.01-0.03, Chorus: 0.03-0.08, Wide: 0.1-0.5
  kFreqScatter = 0.02

  ; <<< CUSTOMIZE: position scatter (0-0.5)
  ;   Focused: 0-0.02, Moderate: 0.02-0.1, Wide: 0.1-0.3
  kPosScatter = 0.05

  ; Scan position through source
  kPos line 0, p3, 1

  ; Grain synthesis
  aL grain3 iPitch, kPos, kFreqScatter, kPosScatter, kGrainDur, kDensity, 80, giSource, giWindow, 0, 0
  ; Slightly different parameters for stereo
  aR grain3 iPitch*1.001, kPos+0.01, kFreqScatter, kPosScatter*1.1, kGrainDur*1.05, kDensity*0.95, 80, giSource, giWindow, 0, 0

  ; Amplitude envelope
  kEnv linseg 0, 0.5, 1, p3-1.5, 1, 1, 0

  outs aL * iAmp * kEnv, aR * iAmp * kEnv
endin

</CsInstruments>
<CsScore>
i "GranularTexture" 0  8  0.4  1
e 10
</CsScore>
</CsoundSynthesizer>
