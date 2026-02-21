<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.9.1 simple grain.csd

0dbfs = 1

instr	1

igrainrate	=	p4	;intervallo di tempo tra i singoli grani

play:
timout	0,igrainrate,continua  
reinit	play
continua:

ktrigger	=	1	;zero bypassa,1 attiva
kinsnum	=	2	;suona lo strumento numero 2
kwhen	=	0 	;p2,inizio dell'evento
kgrainsize	=	p5	;durata dei grani
schedwhen	ktrigger,kinsnum,kwhen,kgrainsize
endin

instr	2
k1	=	rnd(1000)	;generatore numeri casuali
a1	poscil	.4,60+k1,1	;oscillatore con frequenza random
aenv	linseg	0,0.02,1,p3-0.04,1,0.02,0,0.01,0 ;inviluppo

;random pan
kpan	=	birnd(1)
al,ar	pan2	a1,kpan,2

outs	al*aenv,ar*aenv

endin

</CsInstruments>
<CsScore>

f1	0	16384	10	1 
;p4 = rate
;p5 = grain size
i1	0	5	.9	.1
s
i1	0	5	.8	.09
s
i1	0	5	.7	.08
s
i1	0	5	.6	.07
s
i1	0	5	.2	.06
s
i1	0	5	.1	.05
s
i1	0	5	.09	.04
s
i1	0	5	.03	.04
s
i1	0	5	.02	.04
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
