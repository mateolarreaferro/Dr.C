<CsoundSynthesizer>
<CsInstruments>

0dbfs = 1

instr 1
aEnv linseg 0, .2, 1, .2, .5, .2, .7, .2, 0
a1 oscili aEnv, 400
outs a1, a1
endin

instr 2
kTrig metro 1
aEnv trigLinseg kTrig, 0, .2, 1, .2, .5, .2, .7, .2, 0
a1 oscili aEnv, 400
outs a1, a1
endin

</CsInstruments>
<CsScore>
i1 0 1
i2 1 10
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
