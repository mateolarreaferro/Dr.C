<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
kenv	linen	.5,p3/2,p3,p3/2	;envelope (amp ranges 0 to .5)
a1	oscil	kenv,ifrq,1		;sinusoid (oscillates between -.5 and .5)

;waveshaping

a2	table	a1,2,1,.5 	;a1=input signal
				;2=waveshaper table number
				;1= index mode (normalized)
				;.5 offset added to the input signal
a2	=	a2 * iamp

;beside using alternated coefficient signs, as suggested in the text,
;to avoid the DC offset we can also use a highpass filter, such that
;the DC component is eliminated (or attenuated) at the beginning and at the 
;ending of the note - to that aim, cancel the semicolon in the following 
;line and use aout as the ouput signal, not a2.

;aout	atone	a2, 30

	out	a2	 
	endin
 

</CsInstruments>
<CsScore>
;dnl.sco
f1 0 4096 10 1
;EXAMPLE 1: first 5 harmonics have the same amplitude
;             xmin/xmax xamp   coefficients
f2 0 4096 13 	1 	1 	0 1 1 1 1 1
i1	0	3	80	7
;EXAMPLE 2:
;to attenuate the DC offset, use alternated, positive and negative, signs:
f2 3 4096 13 	1 	1 	0 1 -1 -1 1 1
i1 	3	3	80	7
;EXAMPLE 3: odd harmonics only, resuling in a square wave
;(graphically this is not a square wave, as the harmonics are not in phase) 
f2 6 4096 13  1 1 	0 1 0 .33 0 .2 0 .14 0 .11 0 .09 0 .0769 0 .067 0 .0588
i1 6 3 80 7

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
