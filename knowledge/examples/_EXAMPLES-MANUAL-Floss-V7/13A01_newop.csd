<CsoundSynthesizer>
<CsOptions>
--opcode-lib=newopc.so  ; OSX: newopc.dylib; Windows: newopc.dll
</CsOptions>
<CsInstruments>

schedule 1,0,100,440

instr 1

asig   newopc  0, 0.001, 1
ksig   newopc  1, 0.001, 1.5
aosc   oscili 1000, p4*ksig
    out aosc*asig

endin

</CsInstruments>
</CsoundSynthesizer>
;example by victor lazzarini
