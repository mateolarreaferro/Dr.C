<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;am3.sco

	instr 1
abimod	oscili	5000,200,1 	;abimod oscillates between -5000 and 5000
				;(bipolar signal)
acar	oscili	abimod,800,1	;carrier: amplitude is driven by abimod 
	out   	acar
	endin
 

</CsInstruments>
<CsScore>
;am3.sco
f1	0	4096	10	1
i1	0	3

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
