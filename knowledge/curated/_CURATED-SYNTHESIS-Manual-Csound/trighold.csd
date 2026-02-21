<CsoundSynthesizer>
<CsInstruments>

0dbfs = 1.0

instr 1
  km = metro(1)
  kt timeinsts
  ktrig = trighold(km, 0.5)
;  printks "t=%f  km=%f    ktrig=%f\n", 0.01, kt, km, ktrig
endin

instr 2
  am = upsamp(metro(1))
  aenv = trighold(am, 0.5)
  asig pinker
  outch 1, asig*aenv
  outch 2, asig
endin

</CsInstruments>
<CsScore>
i 1 0 10
i 2 0 10

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
