<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr 1
abimod	oscili	5000,200,1  	;abimod oscillates between 5000 and -5000
aunimod	=	abimod+5000	;add an offset of 5000, to get a unipolar 
				;modulator (aunimod oscillates between 0 
				;and 10000)
acar	oscili 	aunimod,800,1 	;carrier: amplitude is controlled with the  
				;unipolar oscillation
	out 	acar
	endin
 

</CsInstruments>
<CsScore>
;am.sco
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
