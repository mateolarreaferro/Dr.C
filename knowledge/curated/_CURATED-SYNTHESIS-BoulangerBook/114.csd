<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr   114
k1      linen   p4, p7, p3, p8
k2      line    p11, p3, p12
a1   	foscil 	k1, p5, p9, p10, k2, p6
		out     a1
		endin

</CsInstruments>
<CsScore>
;Function 1 uses the GEN10 subroutine to compute a sine wave

f1  0 4096 10   1    

;ins	strt	dur amp     frq     fn	atk		rel    fc   fm  indx1	indx2
;============================================================================
i114	1		3	20000	440  	1   1		1		1	1	6		1   
i114 	4.5   	3 	20000	220  	1   .1		2.9  	1   .5	1		6
i114	8	    3	20000	110   	1   .1		.1   	1   3	10		1
i114 	12	   10	10000	130.8  	1   9  		1    	1   9	1		7
i114	12	   10	10000	329.6  	1   1  		9    	1   1	9		1
i114	12	   10 	10000	440    	1   5   	5    	.5  1	3		2

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
