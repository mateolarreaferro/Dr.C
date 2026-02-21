<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr   108
a1   	foscil 	p4, p5, p6, p7, p8, p9
		out     a1
		endin

</CsInstruments>
<CsScore>
;Function 1 uses the GEN10 subroutine to compute a sine wave
;Function 2 uses the GEN10 subroutine to compute the first sixteen partials of a sawtooth wave

f1  0 4096 10   1    
f2  0 4096 10   1  .5 .333 .25 .2 .166 .142 .125 .111 .1 .09 .083 .076 .071 .066 .062

i108		0		1       10000		440  	1  2  		3  		1
i108		1.5   	1       20000		220  	1  13  		8  	    1
i108		3	    3       10000		110   	1  1  		13  	1
i108		3.5		2.5     10000		130.8  	1  2.001  	8  	   	1
i108		4	    2       5000		329.6  	1  3.003  	5  	    1
i108		4.5		1.5     6000		440    	1  5.005  	3  		1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>8</height>
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
