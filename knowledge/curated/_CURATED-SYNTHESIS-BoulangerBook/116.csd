<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr   	116
k1      linen   	p4, p7, 	p3, 	p8
k2      linseg  	p5, p3/2, 	p10, 	p3/2, 	p5	
a1 		pluck 		k1, k2, 	p5, 	p6, 	p9
		out 		a1
		endin


</CsInstruments>
<CsScore>
;ins	strt	dur amp     frq     fn	atk		rel		meth  	bend
;============================================================================

i116   0      3	30000	440     0		.6  	.1		1		329.6
i116   	3.5    3	30000  	220     0  	1   	.1		1		138.6
i116   	7      3	10000  	110     0   	.05		1		1		220
i116   	10     10	30000  	138.6   0  	.2  	1		1		220			
i116   	10     10	30000  	329.6   0  	.3  	1		1		220		
i116   10     10	30000  	440     0  	.4  	.1		1		220
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>180</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
