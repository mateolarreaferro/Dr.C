<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   1402
a2      linseg  0, p3*.3, 20000, p3*.4, 15000, p3*.3, 0
a1      fof     a2, 200, 650, 0, 40, .003, .02, .007, 5, 1, 2, p3
        out     a1
        endin

</CsInstruments>
<CsScore>
f 1 0   4096    10  1
f 2 0   1024    19  .5 .5 270 .5
                
i 1402  0   3       
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
