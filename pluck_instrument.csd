<CsoundSynthesizer>
<CsOptions>
-o dac -d -m0
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

seed 0

; Global reverb send
ga_send init 0

instr 1
  iFreq = p4
  iAmp = p5
  iDecay = p6
  
  ; Karplus-Strong plucked string
  aPluck pluck iAmp, iFreq, iFreq, 0, 1, 0, iDecay
  
  ; Send to reverb
  ga_send += aPluck * 0.5
  
  ; Dry output
  aL = aPluck * 0.6
  aR = aPluck * 0.6
  
  outs aL, aR
endin

instr 99
  ; Global reverb
  aRvbL, aRvbR reverbsc ga_send, ga_send, 0.85, 8000
  
  outs aRvbL * 0.4, aRvbR * 0.4
  
  ; Clear the send
  clear ga_send
endin

</CsInstruments>
<CsScore>
; Plucked string melody with global reverb
; instr start dur freq amp decay
i 1 0 1.5 262 0.6 0.4
i 1 1.5 1.5 330 0.5 0.5
i 1 3 1.5 392 0.6 0.4
i 1 4.5 1.5 523 0.5 0.6
i 1 6 2 392 0.6 0.3
i 1 8 1.5 330 0.5 0.5
i 1 9.5 1.5 262 0.6 0.4
i 1 11 1.5 330 0.5 0.5
i 1 12.5 1.5 392 0.6 0.4
i 1 14 2 440 0.7 0.3
i 1 16 1.5 523 0.6 0.5
i 1 17.5 1.5 440 0.5 0.4
i 1 19 1.5 392 0.6 0.5
i 1 20.5 1.5 330 0.5 0.6
i 1 22 3 262 0.7 0.3

; Global reverb (always on)
i 99 0 25
e
</CsScore>
</CsoundSynthesizer>
