<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;ring.orc	


	instr 	1
abimod	oscili 	100, 250, 1 		;bipolar mod
acar	oscili	100*abimod, 800, 1 	;bipolar car
	out 	acar
	endin
 

</CsInstruments>
<CsScore>
;ring.sco
f1 0 4096 10 3 2 1 
i1  0	3

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
