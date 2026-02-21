<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 701		
idur	=		abs(p3)				; NEED POSITIVE DUR FOR ENVELOPE
		ir		tival				; FIND OUT IF THIS IS A TIED NOTE
i1		=		-1					; SET OSCIL PHASE FOR A TIED NOTE
		tigoto	slur				; SKIP REINIT OF ENV ON TIED NOTES
i1		=		0					; FIRST NOTE, SO RESET OSC PHASE
katt	line	p4, idur, 0			; OVERALL ENVELOPE
slur:			
		if 		ir==0	kgoto tone	; NO SWELL IF FIRST NOTE
kslur	linseg	0, idur/2, p4, idur/2, 0 ; SIMPLE SWELL SHAPE 
katt	=		katt+kslur			; ADD SWELL TO PRIMARY ENVELOPE
tone:			
asig	oscili	katt, cpspch(p5), 1, i1	; REINIT PHASE IF FIRST NOTE
		out		asig	
		endin 		

</CsInstruments>
<CsScore>
f 1 0   1024    10  1 0.95 0.1 0.05 0.01 0.001
;(p4): HELD NOTE SETS INITIAL AMP, TIED NOTE SETS AMP OF SWELL
;INS    ST  DUR AMP PCH 
i 701   0   -3  20000   8.09    ;HELD NOTE, TAKEN OVER...
i 701   1.5 1.5 5000    9.00    ;BY SECOND, SMALL SWELL 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>1626</height>
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
