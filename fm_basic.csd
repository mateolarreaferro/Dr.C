<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

instr 1
  iAmp = p4
  iFreq = p5
  iDecay = p6
  
  ; Plucked string using Karplus-Strong algorithm
  aPluck pluck iAmp, iFreq, iFreq, 0, 1, iDecay
  
  ; Simple lowpass filter for warmth
  aFilt tone aPluck, 3000
  
  aOut = aFilt * 0.7
  
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; p4=amp p5=freq p6=decay
i 1 0 3 0.8 261.63 0.8    ; C4
i 1 1 3 0.8 329.63 0.9    ; E4
i 1 2 3 0.8 392.00 0.85   ; G4
i 1 3 4 0.8 523.25 0.95   ; C5
e
</CsScore>
</CsoundSynthesizer>
