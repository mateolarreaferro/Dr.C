<CsoundSynthesizer>

<CsInstruments>
0dbfs = 1

instr 1
  a1 oscil 0.8, 440
  a2 oscil 0.6, 880
  az = 0
  alow line -1, p3, -1
  ahigh line 1, p3, 1
  aout  select a1,a2,alow,az,ahigh
  outch 1, a1, 2,a2, 3,aout
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
