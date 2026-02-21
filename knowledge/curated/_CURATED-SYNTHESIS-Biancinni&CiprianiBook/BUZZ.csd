<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;buzz.orc

	instr	1
kharm	line	1,p3,20		;control ramp, from 1 to 20
a1	buzz	10000,440,kharm,1	;number of harmonics in the buzz increases 					;from 1 to 20
	out	a1
	endin
 

</CsInstruments>
<CsScore>
;buzz.sco
f1	0	8192	10	1	;sine wave
i1 	0	3

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
