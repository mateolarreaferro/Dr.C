<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr 204
ifrq    =       cpspch(p5)
kenv    linseg  0, .05, p4, p3-.1, p4*.8, .05, 0
asig    oscili  kenv, ifrq/21, p6
        out     asig
        endin

</CsInstruments>
<CsScore>
f 13    0   8192    9   21 1 0 22 1 0 25 1 0 27 1 0 31 1 0 33 1 0 34 1 0 35 1 0 

i 204 0     3 20000     8.09 13
i 204 4     . .         8.07 13
i 204 8     . .         8.05 13
i 204 12    . .         8.03 13
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
