<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

nchnls = 2

instr 1

idamp = p4			;vary damping amount
asig stix .5, 0.01, 30, idamp
     outs asig, asig

endin
</CsInstruments>
<CsScore>

i1 0 1 .3
i1 + 1  >
i1 + 1  >
i1 + 1 .95

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
