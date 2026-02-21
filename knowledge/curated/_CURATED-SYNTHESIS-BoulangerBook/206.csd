<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 206		
iwshpfn	=		p6	
inrmfn	=		p7	
kswp	linseg	0, p3*.5, .49, p3*.5, 0	; INDEX SWEEP FUNCTION
aindex	oscili	kswp, p5, 2				; SOUND TO WAVESHAPE
atable	tablei	aindex, iwshpfn, 1, .5	; WAVESHAPE aindex
knrm	tablei	kswp*2, inrmfn, 1		; MAKE NORMALIZATION FUNCTION
kenv	linen	p4, .01, p3, .02		; AMPLITUDE ENVELOPE
		asig	=	(atable*knrm)*kenv	; NORMALIZE AND IMPOSE ENV
		out		asig
		dispfft	asig, .1, 1024
		endin		


</CsInstruments>
<CsScore>

;8192 POINT SINE
f   02  0   8192    10  1
;WAVESHAPING FUNCTION: GEN13 - ODD HARMONICS
f   28  0   4097    13  1 1 1 0 .8 0 .5 0 .2
;AMP NORMALIZING FUNCTION
f   280 0   2049    4   28 1
;WAVESHAPING FUNCTION: GEN14 - SAME HARMONICS
f   29  0   4097    14  1 1 1 0 .8 0 .5 0 .2
;AMP NORMALIZING FUNCTION
f   290 0   2049    4   29 1
;WAVESHAPING FUNCTION: GEN14 - EVEN HARMONICS
f   30  0   4097    14  1 1 0 1 0 .6 0 .4 0 .1
;AMP NORMALIZING FUNCTION
f   301 0   2049    4   30 1
;WAVESHAPING FUNCTION: GEN 13 - OVER 20 HARMONICS
f   31  0   4097    13  1 1 1 .666 .5 .3 0 0 .3 0 .2 .25 .33 0 0 .1 0 .45 .33 .2 .1 .1 .15
;AMP NORMALIZING FUNCTION
f   310 0   2049    4   31 1
;SIGNIFICATION
f   32  0   8193    13  1 1 1 1 -1 -1 1 1 -1 -1 1 1 -1 -1 1 1 -1 -1
;AMP NORMALIZING FUNCTION
f   320 0   2049    4   32 1

i   206 0   3   20000   440 28  280 
i   206 4   .   .       .   29  290
i   206 8   .   .       .   30  301
i   206 12  .   .       .   31  310
i   206 16  .   20000   .   32  320
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>240</height>
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
