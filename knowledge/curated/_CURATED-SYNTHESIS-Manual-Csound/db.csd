<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

instr 1

idec = p4
iamp = db(idec)
     print iamp
asig vco2 iamp, 110			;sawtooth
     outs asig, asig

endin

</CsInstruments>
<CsScore>

i 1 0 1 50
i 1 + 1 >
i 1 + 1 >
i 1 + 1 85
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
