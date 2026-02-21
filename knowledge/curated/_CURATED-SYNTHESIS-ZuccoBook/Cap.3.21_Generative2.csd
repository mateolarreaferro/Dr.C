<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.21_Generative2

0dbfs = 1

instr	1

krndtime	linseg	.1,p3/4,4,p3/4,.2,p3/4,10,p3/4,.1
krnddur	random	.02,.1	;durata random di ogni evento
ktrig1	metro	krndtime	;intervallo tra un evento e il successivo
kdur	=	krnddur	;durata di ogni evento (p3 nella score)
kwhen	=	0	;attacco (p2 nella score)
schedkwhennamed	ktrig1,0,100,"percussion1",kwhen,kdur
schedkwhennamed	ktrig1,0,100,"percussion2",kwhen+4,kdur
schedkwhennamed	ktrig1,0,100,"percussion3",kwhen+8,kdur
schedkwhennamed	ktrig1,0,100,"percussion4",kwhen+12,kdur
schedkwhennamed	ktrig1,0,100,"percussion5",kwhen+24,kdur
schedkwhennamed	ktrig1,0,100,"water",kwhen+32,kdur

endin


instr	percussion1
a1	guiro	.5,.01
outs	a1,a1*0
endin

instr	percussion2
a1	cabasa	.5,.07
outs	a1*0,a1
endin

instr	percussion3
a1	sleighbells	.5,.01
outs	a1,a1*0
endin

instr	percussion4
a1	tambourine	.5,.01
outs	a1*0,a1
endin

instr	percussion5
a1	stix	.5,.1
outs	a1*0,a1
endin

instr	water
a1	dripwater	.5,.09,10,.9
;random pan
kpan	=	birnd(1)
al,ar	pan2	a1,kpan,2
outs	al,ar
endin
</CsInstruments>
<CsScore>

i1	0	60

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
