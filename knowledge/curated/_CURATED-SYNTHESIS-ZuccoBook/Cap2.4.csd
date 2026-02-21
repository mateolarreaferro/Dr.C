<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap2.4



instr	1   

a1	oscil	p4,p5,1
a2	oscil	p4,p6,2
a3	oscil	p4,p7,3
a4	oscil	p4,p8,4

asomma	sum	a1,a2,a3,a4

out	asomma

endin	 

</CsInstruments>
<CsScore>
f1	0	4096	10	1
f2	0	4096	10	0	1
f3	0	4096	10	0	0	1
f4	0	4096	10	0	0	0	1

;p1	p2	p3	p4	p5	p6	p7	p8
i1	0	4	.1	440	540	640	740

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
