<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

gifn	ftgen	0,0, 257, 9, .5,1,270	; define a sigmoid, or better 
;gifn	ftgen	0,0, 257, 9, .5,1,270,1.5,.33,90,2.5,.2,270,3.5,.143,90,4.5,.111,270

instr 1

kdist	line	0, p3, 2		; and over 10 seconds
asig	poscil	0.3, 440, 1
aout	distort	asig, kdist, gifn	; gradually increase the distortion
	outs	aout, aout

endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1
i 1 0 10
e

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
