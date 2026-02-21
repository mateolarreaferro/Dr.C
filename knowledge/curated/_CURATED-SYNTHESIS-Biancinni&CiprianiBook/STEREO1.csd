<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;stereo1.orc

	instr 	1
ast	oscili	p4,p5,1
	outs	ast*(1-p6),ast*p6
	endin
 

</CsInstruments>
<CsScore>
;stereo1.sco
f1 0 4096 10 9 8 7 6 5 4 3 2 1
i1 0	1 	10000	200	1 	;right stereo output
i1 1.1	1 	10000	200	.5 	;center stereo output
i1 2.2	1 	10000	200	0	;left stereo output

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
