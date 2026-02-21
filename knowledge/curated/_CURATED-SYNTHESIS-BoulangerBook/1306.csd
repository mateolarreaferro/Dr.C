<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	1306
; ar	grain	XAMP, XPITCH, XDENS, KAMPOFF, KPITCHOFF, KGDUR, IGFN, IWFN, IMGDUR
a1 		grain 	2000,    220, 1000,       0,     20000,   .05,    1,    2, 1
		out 	a1
		endin

</CsInstruments>
<CsScore>

; FOR GENERATING 10 SECONDS OF OUTPUT USING THE OPCODE GRAIN
; USING THE GEN10 SUBROUTINE TO GENERATE ONE FULL CYCLE OF
; SINE FUNCTION AS SOURCE
f 1 0 8192 10 1
;USING THE GEN20 TO GENERATE A HANNING WINDOW FOR ENVELOPE
f 2 0 1025 20 2 1
;PRODUCE 10 SECONDS OF OUTPUT
i 1306 0 10
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
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
