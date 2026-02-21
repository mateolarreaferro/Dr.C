<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.1_simple additive

0dbfs = 1
instr	1

iamp	=	p4	;ampiezza
ibasefreq	=	p5	;frequenza base

;otto oscillatori 
a1	poscil	iamp*2,ibasefreq,1	;frequenza fondamentale
a2	poscil	iamp*.9,ibasefreq*1.2,1
a3	poscil	iamp*.8,ibasefreq*1.4,1
a4	poscil	iamp*.7,ibasefreq*1.6,1
a5	poscil	iamp*.6,ibasefreq*1.8,1
a6	poscil	iamp*.5,ibasefreq*2,1
a7	poscil	iamp*.4,ibasefreq*2.2,1
a8	poscil	iamp*.3,ibasefreq*2.4,1


aout	sum	a1,a2,a3,a4,a5,a6,a7,a8 ;somma degli oscillatori
aout	=	aout/8
kenv	mxadsr	1,.5,.8,.8

outs	aout*kenv,aout*kenv ;uscita con inviluppo

endin

</CsInstruments>
<CsScore>
f1	0	16384	10	1

i1	0	10	.6	220
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
