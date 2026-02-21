<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr	411					
a1		oscil	p5, 440, 1			; GENERATE THE SIGNAL
a2		table	a1, 2				; USE TABLE LOOKUP TO COMPUTE THE SINE
		out		a2*p4				; AND PLAY THE OUTPUT
		endin		

</CsInstruments>
<CsScore>
f 1 0 512 10 1
f 2 0 256 10 1

i 411 0 2 10000 128 
s
i 411 0 2 10000 512 
s
i 411 0 2 10000 1024 


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
