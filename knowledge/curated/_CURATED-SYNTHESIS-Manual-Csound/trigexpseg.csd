<CsoundSynthesizer>
<CsInstruments>

0dbfs = 1

instr 1
aEnv expseg 0.0001, .2, 1, .2, .5, .2, .7, .2, 0.0001
a1 oscili aEnv, 400
outs a1, a1
endin

instr 2
kTrig metro 1
aEnv trigexpseg kTrig, 0.0001, .2, 1, .2, .5, .2, .7, .2, 0.0001
a1 oscili aEnv, 400
outs a1, a1
endin

</CsInstruments>
<CsScore>
i1 0 1
i2 3 8
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
