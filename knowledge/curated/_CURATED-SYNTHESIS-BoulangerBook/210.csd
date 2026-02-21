<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; p4 	= 		amp 
; p5-6 	= 		xtrans: init-final 
; p7-8 	= 		xoscil amp:	init-final 
; p9-10	=		xoscil freq: init-final
; p11	=		x index fn
; p12-13 =		ytrans:	init-final
; p14-15 =		yoscil amp:	init-final 
; p16-17 =		yoscilfreq:	init-final 
; p18	=		y index fn
; p19	=		x plane fn table   
; p20	=		y plane fn table

		instr 	210
kenv	linen	p4,.02,p3,.02		; AMP ENVELOPE
									; X INDEX VALUES FOLLOW
kxtrans	line	p5,p3,p6			; TRANSVERSE MOVEMENT IN X PLANE
kxamp	line	p7,p3,p8			; INDEX OSCILLATOR AMPLITUDE
kxamp	=		kxamp*.5			; NORMALIZES OSCIL AMP TO INDEX TABLE
kxfreq	line	p9,p3,p10			; X PLANE INDEX OSCIL FREQUENCY
kxndx	oscili	kxamp,kxfreq,p11	; p11=X INDEX FUNCTION
									; TRY SINES, TRAINGLES, OR ASCENDING LINES FROM -1 TO +1 
									; (PHASOR) ETC FOR INDEX FUNCTION
axndx	=		frac(kxndx+1000.5+kxtrans)	; NEED FRACTIONAL VALUES
									; TO GO FROM ONE TERRAIN BOUNDARY TO THE OTHER
									; 1000.5 AVOIDS NEGATIVE VALUES AND SETS START POINT
									; AT TABLE MIDPOINT
									; Y INDEX VALUES FOLLOW
kytrans	line	p12,p3,p13			; TRANSVERSE MOVEMENT IN X PLANE
kyamp	line	p14,p3,p15			; INDEX OSCILLATOR AMPLITUDE
kyamp	=		kyamp*.5			; NORMALIZES OSCIL AMP TO INDEX TABLE
kyfreq	line	p16,p3,p17			; X PLANE INDEX OSCIL FREQUENCY
kyndx	oscili	kyamp,kyfreq,p18	; p11=X INDEX FUNCTION
									; TRY SINES, TRAINGLES, OR ASCENDING LINES FROM -1 TO +1 
									; (PHASOR) ETC FOR INDEX FUNCTION
ayndx	=		frac(kyndx+1000.5+kytrans)	; NEED FRACTIONAL VALUES
									; TO GO FROM ONE TERRAIN BOUNDARY TO THE OTHER
									; 1000.5 AVOIDS NEGATIVE VALUES AND SETS START POINT
									; AT TABLE MIDPOINT
ax		tablei	axndx,p19,1,0,0		; NORMALIZED (-1 TO +1) AUDIO FOR X PLANE
ay		tablei	ayndx,p20,1,0,0		; NORMALIZED (-1 TO +1) AUDIO FOR Y PLANE
az		=		(ax*ay)*kenv		; TRACKS Z PLANE TO GENERATE TERRAIN WAVEFORM
		out		az
		endin		


</CsInstruments>
<CsScore>
f 02    0   8193    10  1           ;SINE
f 03    0   8193    7   -1 8192 1   ;PHASOR FROM -1 TO +1
f 10    0   8193    10  0   0   1 
f 61    0   8193    10  0   0   1
f 62    0   8193    10  1   .43 0 .25 .33 .11 0 .75
f 63    0   8193    9   1   1   0 1.5 1 0
f 64    0   8193    9   3   1   0 3.5 1 0

;p4     =   amp 
;p5-6   =   xtrans: init-final 
;p7-8   =   xoscil amp: init-final 
;p9-10  =   xoscil freq: init-final
;p11    =   x index fn
;p12-13 =   ytrans: init-final
;p14-15 =   yoscil amp: init-final 
;p16-17 =   yoscilfreq: init-final 
;p18    =   y index fn
;p19    =   x plane fn table   
;p20    =   y plane fn table

;				amp	xtrs i-f xosc i-f xoscfq fn 

i 210 0     5 20000 -.5 .5   .1 .1 440 440 3   0  0  1  1 440 440 3 2 2     
i 210 6     5 20000   0  0    1  1 440 440 3 -.5 .5 .1 .1 440 440 3 2 2     
s
i 210 0     5 20000 -.5   .5 .1 10 110 110 3   0  3  3  1 110 110 3 2 2     
i 210 6     5 20000 .25 -.25  3 1  110 110 3 -.5 .5 .1 10 110 110 3 2 2     
s
i 210 0     5 20000 -.5 .5   .1 .1 440 440 3   0  0  1  1 440 440 3 2 61    
i 210 6     5 20000   0  0    1  1 440 440 3 -.5 .5 .1 .1 440 440 3 2 61    
s
i 210 0     5 20000 -.5   .5 .1 10 110 110 3   0  3  3  1 110 110 3 2 61    
i 210 6     5 20000 .25 -.25  3 1  110 110 3 -.5 .5 .1 10 110 110 3 2 61    
s
i 210 0     5 20000 -.5 .5   .1 .1 440 440 3   0  0  1  1 440 440 3 62 10   
i 210 6     5 20000   0  0    1  1 440 440 3 -.5 .5 .1 .1 440 440 3 62 10   
s
i 210 0     5 20000 -.5   .5 .1 10 110 110 3   0  3  3  1 110 110 3 62 10   
i 210 6     5 20000 .25 -.25  3 1  110 110 3 -.5 .5 .1 10 110 110 3 62 10   
s
i 210 0     5 20000 -.5 .5   .1 .1 440 440 3   0  0  1  1 440 440 3 63 64   
i 210 6     5 20000   0  0    1  1 440 440 3 -.5 .5 .1 .1 440 440 3 63 64   
s
i 210 0     5 20000 -.5   .5 .1 10 110 110 3   0  3  3  1 110 110 3 63 64   
i 210 6     5 20000 .25 -.25  3 1  110 110 3 -.5 .5 .1 10 110 110 3 63 64
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
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
