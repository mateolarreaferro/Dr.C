<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 3.26A.ORC

instr          1
i1             =         1/p3
i2             =         cpspch(p4)
i3             =         p5/2
i4             =         p5/6
i5             =         p5/2.5

k1             oscili    i3,i1,2
a1             randi     k1,p6
a1             oscili    a1,4000,3

a2             oscili    i4,i1,2
a2             oscili    a2,i2*.1,4

a3             oscili    i5,i1,1
a3             oscili    a3,i2,3

out            a1+a2+a3

endin

</CsInstruments>
<CsScore>
c fig 3.26s.scr
f 1 0 512 5 1 512 .004
f 2 0 512 5 1 512 .00012
f 3 0 512 9 1 1 0
f 4 0 512 9 10 1 0 16 1.5 0 22 2 0 23 1.5 0
  i1 0.000 0.250 5.00 24000 1000
  i1 0.250 0.250 5.00 24000 1000
  i1 0.500 0.250 5.00 24000 1000
  i1 0.750 0.250 5.00 24000 1000
  i1 1.000 0.250 6.00 24000 1000
  i1 1.250 0.250 6.00 24000 1000
  i1 1.500 0.250 6.00 24000 1000
  i1 1.750 0.250 6.00 24000 1000
  i1 2.000 0.250 7.00 24000 1000
  i1 2.250 0.250 7.00 24000 1000
  i1 2.500 0.250 7.00 24000 1000
  i1 2.750 0.250 7.00 24000 1000
  i1 3.000 0.250 8.00 24000 1000
  i1 3.250 0.250 8.00 24000 1000
  i1 3.500 0.250 8.00 24000 1000
  i1 3.750 0.250 8.00 24000 1000
  i1 4.000 0.250 9.00 24000 1000
  i1 4.250 0.250 9.00 24000 1000
  i1 4.500 0.250 9.00 24000 1000
  i1 4.750 0.250 9.00 24000 1000
  i1 5.000 0.250 10.00 24000 1000
  i1 5.250 0.250 10.00 24000 1000
  i1 5.500 0.250 10.00 24000 1000
  i1 5.750 0.250 10.00 24000 1000
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
