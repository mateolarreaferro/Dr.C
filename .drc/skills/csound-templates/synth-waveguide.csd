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
; Waveguide Physical Model Template
; Plucked string using wgpluck2
; ============================================================

giSine ftgen 0, 0, 8192, 10, 1

instr PluckedString
  iFreq = p4                      ; <<< CUSTOMIZE: pitch (Hz)
  iAmp = p5                       ; <<< CUSTOMIZE: amplitude (0-1)

  ; --- Pluck Parameters ---
  ; <<< CUSTOMIZE: pluck position (0-1)
  ;   0.5 = center (mellow, round)
  ;   0.1-0.3 = near bridge (bright, nasal)
  ;   0.7-0.9 = near nut (thinner)
  iPlkPos = 0.4

  ; <<< CUSTOMIZE: damping (30-500)
  ;   Low (30-80) = nylon string, muted
  ;   Medium (80-200) = steel string
  ;   High (200-500) = bright, ringing
  iDamp = 120

  ; <<< CUSTOMIZE: filter (0-1)
  ;   Low (0.1-0.3) = dark, nylon guitar
  ;   Medium (0.4-0.6) = balanced
  ;   High (0.7-0.9) = steel string, bright
  iFilt = 0.5

  ; --- Waveguide ---
  aOut wgpluck2 iPlkPos, iAmp, iFreq, iPlkPos, iDamp, iFilt, 0, 0

  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; Simple plucked melody
i "PluckedString" 0    2     330     0.6
i "PluckedString" 0.5  2     392     0.5
i "PluckedString" 1    2     440     0.55
i "PluckedString" 1.5  3     523     0.5
e 6
</CsScore>
</CsoundSynthesizer>
