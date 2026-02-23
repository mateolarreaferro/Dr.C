<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

gaRvbSend init 0
gaDelaySend init 0

instr 1
  iFreq = p4
  iAmp = p5
  
  aOsc poscil iAmp, iFreq
  aOut = aOsc * 0.7
  
  gaRvbSend += aOut * 0.3
  gaDelaySend += aOut * 0.2
  
  outs aOut, aOut
endin

instr 99 ; Effects
  ; Delay
  aDelL delayr 0.5
  aDel1L deltap 0.375
  delayw gaDelaySend
  
  aDelR delayr 0.5
  aDel1R deltap 0.4
  delayw gaDelaySend
  
  aDelOut = (aDel1L + aDel1R) * 0.6
  
  ; Reverb
  aRvbL, aRvbR reverbsc gaRvbSend, gaRvbSend, 0.85, 8000
  
  outs aDelOut + aRvbL*0.5, aDelOut + aRvbR*0.5
  
  clear gaRvbSend, gaDelaySend
endin

</CsInstruments>
<CsScore>
i 99 0 10
i 1 0 2 440 0.5
i 1 3 2 523.25 0.5
i 1 6 2 659.25 0.5
e
</CsScore>
</CsoundSynthesizer>
