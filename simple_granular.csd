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

giEnv ftgen 0, 0, 8192, 20, 2, 1

instr 1
  kFreq = 440
  kGrainRate = 40
  
  ; Trigger for grains
  kTrig metro kGrainRate
  
  ; Random frequency and pan variation
  kFreqVar randomh 0.95, 1.05, kGrainRate
  kPan randomh 0.3, 0.7, kGrainRate
  
  ; Reset envelope on each trigger
  if kTrig == 1 then
    reinit GRAIN
  endif
  
GRAIN:
  ; Grain envelope (short)
  aEnv linseg 0, 0.01, 1, 0.04, 0
  
  ; Oscillator
  aOsc poscil aEnv, i(kFreq) * i(kFreqVar)
  rireturn
  
  aGrain = aOsc * 0.2
  
  aL = aGrain * kPan
  aR = aGrain * (1 - kPan)
  
  outs aL, aR
endin

</CsInstruments>
<CsScore>
i1 0 5
</CsScore>
</CsoundSynthesizer>
