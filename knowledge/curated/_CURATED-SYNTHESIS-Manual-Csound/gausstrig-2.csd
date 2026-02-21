<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kfrq0 oscil 8, 0.25, 1
ktrig metro 1
kfrq  samphold kfrq0+8, ktrig 
seed  20120125
aimp  gausstrig 0.5, kfrq, 0.5, 1
aenv  filter2 aimp, 1, 1, 0.993, 0.993
anoi  fractalnoise 0.2, 1.7
al    = anoi*aenv
ar    delay al, 0.02
outs  al, ar

endin
</CsInstruments>
<CsScore>
f1 0 8192 10 1
i1 0 16
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
