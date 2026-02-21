<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


garvb	init	0

		instr   140 		; dual mono - buzz + plk
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
iatkl	=		p6
irell	=		p7
ihrm1r	=		p8
ihrm2r	=		p9
irvbsnd	=		p10
kenvl	linen	1, .001, idur, .1
kenvr	linen   iamp, iatkl, idur, irell
khrmr   line  	ihrm1r, idur, ihrm2r	
asigl	pluck   iamp*kenvl, ifrq, ifrq, 2, 1
asigr	buzz   	kenvr, ifrq, khrmr+1, 1
        outs    asigl, asigr
garvb	=		garvb+((asigl+asigr)*irvbsnd)
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
i 199	0		11.1	1.1		.1

;	st	dur amp frq   atkl rell		hrm1l	hrm2l  rvbsnd
;============================================================================
i 140  0	1	80	6.09  .01   .2  	20		3		.2
i 140  +	.	78	6.08  .01   .2  	10		1		.1
i 140  .	.	73	6.07  .01   .2  	40		6		.2
i 140  .	.	70	6.06  .01   .2  	15		8		.1
i 140  .	.	72	6.07  .01   .2  	9		3		.2
i 140  .	.	74	6.08  .01   .2  	12		2		.1
i 140  .	.	78	6.09  .01   .2  	16		3		.2
i 140  .	1.5	80	5.09  .01   .2  	50		10		.4
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
