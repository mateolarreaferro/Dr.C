<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr   122
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
ifun	=		p6
iatk	=		p7
irel	=		p8
iatkfun	=		p9				
index1	=		p10
index2	=		p11
kenv	envlpx	iamp, iatk, idur, irel, iatkfun, .7, .01
kmodswp	expon	index1, idur, index2
kbuzswp expon   20, idur, 1
asig3   foscil 	kenv, ifrq, 1, 1, kmodswp, ifun
asig2   buzz   	kenv, ifrq*.99, kbuzswp+1, ifun
asig1 	pluck 	iamp, ifrq*.5, ifrq, 0, 1
amix	=		asig1+asig2+asig3	
		out     amix
		dispfft	amix, .25, 1024
		endin

</CsInstruments>
<CsScore>
;Function  1 uses the GEN10 subroutine to compute a sine wave
;Function  9 uses the GEN05 subroutine to compute an exponential Attack for use with envlpx
;Function 10 uses the GEN05 subroutine to compute an exponential Attack for use with envlpx

f 1  0 4096 10   1    
f 9  0 513  5    .001 128 .8  128 .6  256  1
f 10 0 513  5   .01  64   1   64   .5   64  .99  64   .6  64  .98  64  .7  64 .97  32  .8  32 1

;ins	st 	dur amp	frq		fun	atk	rel	atkfun indx1 indx2	
;========================================================
i 122	0	 4	70	7.09	 1 .01	.2	10	 1 		30		
i 122	4.5 5	70	7.00	 1  1	.1	9	 10 	60	
i 122	10	10	70	5.09	 1  3	 2	10	 60 	3		
i 122	13	 7	66	7.04	 1  .5	 1	9	 3 		100	

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>8</height>
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
