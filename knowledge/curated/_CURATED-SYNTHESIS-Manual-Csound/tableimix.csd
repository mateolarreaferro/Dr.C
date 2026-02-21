<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

gisine ftgen 1, 0, 256, 10, 1, 0, 0, .4		;sinoid
gisaw  ftgen 2, 0, 1024, 7, 0, 256, 1		;saw
gimix  ftgen 100, 0, 256, 7, 0, 256, 1		;used to mix

instr 1

      tableimix 100, 0, 256, 1, 0, 1, 2, 0, .5
asig  poscil .5, 110, gimix			;mix table 1 & 2			
      outs   asig, asig

endin
</CsInstruments>
<CsScore>

i1 0 5
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
