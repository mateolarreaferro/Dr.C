<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;vibrato.orc

	instr 1
k1	oscili		2,3,1 			;control oscillator, amplitude peak=deviation peak,
						;frequency=vibrato speed
asound	oscili		10000,220+k1,1 	;audio variable
	out		asound
	endin
 

</CsInstruments>
<CsScore>
;vibrato.sco
f1 	0 	4096 	10 	1
i1	0 	3 

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
