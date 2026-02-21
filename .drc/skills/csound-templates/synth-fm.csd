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
; FM Synthesis Template
; 2-operator FM with index envelope
; ============================================================

giSine ftgen 0, 0, 8192, 10, 1

instr FMSynth
  iFreq = p4                      ; <<< CUSTOMIZE: pitch (Hz)
  iAmp = p5                       ; <<< CUSTOMIZE: amplitude (0-1)

  ; --- FM Parameters ---
  ; <<< CUSTOMIZE: carrier:modulator ratio
  ;   1:1 = brass/organ, 1:1.4 = bell, 1:2 = bright, 1:7 = epiano tine
  iCarrier = 1
  iModulator = 1.4

  ; --- Index Envelope ---
  ; <<< CUSTOMIZE: index start, sustain, end (higher = more harmonics)
  ;   Bells: 12 → 0.5 fast decay
  ;   Brass: 2 → 8 rising with amplitude
  ;   EPiano: 5 → 1 medium decay
  iIdxStart = 10
  iIdxSustain = 2
  iIdxEnd = 0.5
  kIdx linseg iIdxStart, 0.01, iIdxStart, 0.3, iIdxSustain, p3-0.41, iIdxEnd, 0.1, iIdxEnd

  ; --- Amplitude Envelope ---
  ; <<< CUSTOMIZE: ADSR (bells: fast attack, long decay; brass: slow attack)
  kAmp expsegr iAmp, 0.002, iAmp, p3-0.102, 0.001, 0.1, 0.001

  ; --- FM Oscillator ---
  aOut foscili kAmp, iFreq, iCarrier, iModulator, kIdx, giSine

  aOut limit aOut, -1, 1
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; Bell-like sounds at different pitches
i "FMSynth" 0    3     523     0.4
i "FMSynth" 1    3     659     0.35
i "FMSynth" 2    4     784     0.3
e 10
</CsScore>
</CsoundSynthesizer>
