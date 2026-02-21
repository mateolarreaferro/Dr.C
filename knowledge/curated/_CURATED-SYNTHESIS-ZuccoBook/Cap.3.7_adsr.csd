<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.7_adsr

0dbfs = 1

instr	1

iattac	=	p6	;attack
idec	=	p7	;decay
isust	=	p8	;sustain
irel	=	p9	;release

kadsr 	adsr	iattac,idec,isust,irel
kamp	=	p4	;ampiezza
kpitch	=	cpspch(p5)	;pitch
a1	vco2	kamp*kadsr,kpitch,0,.9	;vco

out	a1
endin

</CsInstruments>
<CsScore>

i1	0	2	.6	8.00	1	.4	.06	.0001
i1	0	2	.6	7.00	1	.4	.06	.0001
i1	3	2	.6	8.03	.1	.9	.02	.0001
i1	3	2	.6	7.03	.1	.9	.02	.0001
i1	6	2	.6	8.06	1	.01	.1	.0001
i1	6	2	.6	7.06	1	.01	.1	.0001

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
