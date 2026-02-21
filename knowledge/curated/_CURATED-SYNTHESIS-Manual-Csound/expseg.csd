<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1
  
kcps = cpspch(p4)                           ; p4 = frequency in pitch-class notation.
kenv expseg 0.01, p3*0.25, 1, p3*0.75, 0.001 ; amplitude envelope.
kamp = kenv 
a1 oscili kamp, kcps
outs a1, a1

endin

</CsInstruments>
<CsScore>

i 1 0 0.5 8.00
i 1 1 0.5 8.01
i 1 2 0.5 8.02
i 1 3 2.0 8.03
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
