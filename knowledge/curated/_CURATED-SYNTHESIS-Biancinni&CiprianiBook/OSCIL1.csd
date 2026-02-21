<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;oscil.orc

	instr 1
aneworc	oscil 	10000, 220, 1
	out 	aneworc
	endin
 


</CsInstruments>
<CsScore>
;oscil1.sco
f1 0 4096 10 10 9 8 7 6 5 4 3 2 1
;fundamental plus harmonics up to the ninth, with decreasing amplitude
;
f1 3 4096 10 10 5 3.3 2.5 2 1.6 1.4 1.25 1.1 1
;approximates a sawtooth wave
;
f1 6 4096 10 10 0 3.3 0 2 0 1.4 0 1.1
;approximates a square wave
;
f1 9 4096 10 1					; a sine wave
f1 12 4096 10 0 1				; 1st harmonic only
f1 15 4096 10 0 0 1				; 2nd harmonic only
f1 18 4096 10 0 0 0 1				; 3rd harmonic only
f1 21 4096 10 1 1 1 1 1				; fund.+1st +2nd+3rd +4th 
f1 24 4096 10 10 0 0 0 0 0 1			; fund.+6th 
f1 27 4096 10 0 0 0 0 0 0 1			; 6th harmonic only
i1 0 2
i1 3 2
i1 6 2
i1 9 2
i1 12 2
i1 15 2
i1 18 2
i1 21 2
i1 24 2
i1 27 2



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
