<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr	123
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
kenv	envlpx	iamp, iatk, idur, irel, iatkfun, .7, .01
klfo	oscil	imodpth, imodfrq, imodfun	
asig    oscil	klfo, ifrq, ifun
       	out  	asig*kenv
		endin

</CsInstruments>
<CsScore>
;Function  1 uses the GEN10 subroutine to compute a sine wave
;Function  2 uses the GEN10 subroutine to compute the first sixteen partials of a sawtooth wave
;Function  8 uses the GEN05 subroutine to compute an exponential ADSR envelope function
;Function  9 uses the GEN05 subroutine to compute an exponential Attack for use with envlpx
;Function 10 uses the GEN05 subroutine to compute an exponential Attack for use with envlpx
;Function 11 uses the GEN01 subroutine to read in an AIF audio file "piano.aif"
;Function 12 uses the GEN01 subroutine to read in an AIF audio file "marimba.aif"
;Function 13 uses the GEN01 subroutine to read in an AIF audio file "brass.aif.aif"
;Function 14 uses the GEN01 subroutine to read in an AIF audio file "violin.aif"
;Function 15 uses the GEN05 subroutine to compute an exponential ADSR envelope function
;Function 16 uses the GEN07 subroutine to compute a linear triangle function for AM
;Function 17 uses the GEN07 subroutine to compute a square function for AM

f1  0 4096 10   1    
f2  0 4096 10   1  .5 .333 .25 .2 .166 .142 .125 .111 .1 .09 .083 .076 .071 .066 .062
f5  0 0    1   "hellorcb.aif" 	0 	4 	0 
f8  0 1024 5   .01  32  1   288   .8   512  .7   192  .01
f9  0 513  5    .001 128 .8  128 .6  256  1
f10 0 513  5   .01  64   1   64   .5   64  .99  64   .6  64  .98  64  .7  64 .97  32  .8  32 1
f11 0 0   -1   "piano.aif" 0 4 0
f12 0 0   -1   "marimba.aif" 0 4 0
f13 0 0   -1   "brass.aif" 0 4 0
f14 0 0   -1   "violin.aif" 0 4 0
f15 0 512  5    1   64  .7   136  .65    312  .001
f16	0 513	7	0	256	1	256		0	 
f17	0 513	7	0	10  1  246	1	10   0  246    0	
f18	0 513	7	0	10  1  502 0

;ins	strt	dur amp	frq     fn	atk	rel	atkfun	modpth	modfrq	modfun
;============================================================================
i 123   	0      2	80	8.09	2	.01	.01  9		1		4		16
i 123   	3      2	80	8.07	2	.01	.01  9		1		4		17
i 123   	6      10	80	8.05	2	.01	.01  9		1		3		16
i 123   	8      8	80	8.00	2	.01	.01  9		1		4		18
i 123   	10      6	80	7.09	2	.01	.01  9		1		5		17
i 123   	12      4	80	6.05	2	.01	.01  9		1		2		18
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>16</width>
 <height>25</height>
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
