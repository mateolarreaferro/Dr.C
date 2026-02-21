<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

seed 0

instr 1
  iFreq = p4
  iAmp = p5
  iDecay = p6
  
  ; Karplus-Strong plucked string
  aNoise rand 0.5
  aPluck init 0
  aDelay delayr 1/iFreq
  aPluck deltapi 1/iFreq - 0.0001
  delayw aNoise + aPluck * iDecay
  
  ; Envelope and output
  aEnv expon 1, p3, 0.001
  aOut = aPluck * iAmp * aEnv
  aOut clip aOut, 0, 0.95
  
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; Plucked string sequence
; p4=frequency, p5=amplitude, p6=decay factor

; Brian Eno "Music for Airports" style - overlapping loops
; Loop 1: 7.3 second cycle
i1 0 6 261.63 0.25 0.998   ; C4
i1 7.3 6 349.23 0.22 0.998  ; F4
i1 14.6 6 392.00 0.28 0.998 ; G4
i1 21.9 6 523.25 0.20 0.998 ; C5

; Loop 2: 11.7 second cycle
i1 2.1 8 293.66 0.18 0.998  ; D4
i1 13.8 8 392.00 0.23 0.998 ; G4
i1 25.5 8 293.66 0.19 0.998 ; D4

; Loop 3: 13.2 second cycle
i1 5.5 9 349.23 0.21 0.998  ; F4
i1 18.7 9 523.25 0.17 0.998 ; C5

; Loop 4: 17.1 second cycle
i1 8.9 11 440.00 0.16 0.998 ; A4
i1 26.0 11 587.33 0.15 0.998; D5

e
</CsScore>
</CsoundSynthesizer>
