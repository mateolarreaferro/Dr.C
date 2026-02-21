<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 8192, 10, 1

instr 1

asig poscil 0.5, p4, giSine		;play something
     outs asig, asig
endin

instr 11

setscorepos 8.5				
endin

</CsInstruments>
<CsScore>

i1 0 2 220	;this one will be played
i11 2.5 1	;start setscorepos now
i1 3 2 330	;skip this note
i1 6 2 440	;and this one
i1 9 2 550	;play this one        

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
