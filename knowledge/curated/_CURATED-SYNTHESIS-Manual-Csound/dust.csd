<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kdens expon 2, p3, 20000
aout  dust 0.5, kdens
outs  aout, aout

endin
</CsInstruments>
<CsScore>
i1 0 10
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
