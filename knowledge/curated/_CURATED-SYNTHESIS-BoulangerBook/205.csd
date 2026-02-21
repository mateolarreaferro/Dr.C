<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	205						
ksweep	linseg	0, p3*.5, .49, p3*.5, 0	; INDEX SWEEP FUNCTION
aindex	oscili	ksweep, p5, 2		; SOUND TO WAVESHAPE
atable	tablei	aindex, 26, 1, .5	; WAVESHAPE aindex
knorm	tablei	ksweep*2, 27, 1		; MAKE NORMALIZATION Fn
kenv	linen	p4, .01, p3, .02	; AMPLITUDE ENVELOPE
		out		atable*knorm*kenv	; NORMALIZE AND IMPOSE ENV
		endin

</CsInstruments>
<CsScore>
;8192 POINT SINE
f   02  0   8192    10  1
;WAVESHAPING FUNCTION
f   26  0   1025    7   -1 256 -1 513 1 256 1   
;AMP NORMALIZING FUNCTION
f   27  0   513     4   26 1

i   205 0   3   20000   440
i   205 4   .   .       220 
i   205 8   .   .       110
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
