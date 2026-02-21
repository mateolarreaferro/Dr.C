<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.9_statevar filter(nogui)

0dbfs = 1

instr 1

a1	rand	1
kcutoff	randomi	100,10000,2
kQ	=	p4
iosamps	=	20	;oversampling del processamento
				;,aumenta la componente acuta di Q
ahp,alp,abp,abr	statevar	a1,kcutoff,kQ,iosamps

kselect	=	p5	;sceglie il tipo di filtro
if	kselect	=	1	then
aout	=	ahp
elseif	kselect	=	2	then
aout	=	alp
elseif	kselect	=	3	then
aout	=	abp
elseif	kselect	=	4	then
aout	=	abr
elseif	kselect	=	5	then
aout	=	ahp+alp
elseif	kselect	=	6	then
aout	=	abp+abr
elseif	kselect	=	7	then
aout	=	abp+abr+ahp
elseif	kselect	=	8	then
aout	=	abp+abr+ahp+alp
endif

aclip	clip	aout,0,.9

out	aclip

endin	

</CsInstruments>
<CsScore>
i1	0	10	.1	1	;hp
s
i1	0	10	.2	2	;lp
s
i1	0	10	.3	3	;bp
s
i1	0	10	.4	4	;br
s
i1	0	10	.5	5	;hp+lp
s
i1	0	10	.6	6	;bp+br
s
i1	0	10	.7	7	;bp+br+hp
s
i1	0	10	.8	8	;4 filtri
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
