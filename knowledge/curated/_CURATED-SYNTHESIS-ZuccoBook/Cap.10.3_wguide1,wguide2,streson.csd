<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.10.3_wguide1,wguide2,streson.csd

0dbfs  = 1 ;ampiezza costante relativa a 0 db (ampiezza massima = 1

;impulso con risonatore di piastra percossa
instr 1
krnd	randomi	.009,.1,2000
asig	mpulse	3,krnd
kfreq1	randomi	60,500,.1
kfreq2	randomi	60,500,.2
kcut1	randomi	1000,20000,.3
kcut2	randomi	1000,20000,.4	
kfeed1	=	.2	;la somma dei valori di feedback non deve superare il valore = .5
kfeed2	=	.2				
awg	wguide2	asig,kfreq1,kfreq2,kcut1,kcut2,kfeed1,kfeed2
outs	awg,awg

endin

;rumore bianco con risonatore di piastra percossa
instr 2
asig	rand	.1
kfreq1	randomi	60,10000,1
kfreq2	randomi	60,10000,2
kcut1	randomi	60,20000,3
kcut2	randomi	60,20000,4	
kfeed1	=	.2
kfeed2	=	.2				
awg	wguide2	asig,kfreq1,kfreq2,kcut1,kcut2,kfeed1,kfeed2
outs	awg,awg

endin

;impulso con waveguide composto da delay line e filtro passa-basso
instr 3
krnd	randomi	.001,.1,2000
asig	mpulse	3,krnd
kfreq	randomi	60,400,3
kcut	randomi	1000,10000,4
kfeed	=	.5				
awg	wguide1	asig,kfreq,kcut,kfeed
outs	awg,awg

endin

;rumore bianco con waveguide composto da delay line e filtro passa-basso
instr 4
asig	rand	.1
kfreq	randomi	100,1000,3
kcut	randomi	1000,10000,4
kfeed	=	.5				
awg	wguide1	asig,kfreq,kcut,kfeed
outs	awg,awg

endin

;impulso con risonatore di corda pizzicata
instr 5

krnd	randomi	.009,.1,1000
asig	mpulse	3,krnd

;pitch del risonatore generato da una tabella con scala definita
;kmelody legge la tabella(f2) in modo casuale generando una melodia
iscale	=	2
kmelody	randomi 1,22,1
kpitch	table	kmelody,iscale	;tabella con scala diatonica

ifdbgain	=	.9
astr1	streson asig,cpspch(kpitch),ifdbgain
astr2	streson asig,cpspch(kpitch)*1.4,ifdbgain
aenv    linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0
outs	astr1*aenv,astr2*aenv

endin

;file audio con risonatore di corda pizzicata
;il risultato Ë simile a sonorit‡ ottenute con l'effetto flanger o un filtro comb
instr 6

iscale	=	2
kmelody	randomi 1,22,3
kpitch	table	kmelody,iscale
asig1,asig2	diskin2	"drums_loop.aif",1,0,1
ifdbgain	=	.9
astr1	streson	asig1,cpspch(kpitch)*.9,ifdbgain
astr2	streson asig2,cpspch(kpitch)*2,ifdbgain
aenv    linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0
outs	astr1*aenv,astr2*aenv

endin

</CsInstruments>
<CsScore>
f2 0 32 -2  6.07 6.09 6.11 7.00 7.02 7.04 7.06 
              7.07 7.09 7.11 8.00 8.02 8.04 8.06 
              8.07 8.09 8.11 9.00 9.02 9.04 9.06 
              10.07 10.09 10.11 11.00 11.02 11.04 11.06 

i1	0	10
s
i2	0	10
s
i3	0	10
s 
i4	0	10
s 	
i5	0	10
s 
i6	0	10
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
