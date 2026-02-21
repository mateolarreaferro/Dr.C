<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr	120
		
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
ifun	=		p6
iatk	=		p7
irel	=		p8
iatkfun	=		p9				
kenv	envlpx	iamp, iatk, idur, irel, iatkfun, .7, .01
asig3   oscil	kenv, ifrq*.99, ifun
asig2   oscil	kenv, ifrq*1.01, ifun
asig1   oscil	kenv, ifrq, ifun
amix	=		asig1+asig2+asig3
       	out  	amix
       	display	kenv, p3
		endin

</CsInstruments>
<CsScore>
;Function  2 uses the GEN10 subroutine to compute the first sixteen partials of a sawtooth wave
;Function  9 uses the GEN05 subroutine to compute an exponential Attack for use with envlpx
;Function 10 uses the GEN05 subroutine to compute an exponential Attack for use with envlpx

f 2  0 4096 10   1  .5 .333 .25 .2 .166 .142 .125 .111 .1 .09 .083 .076 .071 .066 .062
f 9  0 513  5    .001 128 .8  128 .6  256  1
f 10 0 513  5   .01  64   1   64   .5   64  .99  64   .6  64  .98  64  .7  64 .97  32  .8  32 1

;ins	strt	   dur amp     frq     fn  atk	rel	atkfn
;==================================================
i 120		0		2	80	    6.09	2   .5	1	9
i 120		2		2	81	    6.08	2   .5	1	10
i 120		4		2	80	    6.06	2   .5	1	9
i 120		6		2	79	    6.04	2   .5	1	10
i 120		8		5	75	    5.09	2   .5	1	9
i 120		8.2		5	74	    6.04	2   .5	1	10
i 120		8.4		5	70	    7.01	2   .5	1	9
i 120		8.6		5	68	    8.09	2   .5	1	10
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>384</width>
 <height>150</height>
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
