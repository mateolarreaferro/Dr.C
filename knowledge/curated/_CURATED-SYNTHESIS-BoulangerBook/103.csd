<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


		instr   103
a1   	buzz   	10000, 440, 10, 1  ; variable pulse train
        out     a1
		endin

</CsInstruments>
<CsScore>
; Function 1 uses the GEN10 subroutine to compute a sine wave

f 1  0 4096 10   1    

;inst	start	duration
i 103  		0       3

</CsScore>
</CsoundSynthesizer>

<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
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
