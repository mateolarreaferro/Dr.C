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
  ; Parameters
  iFreq = p4
  iAmp = p5
  iModIndex = p6
  
  ; Envelope
  kEnv linsegr 0, 0.01, 1, 0.1, 0.8, 0.2, 0
  
  ; Modulator frequency (carrier ratio)
  iModRatio = 1.4
  iModFreq = iFreq * iModRatio
  
  ; FM synthesis: modulator modulates carrier frequency
  aModulator poscil (iModIndex * 0.3) * iModFreq, iModFreq
  aCarrier poscil iAmp, iFreq + aModulator
  
  ; Apply envelope and output
  aOut = aCarrier * kEnv
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; p4=freq, p5=amp, p6=modulation index
i 1 0 2 440 0.3 200
i 1 2 2 554 0.3 300
i 1 4 2 659 0.3 400
e
</CsScore>
</CsoundSynthesizer>
