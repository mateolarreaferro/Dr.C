<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr 1			; instrument #1
kglis	line 220,p3,440		; a straight line going from 220 to 440 in p3 seconds, output in the 				; kglis control rate variable
a1	oscil p4,kglis,1		; oscillator with amplitude p4, frequency following the straight line in 				; kglis, waveform function #1 (as defined in the score), output in the 				; a1 audio rate variable
	out a1			; write the contents of a1 to disk 
	endin
 

</CsInstruments>
<CsScore>
;gliss.sco
f1 0 4096 10 1		; generate function #1, using 4096 memory locations and the 				; GEN10 routine, get a single sine wave
i1 0 3 10000		; amp is 10000, the glissando will complete in 3 seconds
i1 4 10 12000		; amp is 12000, the glissando will complete in 4 seconds

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
