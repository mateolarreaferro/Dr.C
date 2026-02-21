<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


		instr   104					
a1 		pluck 	20000, 440, 440, 2, 1   ;karplus-strong plucked string
		out 	a1
		endin

</CsInstruments>
<CsScore>
; Function 2 uses the GEN10 subroutine to compute the first sixteen partials of a sawtooth wave
f 2  0 4096 10   1  .5 .333 .25 .2 .166 .142 .125 .111 .1 .09 .083 .076 .071 .066 .062

; inst	    start	duration
i 104    	0       3

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
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
