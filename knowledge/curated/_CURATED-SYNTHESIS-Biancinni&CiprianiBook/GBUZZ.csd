<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	1

km	line   .1,p3,.7		; ramping from .1 to .7
a1	gbuzz	10000,440,20,2,km,1	; 20 harmonics, starting with the 2nd					
					; amplitude series multiplier varies with km
	out	a1
	endin
 

</CsInstruments>
<CsScore>
;gbuzz.sco
f1	0	8192	9 1 1 90	;cosine wave
i1 	0	3

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
