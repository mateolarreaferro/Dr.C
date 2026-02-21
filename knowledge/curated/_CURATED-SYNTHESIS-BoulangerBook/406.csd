<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	406		
k1		line	0, p3, 1			; GENERATE AN ENVELOPE SCALED BETWEEN 0 AND 1
a1		oscil	15000*k1, 440, 1	; SCALE IT AND APPLY IT ON AN OSCILATOR
		out		a1					; AND PLAY THE RESULT
		endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1
i 406 0 10
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1323</x>
 <y>61</y>
 <width>396</width>
 <height>687</height>
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
