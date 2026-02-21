<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.10.4_mode.csd


instr 1
;eccitatore ad impulsi
krnd	randomi	.01,.2,1000
aecc	mpulse	3,krnd

;risonatore
;p5	=	damping
imode	=	3	;inizia  la fase di inizializzazione con un valore casuale
kfreq1	randomh	500,8000,2,imode
kfreq2	randomh	100,7000,3,imode
amode1	mode	aecc,kfreq1,p5
amode2	mode	aecc,kfreq2,p5
amode	=	amode1+amode2

;uscita
aout	balance	amode,aecc 
aout	=	aout*p4

;random pan
kpan	randi	1,1,-1
al,ar	pan2	aout,kpan,2

outs	al,ar
endin
</CsInstruments>
<CsScore>
i1	0	20	15000	1000
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
