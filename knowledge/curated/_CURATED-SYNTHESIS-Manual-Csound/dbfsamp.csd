<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

instr 1

iamp = p4
idb  = dbfsamp(iamp)
     print idb
asig vco2 iamp, 110	;sawtooth
     outs asig, asig

endin

</CsInstruments>
<CsScore>

i 1 0 1 1
i 1 + 1 100
i 1 + 1 1000
i 1 + 1 10000
i 1 + 1 30000
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
