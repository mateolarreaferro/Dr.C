<CsoundSynthesizer>
<CsOptions>
-d -m0 -W
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1
seed 0

; ============================================================
; Reverb + Delay Effects Chain Template
; Source → Delay → Reverb → Output
; ============================================================

giSine ftgen 0, 0, 8192, 10, 1

; --- Source instrument (generates something to process) ---
instr Source
  iFreq = p4
  iAmp = p5
  kEnv madsr 0.01, 0.15, 0.3, 0.2
  aOsc vco2 1, iFreq, 0
  aFilt moogladder aOsc, 2000, 0.3
  aOut = aFilt * kEnv * iAmp

  ; Send to effects bus
  chnset aOut, "delayInL"
  chnset aOut, "delayInR"
endin

; --- Delay Effect ---
instr Delay
  ; <<< CUSTOMIZE: delay parameters
  kDelayTime = 0.375              ; delay time in seconds
  kFeedback = 0.45                ; feedback amount (0-0.9, careful above 0.8)
  kMix = 0.35                     ; wet/dry mix (0=dry, 1=wet)
  kHighCut = 6000                 ; feedback filter cutoff (darkens repeats)

  aInL chnget "delayInL"
  aInR chnget "delayInR"

  ; Delay with feedback and filtering
  aDelL init 0
  aDelR init 0

  ; Left delay
  aReadL delayr 2.0               ; max delay buffer
    aTapL deltapi kDelayTime
  delayw aInL + (aDelL * kFeedback)
  aDelL tone aTapL, kHighCut      ; darken repeats

  ; Right delay (slightly offset for stereo)
  aReadR delayr 2.0
    aTapR deltapi kDelayTime * 0.75  ; <<< CUSTOMIZE: ratio for ping-pong
  delayw aInR + (aDelR * kFeedback)
  aDelR tone aTapR, kHighCut

  ; Mix dry + wet
  aOutL = aInL * (1 - kMix) + aDelL * kMix
  aOutR = aInR * (1 - kMix) + aDelR * kMix

  ; Send to reverb
  chnset aOutL, "reverbInL"
  chnset aOutR, "reverbInR"
endin

; --- Reverb Effect ---
instr Reverb
  ; <<< CUSTOMIZE: reverb parameters
  kRoomSize = 0.85                ; feedback level (0.1-0.99, higher=longer tail)
  kDamping = 8000                 ; high frequency damping cutoff (Hz)
  kMix = 0.25                     ; wet/dry mix

  aInL chnget "reverbInL"
  aInR chnget "reverbInR"

  ; Schroeder reverb
  aWetL, aWetR reverbsc aInL, aInR, kRoomSize, kDamping

  ; Mix
  aOutL = aInL * (1 - kMix) + aWetL * kMix
  aOutR = aInR * (1 - kMix) + aWetR * kMix

  aOutL limit aOutL, -1, 1
  aOutR limit aOutR, -1, 1
  outs aOutL, aOutR
endin

</CsInstruments>
<CsScore>
; Start effects (run for entire duration)
i "Delay"  0  12
i "Reverb" 0  12

; Source notes
i "Source" 0    0.5   330   0.5
i "Source" 0.5  0.5   440   0.45
i "Source" 1    0.5   523   0.4
i "Source" 2    1     392   0.5
i "Source" 4    2     262   0.5
e 12
</CsScore>
</CsoundSynthesizer>
