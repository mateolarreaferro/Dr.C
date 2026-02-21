<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	412				
k1		line	.5, p3, 1			; GENERATE AN ENVELOPE
a1		oscil	32000, 440/k1, 1	; APPLY IT ON AN OSCILATOR
		out		a1					; AND PLAY THE RESULT
		endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1

i 412 0 5
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1289</x>
 <y>61</y>
 <width>396</width>
 <height>645</height>
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
