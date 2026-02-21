<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>


gkfreq init 0.1

instr 1
  kamp = 30000

  a1 mpulse kamp, gkfreq
  out a1
endin

instr 2
; Assign the value of p4 to gkfreq
gkfreq init p4
endin
</CsInstruments>
<CsScore>

; Play Instrument #1 for one second.
i 1 0 11
i 2 2 1    0.05
i 2 4 1    0.01
i 2 6 1    0.005
; only last notes are audible
i 2 8 1    0.003
i 2 10 1    0.002


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
