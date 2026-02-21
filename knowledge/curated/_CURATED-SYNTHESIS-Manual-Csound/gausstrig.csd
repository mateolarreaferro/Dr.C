<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kdev line 0, p3, 0.9
seed 20120125
aimp gausstrig 0.5, 10, kdev
aenv filter2 aimp, 1, 1, 0.993, 0.993
anoi fractalnoise 0.2, 1.7
al   = anoi*aenv
ar   delay al, 0.02
outs al, ar

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
