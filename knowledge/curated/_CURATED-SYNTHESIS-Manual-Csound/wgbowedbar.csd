<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1

kp   = p6
asig wgbowedbar p4, cpspch(p5), 1, kp, 0.995
     outs asig, asig

endin
</CsInstruments>
<CsScore>
s
i1 0 .5 .5 7.00 .1	;short sound
i1 + .  .3 8.00 .1
i1 + .  .5 9.00 .1
s
i1 0 .5 .5 7.00  1	;longer sound
i1 + .  .3 8.00  1
i1 + .  .5 9.00  1
 
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
