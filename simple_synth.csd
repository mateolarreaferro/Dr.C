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
  
  kEnv linsegr 0, 0.01, 1, 0.1, 0.7, 0.2, 0
  aOsc poscil iAmp * kEnv, iFreq
  
  outs aOsc, aOsc
endin

</CsInstruments>
<CsScore>
i 1 0 1 440 0.3
i 1 1 1 523.25 0.3
i 1 2 1 659.25 0.3
i 1 3 2 880 0.3
e
</CsScore>
</CsoundSynthesizer>
