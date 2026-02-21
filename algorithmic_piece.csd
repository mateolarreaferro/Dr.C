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

; Global delay buffer
gaDelayL init 0
gaDelayR init 0

instr 1 ; Sine tone generator
    iFreq = p4
    iAmp = p5
    iPan = p6
    iAttack = 0.01
    iRelease = 0.1
    
    kEnv linsegr 0, iAttack, iAmp, iRelease, 0
    aOsc poscil kEnv, iFreq
    
    aPanL = aOsc * sqrt(1 - iPan)
    aPanR = aOsc * sqrt(iPan)
    
    gaDelayL += aPanL
    gaDelayR += aPanR
    
    outs aPanL, aPanR
endin

instr 99 ; Global delay effect
    kFeedback = 0.4
    iDelayTime = 0.375
    
    aDelL delayr 2
    aTapL deltapi iDelayTime
    delayw gaDelayL + (aTapL * kFeedback)
    
    aDelR delayr 2
    aTapR deltapi iDelayTime + 0.125
    delayw gaDelayR + (aTapR * kFeedback)
    
    aOutL = gaDelayL + (aTapL * 0.3)
    aOutR = gaDelayR + (aTapR * 0.3)
    
    outs aOutL, aOutR
    
    clear gaDelayL, gaDelayR
endin

</CsInstruments>
<CsScore>
; Algorithmic pattern: Euclidean rhythm with minor pentatonic scale
; Scale: A C D E G (220, 261.63, 293.66, 329.63, 392)

i 99 0 20 ; Global delay always on

; Pattern 1: Fast pulses
i 1 0 0.3 220 0.2 0.2
i 1 0.5 0.3 329.63 0.15 0.8
i 1 1 0.3 392 0.2 0.5
i 1 1.5 0.3 293.66 0.15 0.3
i 1 2 0.3 261.63 0.2 0.7

i 1 2.5 0.3 392 0.2 0.4
i 1 3 0.3 220 0.15 0.6
i 1 3.5 0.3 329.63 0.2 0.2
i 1 4 0.3 293.66 0.15 0.8
i 1 4.5 0.3 261.63 0.2 0.5

; Pattern 2: Lower register enters
i 1 5 0.4 110 0.25 0.5
i 1 5.75 0.4 130.81 0.2 0.4
i 1 6.5 0.4 146.83 0.25 0.6
i 1 7.25 0.4 164.81 0.2 0.7

; Overlapping patterns
i 1 8 0.2 392 0.15 0.3
i 1 8.25 0.2 329.63 0.15 0.7
i 1 8.5 0.2 293.66 0.15 0.5
i 1 8.75 0.2 261.63 0.15 0.4
i 1 9 0.2 220 0.15 0.6
i 1 9.25 0.2 261.63 0.15 0.2
i 1 9.5 0.2 293.66 0.15 0.8

i 1 10 0.5 164.81 0.3 0.5
i 1 10.5 0.3 220 0.2 0.3
i 1 11 0.3 293.66 0.2 0.7
i 1 11.5 0.5 329.63 0.25 0.5

; Sparse ending
i 1 12 0.6 392 0.25 0.4
i 1 13 0.6 293.66 0.2 0.6
i 1 14.5 0.8 220 0.3 0.5
i 1 16 1.2 164.81 0.25 0.5

e
</CsScore>
</CsoundSynthesizer>
