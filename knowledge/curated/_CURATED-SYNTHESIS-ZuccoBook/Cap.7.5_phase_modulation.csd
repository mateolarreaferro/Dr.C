<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.7.5_phase_modulation

0dbfs = 1

instr	1  

icar	=	p5	;freq carrier
iamp	=	p4	;ampiezza	
kmodfreq	linseg	p6/2,p3/2,p6,p3/2,p6/2	;freq modulazione
kindex	linseg	0,p3/2,p7,p3/2,0	;indice di modulazione
kfeedback	=	p8	;feedback
amod	oscili	kindex,kmodfreq,1	;oscillatore modulante
aphase	phasor	icar	;generatore di frequenza per tablei
acarrier	init	0	;inizializzo il carrier per il feedback
acarrier	tablei	aphase+amod+(acarrier*kfeedback),1,1,0,1	;car+mod+feedbk
kenv	adsr	0.01,.9,1,0.6	;inviluppo d'ampiezza
out	(acarrier*iamp)*kenv	;uscita audio

endin


</CsInstruments>
<CsScore>
f1	0	16384	10	1
;p4	=	ampiezza
;p5	=	carrier
;p6	=	modulation
;p7	=	indice di modulazione
;p8	=	feedback               

i1	0	4	.6	440	100	2	0
s
i1	0	4	.6	440	440	6	.1
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
