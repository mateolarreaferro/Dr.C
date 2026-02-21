<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;oscil2.orc

	instr 1
asound 	oscil 	p4,p5,1
	out 	asound
	endin
 


</CsInstruments>
<CsScore>
;oscil2.sco
f1 0 4096 10 1
; p1	p2	p3	p4	p5
i1	0	2	20000	110 	; playes a note starting at 0 sec, with a duration of 2 sec, 					; amp level 20000 and fundamental freq. 110 Hz
i1	3	2	8000	110	; starts at 3 sec, with a duration of 2 sec, amp level 8000 and 					; fundamental freq. 110 Hz
i1	6	2	9000	440
i1	9	2	15000	440

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
