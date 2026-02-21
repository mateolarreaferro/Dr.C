<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 4.8.long.orc

          instr 1
i1        =         1/p3
i2        =         cpspch(p4)
i3        =         i1*p6
i4        =         i3*p7

a1        oscil     p5,i1,2
a2        oscil     i4,i1,1
a2        oscili    a2,i3,3
a1        oscili    a1,i2+a2,3

          out       a1

          endin

</CsInstruments>
<CsScore>
c fig 4.8.long
f 1 0 512 5 1 512 .001
f 2 0 512 7 1 64 0 448 0
f 3 0 512 9 1 1 0
  i1 0.000 1.000 8.00 20000 1.400 10
  i1 1.000 1.000 8.00 20000 1.400 10
  i1 2.000 1.000 8.00 20000 1.400 10
  i1 3.000 1.000 8.00 20000 1.400 10
  i1 4.000 15.000 8.00 20000 1.400 10
end of score
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
