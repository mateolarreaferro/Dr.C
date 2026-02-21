<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.5_conversioni

0dbfs = 1

instr	1

kamp	=	p4 
kfreq	=	cpspch(p5)
a1	pluck	kamp,kfreq,220,0,1

out	a1

endin

</CsInstruments>
<CsScore>

i1	0	1	.5	7.00 
s
i1	0	1	.5	7.02
s
i1	0	1	.5	7.04
s
i1	0	1	.5	7.05
s
i1	0	3	.5	7.07
s
i1	0	.1	.5	7.07
s
i1	0	.1	.5	7.05
s
i1	0	.1	.5	7.04
s
i1	0	.1	.5	7.02
s
i1	0	4	.5	7.00
s
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
