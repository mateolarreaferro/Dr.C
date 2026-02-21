<CsoundSynthesizer>
<CsInstruments>

instr 1

  a1 oscil 10000, 440, 1

  out a1

endin

</CsInstruments>
<CsScore>

f1	0	4096	10	1	; use GEN10 to compute a sine wave

;ins	strt	dur

i1	0	4

e					; indicates the end of the score

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
