<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -odac
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

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
    
    outs aPluck, aPluck
endin

</CsInstruments>
<CsScore>
; Play a simple melody
i 1 0 2 60 100
i 1 2 2 64 100
i 1 4 2 67 100
i 1 6 4 72 100
e
</CsScore>
</CsoundSynthesizer>
