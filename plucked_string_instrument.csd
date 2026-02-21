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
    iDecay = p6
    
    ; Karplus-Strong plucked string with softer parameters
    aNoise rand 0.3
    aPluck init 0
    aDelay delayr 1/iFreq
    aPluck deltapi 1/iFreq - ksmps/sr
    delayw aNoise * (1 - aPluck) + aPluck * 0.998 * iDecay
    
    ; Gentle envelope
    aEnv expon 1, p3, 0.001
    
    ; Low-pass filter for softness
    aFilt tone aPluck, 2000
    
    ; Output
    aOut = aFilt * iAmp * aEnv
    outs aOut, aOut
endin

</CsInstruments>
<CsScore>
; C major arpeggio - soft and gentle
; instr start dur freq amp decay
i 1 0 3 261.63 0.25 0.998     ; C4
i 1 0.6 3 329.63 0.22 0.998   ; E4
i 1 1.2 3 392.00 0.22 0.998   ; G4
i 1 1.8 3 523.25 0.20 0.998   ; C5
i 1 2.4 3 392.00 0.22 0.998   ; G4
i 1 3.0 4 329.63 0.25 0.999   ; E4
e
</CsScore>
</CsoundSynthesizer>
