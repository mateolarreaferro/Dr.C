<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
        instr   1406
a2      line    400, p3, 800
a1      fof     17000, 2, a2, 0, 0, .003, .5, .1, 3, 1, 2, p3, 0, 0
        out     a1
        endin
    
        
        instr   1407
a2      line    400, p3, 800
a1      fof     17000, 2, a2, 0, 0, .003, .5, .1, 3, 1, 2, p3, 0, 1
        out     a1
        endin


</CsInstruments>
<CsScore>
f 1 0   4096    10  1
f 2 0   1024    19  .5 .5 270 .5
                
i 1406   0   10
i 1407  12   10     
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>61</y>
 <width>396</width>
 <height>661</height>
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
