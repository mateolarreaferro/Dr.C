<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


		instr  	101
a1   	oscil   10000, 440, 1
       	out     a1
		endin

</CsInstruments>
<CsScore>
;Function 1 uses the GEN10 subroutine to compute a sine wave
f 1  0 4096 10   1 
; inst	start	duration
i 101		0		3
</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>8</height>
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
