<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr 	408		
a1		oscil	15000, 440, 1		; GENERATE THE MODULATING SIGNAL
a2		oscil	15000, 440+a1, 1	; GENERATE THE MODULATED CARRIER SIGNAL
		out		a2					; AND PLAY THE OUTPUT
		endin		

</CsInstruments>
<CsScore>

f 1 0 4096 10 1

i 408 0 2

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
