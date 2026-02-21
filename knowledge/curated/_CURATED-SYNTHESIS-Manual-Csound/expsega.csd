<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs  = 1

instr 1

aenv expsega 0.01, 0.1, 1, 0.1, 0.01    ; Define a short percussive amplitude envelope
a1 oscili aenv, 440
outs a1, a1

endin

</CsInstruments>
<CsScore>
i 1 0 1
i 1 1 1
i 1 2 1
i 1 3 3
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
