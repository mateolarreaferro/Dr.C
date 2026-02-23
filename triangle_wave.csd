<CsoundSynthesizer>
; Prompt: make a simple triangle wave
<CsOptions>
-o dac -d -m0
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
  iCutoff = p6
  
  ; Plucked string decay envelope
  kAmpEnv expon iAmp, p3, 0.001
  
  aPluck pluck kAmpEnv, iFreq, iFreq, 0, 1
  
  aFilt moogladder aPluck, iCutoff, 0.2
  
  outs aFilt, aFilt
  
  gaRvbSend = gaRvbSend + aFilt * 0.4
  gaDelaySend = gaDelaySend + aFilt * 0.5
endin

instr 99 ; Long echo
  aDelL init 0
  aDelR init 0
  
  ; Master fade out over last 10 seconds
  kFade linseg 1, 35, 1, 10, 0
  
  aDelL vdelay3 gaDelaySend + aDelR*0.4, 2700, 8000
  aDelR vdelay3 gaDelaySend + aDelL*0.4, 3100, 8000
  
  aFiltL tone aDelL, 1200
  aFiltR tone aDelR, 1200
  
  outs aFiltL*0.6*kFade, aFiltR*0.6*kFade
  
  gaDelaySend = 0
endin

instr 100 ; Reverb
  ; Master fade out over last 10 seconds
  kFade linseg 1, 35, 1, 10, 0
  
  aRvbL, aRvbR reverbsc gaRvbSend, gaRvbSend, 0.92, 8000
  
  outs aRvbL*0.5*kFade, aRvbR*0.5*kFade
  
  gaRvbSend = 0
endin

</CsInstruments>
<CsScore>
; Brian Eno-style ambient textures
; sustained overlapping tones with different fundamentals
i 1 0    30   277.18  0.15  800   ; C#4
i 1 4    28   329.63  0.12  600   ; E4
i 1 9    26   415.30  0.10  700   ; G#4
i 1 15   24   261.63  0.14  500   ; C4
i 1 20   22   554.37  0.08  900   ; C#5
i 1 25   20   369.99  0.11  650   ; F#4

i 99 0 45
i 100 0 45
</CsScore>
</CsoundSynthesizer>
