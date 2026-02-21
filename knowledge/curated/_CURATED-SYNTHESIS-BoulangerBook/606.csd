<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	606			
imodind	=		p4/20				; SCALES MOD INDEX TO 0-5
iattmod	=		1/(imodind+1)		; SCALES MOD ATT TO INDEX
kenv	linen	ampdb(p4), .1, p3, .1 ; AMP ENVELOPE
kmodenv	linen	imodind, iattmod, p3, .1 ; MOD INDEX ENV
asig	foscil	kenv, cpspch(p5), 1, 1,kmodenv, 1
		out		asig	
		endin		

</CsInstruments>
<CsScore>

;------------------------------------------------------------
f1 0 8192 10 1 ; SINE WAVE
;------------------------------------------------------------
;  ST DUR DB  PCH
;------------------------------------------------------------
i 606 0  1   80  8.00
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .    <  .
i 606 +  .   90  .
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>884</width>
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
