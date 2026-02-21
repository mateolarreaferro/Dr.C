<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1


gadist init 0
  
instr 1
  iamp = p4
  ifqc = cpspch(p5)
  asig pluck iamp, ifqc, ifqc, 0, 1
  gadist = gadist + asig
endin
  
instr 50
  kpre init p4
  kpost init p5
  kshap1 init p6
  kshap2 init p7
  aout distort1 gadist, kpre, kpost, kshap1, kshap2, 1

  outs aout, aout

  gadist = 0
endin


</CsInstruments>
<CsScore>

;   Sta  Dur  Amp    Pitch
i1  0.0  3.0  0.5  6.00
i1  0.5  2.5  0.5  7.00
i1  1.0  2.0  0.5  7.07
i1  1.5  1.5  0.5  8.00
  
;   Sta  Dur  PreGain PostGain Shape1 Shape2
i50 0    4      2       .5       0      0
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
