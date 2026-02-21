<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kfe  expseg 500, p3*0.9, 1800, p3*0.1, 3000
asig buzz  1, 100, 20, 1
kres line .1, p3, .99	;increase resonance
afil moogladder asig, kfe, kres
     outs afil, afil

endin
</CsInstruments>
<CsScore>
f 1 0 4096 10 1

i 1 0 10
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
