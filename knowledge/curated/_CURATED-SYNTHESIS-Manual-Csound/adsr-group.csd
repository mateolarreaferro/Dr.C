<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; by Menno Knevel - 2021

0dbfs  = 1

; both amplitude and filter use same ADSR curves 
instr 1		 	 
kenv	adsr	.01, .5, .5, p4    	; linear envelope 
asig	vco2	kenv, 110			; A+D+S+R = p3 	
asig	rezzy	asig, 500+(kenv*1000), 10	; same curve but scaled 
		outs	asig, asig	 
endin

instr 2	; midi behavior	 	 	 
kenv	madsr	.01, .5, .5, p4		; linear envelope
asig	vco2	kenv, 110			; A+D+S = p3, then go into Release stage 		
asig	rezzy	asig, 500+(kenv*1000), 10	; same curve but scaled  
		outs	asig, asig			
endin

instr 3 	 	 
kenv	xadsr	.01, .5 , .5, p4    ; exponential envelope
asig	vco2	kenv, 110			; A+D+S+R = p3 	 
asig	rezzy	asig, 500+(kenv*1000), 10	; same curve but scaled 
		outs	asig, asig
endin

instr 4	; midi behavior 	 
kenv	mxadsr	.01, .5 , .5, p4	; exponential envelope
asig	vco2	kenv, 110			; A+D+S = p3, then go into Release stage 	 
asig	rezzy	asig, 500+(kenv*1000), 10	; same curve but scaled 
		outs	asig, asig			
endin

</CsInstruments>
<CsScore>
s
i1 1 2 .01	; same notes for everyone!
i1 5 . .5
i1 9 . 1.5
s
i2 1 2 .01
i2 5 . .5
i2 9 . 1.5
s
i3 1 2 .01
i3 5 . .5
i3 9 . 1.5
s
i4 1 2 .01
i4 5 . .5
i4 9 . 1.5
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
