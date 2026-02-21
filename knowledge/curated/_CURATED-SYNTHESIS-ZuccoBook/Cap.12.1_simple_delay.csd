<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.12.1_simple_delay

0dbfs = 1

instr	1

a1	pluck	.6,440,440,0,1	;segnale ingresso

;prima linea di ritardo
abuf1	delayr	1	;buffer memoria
adel1 	deltapi	p4	;punto da cui prelevare il segnale
afeed1	=	p6 * adel1 + a1	;numero di ripetizioni
delayw	afeed1	;scrive il segnale in ritardo

;seconda linea di ritardo
abuf2	delayr	1
adel2 	deltapi	p5
afeed2	=	p6 * adel2 + a1
delayw	afeed2    

;uscita audio stereo
kdeclick	linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0	

outs	(a1+adel1*.5)*kdeclick,(a1+adel2*.5)*kdeclick	;suono originale+delay

endin

</CsInstruments>
<CsScore>
;p4,p5 = valori di ritardo (left,right)
;p6 = feedback (0 = no feedback)

i1	0	4	.1	.2	0
s		
i1	0	4	.2	.4	.1
s	
i1	0	4	.3	.5	1
s
i1	0	4	.1	.2	.9
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
