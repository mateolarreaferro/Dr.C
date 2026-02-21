<CsoundSynthesizer>

<CsInstruments>
0dbfs = 1

gisine  ftgen  0,0,4096,10,1
gi31    ftgen  0,0,4096,31,gisine, 1,1,0, 2,1,0, 3,1,0, 4,1,0, 5,1,0, 6,1,0

instr 1
  aa  oscil3  0.6, 440, gi31
      out     aa
endin
</CsInstruments>

<CsScore>
i1 0 5
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
