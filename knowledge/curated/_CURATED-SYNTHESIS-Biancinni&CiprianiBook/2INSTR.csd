<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;2instr.orc

	instr 1
aone	oscil	p4,p5,1
	out 	aone
	endin

	instr 2
asquare	oscil	p4,p5,2
	out	asquare
	endin
 

</CsInstruments>
<CsScore>
;2instr.sco

f1 0 4096 10 1
f2 0 4096 10 1 0 .33 0 .2 0 .14 0 .11 0 .09
i1	0	3	10000	222	; instr 1, lasts 3 sec, freq. 222 Hz
i2	4	3	10000	222	; instr 2, lasts 3 sec, freq. 222 Hz
i1	8	3	8000	800	; instr 1, lasts 3 sec, freq. 800 Hz
i2	12	3	8000	800	; instr 2, lasts 3 sec, freq. 800 Hz	


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
