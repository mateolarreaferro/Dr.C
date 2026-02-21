<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;vibrato1.orc

	instr 1
k1	oscili	.009,3,1 	;control oscillator, amplitude peak=deviation peak in %,
					;frequency=vibrato speed
asound	oscili	10000,p4*(1+k1),1 	;audio variable 
	out	asound
	endin
 

</CsInstruments>
<CsScore>
;vibrato1.sco
f1 	0 	4096 	10 	1
i1	0 	3 	220
i1	3.1 	3 	440
i1	6.2 	3 	880

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
