<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


garvb	init	0

		instr   143 ; bending strings with envelope pan
idur	=		p3
iamp	=		ampdb(p4)
ifrq1	=		cpspch(p5)
ifrq2	=		cpspch(p6)
itim1	=		p7
itim2	=		p8
ipnv1	=		p9
ipnv2	=		p10
irvbsnd	=		p11
kenv    linen	iamp, .01, idur, .01
kfrq	linseg  ifrq1, itim1, ifrq2, itim2, ifrq1
kpaneg	expseg	ipnv1, itim1, ipnv2, itim2, ipnv1		
asig 	pluck 	kenv, kfrq, ifrq1, 0, 1
kpan	=		sqrt(kpaneg)
		outs 	asig*kpan, asig*(1-kpan)
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



;		st	dur	rvbtim	hfroll	
;===================================================================
i 199 0  12  1   .3

;	strt	dur amp     frq1	frq2  tim1	tim2  panv1	panv2	rvbsnd
;============================================================================
i 143 0     1.2	80		8.09	8.04	.3  	.9		1		.01		.01
i 143 1     1.1	82		8.08	9.03	.4  	.7		.01		1		.02
i 143 2     1.3	84		8.10	9.06	1  		.3		1		.4		.03
i 143 3     .9		78		8.10	10.03	.89 	.01		.2		1		.04
i 143 3.5   1		71		7.09	7.06	.02  	.78		.9		.3		.05
i 143 4.01  .7		71		7.092	7.075	.5  	.2		.2		1		.06
i 143 4.5 	 .6		76		9.08	8.01	.2  	.4		.01		.8		.07
i 143 5     .5		84		8.00	8.07	.04  	.46		.7		.5		.08
i 143 5.2	 .8		85		7.01	10.11	.1  	.7		1		.01		.09
i 143 5.9	 .3		75		9.11	5.11	.05 	.25		.1		.7		.1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
 <height>180</height>
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
