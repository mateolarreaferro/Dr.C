<CsoundSynthesizer>
<CsInstruments>
instr 1
 out oscili(p4,p5)
endin
</CsInstruments>
<CsScore>
i 1 0 5 10000 440   
i . + 2 . 330    ;i1 5 2 1000 440
i . + 1          ;i1 7 1 1000 330
i 2 0 1 55.4 22.1      
i . ^+1 . 67.1   ;i2 1 1 67.1 22.1
i . ^+2 . !      ;i2 3 1 [no p4 or p5 are carried]
e 
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
