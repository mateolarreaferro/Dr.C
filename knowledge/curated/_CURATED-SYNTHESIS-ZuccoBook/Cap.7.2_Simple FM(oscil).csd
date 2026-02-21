<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.7.2_Simple Fm(oscil)

0dbfs = 1

instr 1

icps	=	p5	;frequenza osc portante
kindx	linseg	0,p3/2,p7,p3/2,0	;inviluppo indice di modulazione
amodulator	poscil	kindx*p6,p6,1	;oscillatore modulante
acar	poscil	p4,icps+amodulator,1	;oscillatore portante modulato
aenv	adsr	0.5,0,1,0.5	;inviluppo per il segnale in uscita
out	acar*aenv

endin 
</CsInstruments>
<CsScore>
f1	0	4096	10	1
;p4 = amp
;p5 = freq car
;p6 = freq mod
;p7 = indice di modulazione

i1	0	4	.6	140	200	1
i1	5	4	.6	140	200	10
i1	10	4	.6	140	200	20
i1	15	4	.6	140	200	40
i1	20	4	.6	140	200	80
i1	25	4	.6	140	200	120
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
