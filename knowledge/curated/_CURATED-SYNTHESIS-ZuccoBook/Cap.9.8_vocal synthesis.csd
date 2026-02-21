<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
;Esempio Cap.9.8_vocal synthesis

0dbfs = 1

instr	1

kamp	=	p4	;ampiezza

;formanti tenore "a"
kform1	=	650
kform2	=	1080
kform3	=	2650
kform4	=	2900
kform5	=	3250

;larghezza di banda delle formanti tenore
kbn1	=	80
kbn2	=	90
kbn3	=	120
kbn4	=	130
kbn5	=	140

kfund	linseg	p5,p3/2,p6,p3/2,p5	;frequenza fondamentale

koct	=	0
;0.003,0.02,0.007 valori consigliati per la sintesi vocale
kris	=	0.003
kdur	=	0.02
kdec	=	0.007
iolaps	=	100
ifna	=	1	;funzione sinusoide
ifnb	=	2	;funzione attack,decay
idur	=	p3	;durata di fof

;vibrato con componente random
kjitter	jitter	8,1,3
kvib	lfo	2,kjitter

k1	madsr	1,0,1,0.01;inviluppo d'ampiezza

a1	fof	kamp*k1,kfund+kvib,kform1,koct,kbn1,kris,kdur,kdec,iolaps,ifna,ifnb,idur
a2	fof	kamp*k1,kfund+kvib,kform2,koct,kbn2,kris,kdur,kdec,iolaps,ifna,ifnb,idur
a3	fof	kamp*k1,kfund+kvib,kform3,koct,kbn3,kris,kdur,kdec,iolaps,ifna,ifnb,idur
a4	fof	kamp*k1,kfund+kvib,kform4,koct,kbn4,kris,kdur,kdec,iolaps,ifna,ifnb,idur
a5	fof	kamp*k1,kfund+kvib,kform5,koct,kbn5,kris,kdur,kdec,iolaps,ifna,ifnb,idur

aout	=	a1+a2+a3+a4+a5

kenv	linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0;declick

outs	(aout)*kenv,(aout)*kenv

endin

</CsInstruments>
<CsScore>
f1	0	8192	10	1 
f2	0	8192	19	0.5	0.5	270	0.5 

i1	0	.5	.3	100	300
s
i1	0	.6	.3	300	200
s
i1	0	.7	.3	300	80
s
i1	0	.9	.3	80	200
s
i1	0	1.5	.3	200	200
s
i1	0	3	.3	100	100
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
