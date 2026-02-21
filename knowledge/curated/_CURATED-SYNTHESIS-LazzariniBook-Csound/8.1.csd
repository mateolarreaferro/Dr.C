<CsoundSynthesizer>
<CsInstruments>
instr 1
 out oscili(p4,p5,1)
endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1 0.5 0.33 0.25 0.2
; first section
i1 0 5 1000 440
i1 1 1 1000 550
i1 2 1 1000 660
i1 3 1 1000 880
s
; second section
i1 3 1 1000 440
i1 2 1 1000 550
i1 1 1 1000 660
i1 1 5 1000 880
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
