<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

maxalloc 1, 3	; Limit to three instances.
 
instr 1

asig oscil .3, p4, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>
; sine
f 1 0 32768 10 1

i 1 0 5 220	;1
i 1 1 4 440	;2
i 1 2 3 880	;3, limit is reached
i 1 3 2 1320	;is not played
i 1 4 1 1760	;is not played
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
