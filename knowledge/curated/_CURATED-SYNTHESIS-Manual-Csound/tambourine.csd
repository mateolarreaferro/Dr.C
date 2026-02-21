<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1

idamp = p4
asig  tambourine .8, 0.01, 30, idamp, 0.4
      outs asig, asig

endin
</CsInstruments>
<CsScore>

i 1 0 .2 0
i 1 + .2 >
i 1 + 1 .7
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
