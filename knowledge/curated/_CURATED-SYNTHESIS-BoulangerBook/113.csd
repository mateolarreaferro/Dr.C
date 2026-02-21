<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

		instr  	113
k1		linen	p4, p7, p3, p8
a1   	oscil	k1, p5, p6
       	out  	a1
		endin

</CsInstruments>
<CsScore>
;Function 1 uses the GEN10 subroutine to compute a sine wave
;Function 2 uses the GEN10 subroutine to compute the first sixteen partials of a sawtooth wave

f1  0 4096 10   1    
f2  0 4096 10   1  .5 .333 .25 .2 .166 .142 .125 .111 .1 .09 .083 .076 .071 .066 .062

;ins	strt	dur amp     frq     fn  atk		rel
;==================================================
i113		0		2	20000	440		1    1		1
i113		2.5		2	20000	220		2	 .01	1.99
i113		5		4	20000	110		2    3.9	.1
i113		10		10	10000	138.6	2    9     	1
i113		10		10 	10000	329.6	1    5     	5
i113		10		10	10000	440		1    1     	9
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
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
