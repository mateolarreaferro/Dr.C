<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.7.6_4phasemod

0dbfs = 1



instr 1  ;Phase modulation instrument with 4 operators

icarfreq	=	p5
iamp	=	p4

acar	init	0	;init car1 per feedback
acar2	init	0	;init car2 per feedback
acar3	init	0	;init car3 per feedback
acar4	init	0	;init car4 per feedback

kfeed	randomi	0,p6,2	;feedback	

;modulanti
kmodfreq	=	p7	;mod. freq. 
kmodfreq2	=	p8
kmodfreq3	=	p9
kmodfreq4	=	p10
;indice di modulazione
kindex	=	p11	
kindex2	=	p12
kindex3	=	p13
kindex4	=	p14

;operatori

;OP1
kenvindex	adsr	1,.2,.7,.2
amodulator	oscili	kindex*kenvindex,kmodfreq*icarfreq,1
aphase	phasor	icarfreq
acar	tablei	aphase+amodulator+(acar*kfeed),1,1,0,1

;OP2
kenvindex2	adsr	.01,.4,.7,.6
amodulator2	oscili	kindex2*kenvindex2,kmodfreq2*icarfreq,1
aphase	phasor	icarfreq
acar2	tablei	aphase+amodulator2+(acar2*kfeed),1,1,0,1

;OP3
kenvindex3	adsr	1,.2,.9,1
amodulator3	oscili	kindex3*kenvindex3,kmodfreq3*icarfreq,1
aphase	phasor	icarfreq
acar3	tablei	aphase+amodulator3+(acar3*kfeed),1,1,0,1

;OP4
kenvindex4	adsr	0.4,.2,1,1
amodulator4	oscili	kindex4*kenvindex4,kmodfreq4*icarfreq,1
aphase	phasor	icarfreq
acar4	tablei	aphase+amodulator4+(acar4*kfeed),1,1,0,1

kalgo	=	p15	;sceglie l'algoritmo

;Algorithm1	(OP1)
if	kalgo	=	1	then	;se kalgo = 1 seleziona una combinazione di operatori
aout	=	acar
;Algorithm2	(OP1+OP2)
elseif	kalgo	=	2	then
aout	=	(acar+acar2)/2
;Algorithm3	(OP1+OP3)
elseif	kalgo	=	3	then
aout	=	(acar+acar3)/2
;Algorithm4	(OP1+OP4)
elseif	kalgo	=	4	then
aout	=	(acar+acar4)/2
;Algorithm5	(OP1+OP2+OP3)
elseif	kalgo	=	5	then
aout	=	(acar+acar2+acar3)/3
;Algorithm6	(OP2+OP3+OP4)
elseif	kalgo	=	6	then
aout	=	(acar2+acar3+acar4)/3
;Algorithm7	(OP1+OP2+OP3+OP4)
elseif	kalgo	=	7	then
aout	=	(acar+acar2+acar3+acar4)/4
endif
;random	pan
krndpan	randomi	0,1,4
aR,aL	pan2	aout*iamp,krndpan
kenvamp	adsr	1,1,.2,1	
outs	aR*kenvamp,aL*kenvamp
endin


</CsInstruments>
<CsScore>
;p4	=	amp
;p5	=	freq
;p6	=	feedback
;p7,p8,p9,p10	= modulante
;p11,p12,p13,p14 = indice di modulazione 
;p15	=	sceglie l'algoritmo
	
f1	0	16384	10	1 
; a linear rising envelope
f2	0	129	-7	0	128	1

           
i1	0	5	.8	110	.09	1	2	.1	.2	.1	.2	.3	.4	1
s

i1	0	5	.8	110	.09	1	2	.1	.2	1.1	1.2	1.3	1.4	2
s

i1	0	5	.8	110	.09	2	4	6	8	1.1	1.2	1.3	1.4	3
s

i1	0	5	.8	110	.09	9	8	7	6	2	2	2	2	7
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
