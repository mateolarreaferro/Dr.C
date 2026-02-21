<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 2^10, 10, 1

instr 1

kvib init 1
ktim timeinsts				;read time 

if ktim > 2 then			;do something after 2 seconds
   kvib oscili 2, 3, giSine		;make a vibrato
endif

asig poscil .5, 600+kvib, giSine	;add vibrato
     outs asig, asig

endin 
</CsInstruments>
<CsScore>

i 1 0 5
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
