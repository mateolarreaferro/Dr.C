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

instr 1
  iFreq = p4
  iAmp = p5
  
  ; ADSR envelope
  kEnv madsr 0.01, 0.1, 0.7, 0.5
  
  ; Sawtooth oscillator
  aSaw vco2 iAmp, iFreq, 0
  
  ; Low-pass filter
  ; LFO modulates cutoff
  kLfo lfo 1, 0.3, 0
  kCutoff = 2000 + (kLfo * 1800)
  kRes = 0.7
  aFiltered moogladder aSaw, kCutoff, kRes
  
  ; Apply envelope
  aOut = aFiltered * kEnv
  
  ; Limit output
  aOut clip aOut, 0, 0.9
  
  ; Send to reverb bus
  chnmix aOut, "reverbSendL"
  chnmix aOut, "reverbSendR"
endin

instr 99 ; Global reverb
  aInL chnget "reverbSendL"
  aInR chnget "reverbSendR"
  
  ; Freeverb stereo reverb
  aReverbL, aReverbR freeverb aInL, aInR, 0.85, 0.5
  
  outs aReverbL, aReverbR
  
  ; Clear bus
  chnclear "reverbSendL", "reverbSendR"
endin

</CsInstruments>
<CsScore>
i 99 0 30  ; Reverb runs for entire duration

; "The Star-Spangled Banner" (USA National Anthem)
; Oh say can you see
i 1 0    0.35  0.35 0.35  ; C4 - Oh
i 1 0.8  0.35  0.35 0.35  ; E4 - say
i 1 1.6  0.35  0.35 0.35  ; G4 - can
i 1 2.5  0.35  0.35 0.35  ; C5 - you

; by the dawn's early light
i 1 3.8  0.35  0.35 0.35  ; B4 - see
i 1 4.6  0.35  0.35 0.35  ; A4 - by
i 1 5.2  0.35  0.35 0.35  ; G4 - the
i 1 5.8  0.35  0.35 0.35  ; E4 - dawn's
i 1 6.7  0.35  0.35 0.35  ; G4 - ear-
i 1 7.9  0.35  0.35 0.35  ; C4 - ly
i 1 9.2  0.35  0.35 0.35  ; E4 - light

; What so proudly we hailed
i 1 10.5 0.35  0.35 0.35  ; G4 - What
i 1 11.3 0.35  0.35 0.35  ; C5 - so
i 1 12.1 0.35  0.35 0.35  ; B4 - proud-
i 1 13.0 0.35  0.35 0.35  ; A4 - ly
i 1 14.3 0.35  0.35 0.35  ; G4 - we
i 1 15.1 0.35  0.35 0.35  ; C5 - hailed

; at the twilight's last gleaming
i 1 16.8 0.35  0.35 0.35  ; D5 - at
i 1 17.4 0.35  0.35 0.35  ; C5 - the
i 1 18.0 0.35  0.35 0.35  ; B4 - twi-
i 1 18.8 0.35  0.35 0.35  ; A4 - light's
i 1 19.7 0.35  0.35 0.35  ; G4 - last
i 1 21.0 0.35  0.35 0.35  ; E4 - gleam-ing

e
</CsScore>
</CsoundSynthesizer>
