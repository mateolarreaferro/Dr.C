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
  iFreq = p4
  iAmp = p5
  
  ; ADSR envelope
  kEnv madsr 0.01, 0.1, 0.7, 0.3
  
  ; Sawtooth oscillator
  aSaw vco2 iAmp, iFreq
  
  ; Low-pass filter with envelope-controlled cutoff
  kCutoff = 400 + (kEnv * 3000)
  aFilt moogladder aSaw, kCutoff, 0.6
  
  ; Apply envelope to amplitude
  aOut = aFilt * kEnv
  
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; Play a simple melody
i 1 0 384.737 0.736842 0.5
i 1 1 384.737 0.736842 0.5
i 1 2 384.737 0.736842 0.5
i 1 3 384.737 0.736842 0.5
e
</CsScore>
</CsoundSynthesizer>
