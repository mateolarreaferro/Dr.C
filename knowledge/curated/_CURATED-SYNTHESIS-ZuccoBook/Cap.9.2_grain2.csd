<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.9.2_grain2.csd

0dbfs = 1

gisine	ftgen	1,0,8192,10,1,.6,.3	
ihanning	ftgen	2,0,8192,-20,2	;Hanning
ibarlett	ftgen	3,0,8192,-20,3	;Bartlett (Triangle)

instr	1
kcps	=	p5	;grain freq
kfmd	=	p6	;variazione random in Hz. 
kgdur	=	p7	;durata dei grani in secondi
iovrlp	=	10	;numero di grani sovrapposti
kfn	=	1	;grain waveform
iwfn1	=	2	;inviluppo a1
iwfn2	=	3	;inviluppo a2

a1	grain2	kcps,kfmd,kgdur,iovrlp,kfn,iwfn1
a2	grain2	kcps*2,kfmd,kgdur,iovrlp,kfn,iwfn2

adeclick	linseg	0,0.01,1,p3-0.05,1,0.04,0,1,0
outs	(a1*adeclick)*p4,(a2*adeclick)*p4

endin

</CsInstruments>
<CsScore>

i1	0	5	.1	220	1	1
s
i1	0	5	.1	220	20	.5
s
i1	0	5	.1	220	40	.1
s
i1	0	5	.1	220	60	.08
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
