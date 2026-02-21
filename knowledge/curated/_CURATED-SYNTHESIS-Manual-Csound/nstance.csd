<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1


instr 1 ; Instrument #1 - oscillator with a high note.
  
  iHandle nstance 2, .3, p3     ; Play Instrument #2 0.3 seconds later
  a1 oscils .5, 880, 1          ; a high note
  outs a1 * .5, a1              ; ... a bit to the right
  print iHandle
endin


instr 2 ; Instrument #2 - oscillator with a low note.
  
  a1 oscils .5, 110, 1          ; a low note
  outs a1, a1 * .5              ; ... a bit to the left
endin


</CsInstruments>
<CsScore>
f 1 0 16384 10 1    ; a sine wave.

i 1 0 1
i 1 2 .5
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
