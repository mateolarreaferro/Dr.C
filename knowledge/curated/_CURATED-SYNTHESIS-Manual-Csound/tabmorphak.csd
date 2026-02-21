<CsoundSynthesizer>
<CsInstruments>

0dbfs   =1

giSine	 ftgen	0, 0, 8193, 10, 1						; sine wave
giSquare ftgen	0, 0, 8193, 7, 1, 4096, 1, 0, -1, 4096, -1			; square wave 
giTri	 ftgen	0, 0, 8193, 7, 0, 2048, 1, 4096, -1, 2048, 0			; triangle wave 
giSaw	 ftgen	0, 0, 8193, 7, 1, 8192, -1					; sawtooth wave, downward slope 
	
instr	1

iamp	= .7
aindex	phasor	110			; read table value at this index
kweightpoint expon 0.001, p3, 1		; using the weightpoint to morph between two tables exponentially
ktabnum1 = p4				; first wave, it morphs to
ktabnum2 = p5				; the second wave
asig 	tabmorphak aindex, kweightpoint, ktabnum1,ktabnum2, giSine, giSquare, giTri, giSaw
asig	= asig*iamp
	outs asig, asig

endin
</CsInstruments>
<CsScore>

i1 0 5 0 1	;from sine to square wave
i1 6 5 2 3	;from triangle to saw
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
