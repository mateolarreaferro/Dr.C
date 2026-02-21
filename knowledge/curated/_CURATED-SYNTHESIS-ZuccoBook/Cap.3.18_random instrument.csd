<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.18_random instrument

0dbfs = 1

instr	1
a1	vco2	.5,220,0,.8	;sawtooth
outs	a1,a1
endin

instr	2
a1	bamboo	.5,0	;modello di bamboo
outs	a1,a1
endin

instr	3
a1	buzz	.5,440,8,1	;serie di armoniche sinusoidali
outs	a1,a1
endin

instr	4
a1	foscil	.5,220,400,200,2,1	;sintesi fm
outs	a1,a1
endin

instr	5
k1	randomi	260,550,3
a1	fof	.5,220,k1,0,50,0.003,0.02,0.007,100,1,2,p3	;sintesi per formanti
outs	a1,a1
endin

instr	6
a1	soundin	"sample1.wav"	;sample player
outs	a1,a1
endin

instr	7
axcite	oscil	1, 1, 1
a1	wgpluck	440,.5,0.3,0,10,2000,axcite	;modello di corda pizzicata
outs	a1,a1
endin

instr	8
a1	rand	.5	;rumore bianco
outs	a1,a1
endin

instr	9
ktrigger	=	1	;zero bypassa,1 attiva
kinsnum	=	rnd(7)	;suona lo strumento numero....
kwhen	=	0	;p2,inizio dell'evento
kdur	=	.1	;per la durata di .3
schedwhen	ktrigger,kinsnum+1,kwhen,kdur
endin


</CsInstruments>
<CsScore>
f1	0	16384	10	1 
f2	0	16384	19	0.5	0.5	270	0.5

r	100
i9	0 	.1

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
