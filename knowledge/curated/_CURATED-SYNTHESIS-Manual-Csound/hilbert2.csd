<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
0dbfs = 1

instr 1

asig oscili p4, p5
a1,a2 hilbert2 asig,1024,256
  outs a1, a2

endin


</CsInstruments>
<CsScore>
i1 0 10 0.5 440
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
