<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

aenv expseg .01, p3*0.25, 1, p3*0.75, 0.01
asig poscil3 .8*aenv, p4, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1	;sine wave

m foo			;mark section
i 1 0   1 110
i 1 1.5 1 220
i 1 3   1 440
i 1 4.5 1 880
s			;second section
i 1 0 2 110
i 1 2 2 220
s
n foo			;repeat marked section
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
