<CsoundSynthesizer>
<CsInstruments>

0dbfs = 1

instr 1

a1 rand p4
af expon 20,p3,20000
a2 vclpf a1,af, 0.7
 out a2

endin

</CsInstruments>
<CsScore>
i1 0 5 0.1
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
