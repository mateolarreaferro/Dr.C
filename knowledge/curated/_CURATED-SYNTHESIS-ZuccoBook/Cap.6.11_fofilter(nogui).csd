<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.11_fofilter(nogui).csd

0dbfs = 1



instr	1
;additiva di parziali cosinusoidali

kcps	=	110	;frequenza
knh 	=	80	;numero di armoniche
klh 	=	1	;armonica pi˘ bassa
kmul	randomi 0,1,10	;incrementa l'ampiezza delle parziali

kvib	lfo	2,5

asig	gbuzz	.6,kcps+kvib,knh,klh,kmul,1

;fofilter
kfreq	randomi	60,2000,1
kris	=	0.007	
kdec	=	0.04
afilt	fofilter	asig,kfreq,kris,kdec

aout	clip	afilt,0,.9	;limiter

out	aout

endin


</CsInstruments>
<CsScore>
; a cosine wave
f 1 0 16384 11 1

i1	0	10
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
