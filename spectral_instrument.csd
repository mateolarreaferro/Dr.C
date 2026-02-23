<CsoundSynthesizer>
<CsOptions>
-odac -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; Sine wave function table
giSine ftgen 0, 0, 4096, 10, 1

instr 1
  ; Parameters
  iFreq = p4
  iAmp = p5
  
  ; Envelope
  kEnv linsegr 0, 0.01, 1, 0.1, 0.7, 0.3, 0
  
  ; Source oscillator
  aSource poscil iAmp, iFreq
  
  ; FFT analysis
  fSig pvsanal aSource, 1024, 256, 1024, 1
  
  ; Spectral manipulation: frequency shift
  kShift = 1.5
  fShift pvscale fSig, kShift
  
  ; Resynthesis
  aOut pvsynth fShift
  
  ; Apply envelope and output
  aOut = aOut * kEnv * 0.3
  outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; p4=freq, p5=amp
i 1 0 3 220 0.5
i 1 3 3 165 0.5
i 1 6 3 110 0.5
e
</CsScore>
</CsoundSynthesizer>
