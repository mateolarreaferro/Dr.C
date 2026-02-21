<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


garvb	init	0

		instr	142   ; lfo equalpower pan - am pulser
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
ifun	=		p6
iatk	=		p7
irel	=		p8
iatkfun	=		p9
imodpth	=		p10
imodfrq	=		p11
imodfun	=		p12
ipanfrq	=		p13	
irvbsnd	=		p14			
kenv	envlpx	iamp, iatk, idur, irel, iatkfun, .7, .01
kpan	oscil	.5, ipanfrq, 1
klfo	oscil	imodpth, imodfrq, imodfun	
asig    oscil	klfo*kenv, ifrq, ifun
kpanlfo	=		sqrt(kpan+.5)
       	outs  	asig*kpanlfo, asig*(1-kpanlfo)
garvb	=		garvb+(asig*irvbsnd)
		endin
		
		instr 	199
idur	=		p3					
irvbtim	=		p4
ihiatn	=		p5
arvb	nreverb	garvb, irvbtim, ihiatn
		outs		arvb, arvb
garvb	=		0
		endin



</CsInstruments>
<CsScore>
f 1  0 4096 10   1    
f 2  0 4096 10   1  .5 .333 .25 .2 .166 .142 .125 .111 .1 .09 .083 .076 .071 .066 .062
f 3  0 4097 20   2  1
f 9  0 513  5    .001 128 .8  128 .6  256  1
f 16	0 513	7	0	256	1	256		0	 
f 17	0 513	7	0	10  1  246	1	10   0  246    0	
f 18	0 513	7	0	10  1  502 0


f 5  0 0    1   "hellorcb.aif" 	0 	4 	0 

;		st	dur	rvbtim	hfroll	
;===================================================================
i 199	0	18	2	.8
;ins	strt	dur amp	frq     fn	atk	rel	atkfun	modpth	modfrq	modfun	panfrq	rvbsnd
;============================================================================
i 142   	0      6	80	8.09	2	.01	.01  9		1		4		17		1	.3
i 142   	6      6	78	7.09	2	.01	.01  9		1		8		17		.5	.2
i 142   	12      6	77	7.09	2	.01	.01  9		1		12		17		.25	.1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
 <height>120</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
