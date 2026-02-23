<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

; Global audio send busses
gaDelSend init 0
gaRevSend init 0

instr 1
    iFreq = cpsmidinn(p4)
    iAmp = p5 / 127
    
    ; Plucked string using waveguide
    aPluck wgpluck2 0.98, iAmp, iFreq, 0.1, 0.5
    
    ; Simple envelope for note off
    kEnv linsegr 1, 0.1, 0
    aPluck = aPluck * kEnv
    
    ; Limit output
    aPluck limit aPluck, -0.9, 0.9
    
    ; Send to effects
    gaDelSend = gaDelSend + aPluck * 0.4
    gaRevSend = gaRevSend + aPluck * 0.3
    
    outs aPluck, aPluck
endin

instr 99 ; Delay effect
    aDelL delay gaDelSend, 0.375
    aDelR delay gaDelSend, 0.5
    
    ; Feedback
    gaDelSend = aDelL * 0.4
    
    outs aDelL, aDelR
    clear gaDelSend
endin

instr 100 ; Reverb effect
    aRevL, aRevR reverbsc gaRevSend, gaRevSend, 0.85, 8000
    
    outs aRevL, aRevR
    clear gaRevSend
endin

</CsInstruments>
<CsScore>
; Start effects (always on)
i 99 0 30
i 100 0 30

; Satie-like piece - two hands, left hand bass/chords, right hand melody
; Slow tempo, overlapping voices, modal harmony

; === First phrase ===
; Left hand - bass notes
i 1 0 6 36 55
i 1 2 5 43 48

; Right hand - melody enters
i 1 1 4 60 52
i 1 3 5 64 48
i 1 5.5 4 67 50

; === Second phrase ===
; Left hand - sustained bass
i 1 8 7 38 52
i 1 10 6 45 48

; Right hand - ascending figures
i 1 9 4 69 45
i 1 11 5 67 48
i 1 13 6 72 52
i 1 15 4 71 46

; === Third phrase - more dense ===
; Left hand - moving bass line
i 1 17 5 40 50
i 1 19 6 36 52
i 1 21.5 5 43 48

; Right hand - overlapping melody
i 1 18 5 64 48
i 1 20 6 67 50
i 1 22 5 69 46
i 1 24 6 64 48

; === Final phrase - resolution ===
; Left hand - cadence
i 1 26 8 36 55
i 1 28 6 43 48

; Right hand - final descent
i 1 27 5 67 50
i 1 29 7 60 52

e
</CsScore>
</CsoundSynthesizer>
