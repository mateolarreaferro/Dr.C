<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.2_simple_additive_table

instr	1

iamp	=	p4	;ampiezza
ibasefreq	=	p5	;frequenza base
iamptab	=	p6	;tabella ampiezze
ipartial	=	p7	;tabella parziali


;tabella delle parziali
ifreqtable1	table	1,ipartial
ifreqtable2	table	2,ipartial
ifreqtable3	table	3,ipartial
ifreqtable4	table	4,ipartial
ifreqtable5	table	5,ipartial
ifreqtable6	table	6,ipartial
ifreqtable7	table	7,ipartial

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
a2	poscil	iamp*iamptable1,ibasefreq*ifreqtable1,1
a3	poscil	iamp*iamptable2,ibasefreq*ifreqtable2,1
a4	poscil	iamp*iamptable3,ibasefreq*ifreqtable3,1
a5	poscil	iamp*iamptable4,ibasefreq*ifreqtable4,1
a6	poscil	iamp*iamptable5,ibasefreq*ifreqtable5,1
a7	poscil	iamp*iamptable6,ibasefreq*ifreqtable6,1
a8	poscil	iamp*iamptable7,ibasefreq*ifreqtable7,1


aout	sum	a1,a2,a3,a4,a5,a6,a7,a8 ;somma degli oscillatori
aout	=	aout/8
kenv	mxadsr	1,.5,.8,.2

outs	aout*kenv,aout*kenv ;uscita con inviluppo

endin

</CsInstruments>
<CsScore>
f1	0	16384	10	1
f3	0	-7	-2	1	.9	.8	.7	.6	.5	.4	.3	;ampiezze 

f2	0	-7	-2	1	1.1	1.2	1.3	1.4	1.5	1.6	1.7	;parziali
f4	0	-7	-2	1	1	2	3	4	5	6	7	
f5	0	-7	-2	1	1.2	1.4	1.6	1.8	2	2.4	2.6	
f6	0	-7	-2	1	2	4	5	7	8	10	11	
f7	0	-7	-2	1	1.3	1.5	1.7	1.9	2.11	3.13	4.15	

i1	0	4	.5	220	3	2
s
i1	0	4	.5	220	3	4
s
i1	0	4	.5	220	3	5
s
i1	0	4	.5	220	3	6
s
i1	0	4	.5	220	3	7
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
