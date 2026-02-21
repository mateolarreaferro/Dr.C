<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.2_simple_additive_table_B

0dbfs = 1

instr	1

iamp	=	p4
ibasefreq	=	p5	;frequenza base
iamptab	=	p6	;tabella ampiezze 
ipartial	=	p7	;tabella parziali

k1	randomh	1,7,4	;indice della tabella letto in modo casuale
k2	randomh	1,7,5	;simile ad un arpeggio di armonici con rate indipendente
k3	randomh	1,7,6
k4	randomh	1,7,1
k5	randomh	1,7,.5
k6	randomh	1,7,.6
k7	randomh	1,7,.7

;tabella delle parziali
kfreqtable1	table	k1,ipartial
kfreqtable2	table	k2,ipartial
kfreqtable3	table	k3,ipartial
kfreqtable4	table	k4,ipartial
kfreqtable5	table	k5,ipartial
kfreqtable6	table	k6,ipartial
kfreqtable7	table	k7,ipartial

;tabella ampiezze
iamptable1	table	1,iamptab
iamptable2	table	2,iamptab
iamptable3	table	3,iamptab
iamptable4	table	4,iamptab
iamptable5	table	5,iamptab
iamptable6	table	6,iamptab
iamptable7	table	7,iamptab

;otto oscillatori 
a1	poscil	iamp*2,ibasefreq,1	;frequenza fondamentale
a2	poscil	iamp*iamptable1,ibasefreq*kfreqtable1,1
a3	poscil	iamp*iamptable2,ibasefreq*kfreqtable2,1
a4	poscil	iamp*iamptable3,ibasefreq*kfreqtable3,1
a5	poscil	iamp*iamptable4,ibasefreq*kfreqtable4,1
a6	poscil	iamp*iamptable5,ibasefreq*kfreqtable5,1
a7	poscil	iamp*iamptable6,ibasefreq*kfreqtable6,1
a8	poscil	iamp*iamptable7,ibasefreq*kfreqtable7,1


aout	sum	a1,a2,a3,a4,a5,a6,a7,a8 ;somma degli oscillatori
aout	=	aout/8
kenv	mxadsr	1,.5,.8,.2

outs	aout*kenv,aout*kenv ;uscita con inviluppo

endin

</CsInstruments>
<CsScore>
f1	0	16384	10	1
f3	0	-7	-2	.9	.8	.7	.6	.5	.4	.3	.2	;ampiezze parziali

f2	0	-7	-2	1	1.1	1.2	1.3	1.4	1.5	1.6	1.7	;parziali
f4	0	-7	-2	1	2	3	4	5	6	7	8
f5	0	-7	-2	1	1.2	1.4	1.6	1.8	2	2.4	2.6	
f6	0	-7	-2	1	2	4	5	7	8	10	11	
f7	0	-7	-2	1	1.3	1.5	1.7	1.9	2.11	3.13	4.15	

i1	0	10	.6	440	3	2
s
i1	0	10	.6	440	3	4
s
i1	0	10	.6	440	3	5
s
i1	0	10	.6	440	3	6
s
i1	0	10	.6	440	3	7
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
