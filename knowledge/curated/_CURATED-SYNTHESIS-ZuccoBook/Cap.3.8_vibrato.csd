<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.8_vibrato

0dbfs = 1

instr	1

kvibrato	oscili	3,2,1
iamp	=	p4
ifreq	=	cpspch(p5)
a1	vco2	iamp,ifreq+kvibrato,0,.8
out	a1

endin

instr	2

kvibrato	lfo	4,.7
iamp	=	p4
ifreq	=	cpspch(p5)
a1	vco2	iamp,ifreq+kvibrato,0,.8
out	a1

endin

instr	3

kvibrato jitter 6,.1,8
iamp	=	p4
ifreq	=	cpspch(p5)
a1	pluck	iamp,ifreq+kvibrato,220,0,1
out	a1

endin

instr	4

kvibrato jitter2 6,.5,4,.1,22,.3,12
iamp	=	p4
ifreq	=	cpspch(p5)
a1	pluck	iamp,ifreq+kvibrato,220,0,1
out	a1

endin

instr	5

kvibrato jspline 5,1,8
iamp	=	p4
ifreq	=	cpspch(p5)
a1	pluck	iamp,ifreq+kvibrato,220,0,1
out	a1

endin

</CsInstruments>
<CsScore>
f1	0	4096	10	1

i1	0	4	.6	8.00
s
i2	0	4	.6	8.00
s
i3	0	4	.6	8.00
s
i4	0	4	.6	8.00
s
i5	0	4	.6	8.00
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
