<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; Sine wave source table
giWave ftgen 0, 0, 16384, 10, 1

; Grain envelope (Hanning window)
giEnv ftgen 0, 0, 8192, 20, 2, 1

instr 1
  ; Parameters
  iFreq = p4
  iAmp = p5
  
  ; Envelope
  kEnv linsegr 0, 0.01, 1, 0.1, 0.8, 0.3, 0
  
  ; Granular parameters
  kGrainRate = 80        ; grains per second
  kGrainDur = 0.08       ; grain duration in seconds
  kPitch = iFreq / 440   ; pitch ratio
  
  ; Asynchronous granular synthesis
  aGran grain iAmp, kPitch, kGrainRate, kGrainDur, giWave, giEnv, -0.5
  
  ; Apply envelope and output
  aOut = aGran * kEnv * 0.4
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; p4=freq, p5=amp
i 1 0 3 440 0.6
i 1 3 3 330 0.6
i 1 6 3 220 0.6
e
</CsScore>
</CsoundSynthesizer>
