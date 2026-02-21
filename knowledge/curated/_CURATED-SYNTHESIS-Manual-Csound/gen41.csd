<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

k1   duserrnd 1
 ;    printk 0, k1
asig poscil .5, 220*k1, 2
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f1 0 -20 -41  2 .1 8 .9	;choose 2 at 10% probability, 8 at 90%

f2 0 8192 10 1

i1 0 2
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
