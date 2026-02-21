<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

; Mute Instrument #2.
mute 2
; Mute Instrument three.
mute "three"

instr 1

a1 oscils 0.2, 440, 0
   outs a1, a1
endin

instr 2	; gets muted

a1 oscils 0.2, 880, 0
   outs a1, a1
endin

instr three	; gets muted

a1 oscils 0.2, 1000, 0
   outs a1, a1
endin

</CsInstruments>
<CsScore>

i 1 0 1
i 2 0 1
i "three" 0 1
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
