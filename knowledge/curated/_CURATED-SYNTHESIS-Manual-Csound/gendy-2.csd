<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kenv expseg 0.01, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0.001
kosc oscil 0.1, 3/p3, 1
seed 20120123
kdis bexprnd kosc
knum linseg 3, p3*0.75, 10, p3*0.20, 12, p3*0.05, 5
asig gendy 0.2, kosc*60, 6, 0.7, kdis, 500*kenv, 4800, 0.23, 0.3, 12, knum
aflt resonz asig, 1400, 400
aout comb kenv*aflt*0.1, 0.9, 0.1
outs aout, aout

endin
</CsInstruments>
<CsScore>
f1 0 8192 10 1 0 .8 0 0 .3 0 0 0 .1

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
