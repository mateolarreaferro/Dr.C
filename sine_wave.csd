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
    
    aOsc poscil iAmp, iFreq
    aOut = aOsc * 0.5
    
    outs aOut, aOut
endin

</CsInstruments>
<CsScore>
i 1 0 3 440 0.5
e
</CsScore>
</CsoundSynthesizer>
