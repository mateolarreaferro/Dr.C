<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1
kenv expseg 0.001, p3*0.05, 0.5, p3*0.9, 0.5, p3*0.05, 0.001
kc1  linseg 1, p3/2, 12, p3/2, 3
kc2  random 0, 4
seed 20120124
asig gendyx kenv, 1, 3, 0.7, 0.8, 120, 4300, 0.2, 0.7, kc1, kc2, 12, kc1
aout dcblock asig
outs aout, aout
endin
</CsInstruments>
<CsScore>
i1 0 20
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
