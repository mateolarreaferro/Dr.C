<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr 	117
k2      linseg  p5, p3/2, p9, p3/2, p5
k3      line    p10, p3, p11
k4      line    p12, p3, p13
k5      expon   p14, p3, p15
k6      expon	p16, p3, p17
a1 		grain 	p4, k2, k3, k4, k5, k6, 1, p6, 1
a2      linen   a1, p7, p3, p8
		out 	a2
		endin

</CsInstruments>
<CsScore>
;Function 1 uses the GEN10 subroutine to compute a sine wave
;Function 3 uses the GEN20 subroutine to compute a Hanning window for use as a grain envelope

f1  0 4096 10   1    
f3  0 4097 20   2  1

; ins	strt	dur amp     frq     fn	atk		rel		bend	dens1	dens2	ampof1	ampof2	pchof1	pchof2	gdur1	gdur2
;=============================================================================================================================
i 117    0      5	900  	440  	3 	1		.1		430 	12000 	4000  	120 	50    	.01  	.05  	.1   	.01 
i 117    6     10	4000  	1760  	3	5		.1		60	    5		200   	500   	1000  	10  	20000   1   	.01
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
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
