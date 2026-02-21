<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 4.8.BR1.ORC

instr          1

i1             =         1/p3
i2             =         cpspch(p4)
i3             =         i2*p8
i4             =         i3*(p7-p6)
i5             =         i3*p6

a1             oscil     p5,i1,1
a2             oscil     i4,i1,1
a2             oscili    a2+i5,i3,3
a1             oscili    a1,i2+a2,3

               out       a1

endin

</CsInstruments>
<CsScore>
c fig4.8.brs1.scr
f 1 0 512 7 0 85 1 85 .7 256 .7 86 0
f 2 0 512 7 1 64 0 448 0
f 3 0 512 9 1 1 0
  i1 0.000 0.750 6.05 20000 1 20 0.667
  i1 0.750 0.250 6.02 20000 1 20 0.667
  i1 1.000 1.000 6.04 20000 1 20 0.667
  i1 2.000 0.250 7.01 20000 1 20 0.667
  i1 2.250 0.250 7.09 20000 1 20 0.667
  i1 2.500 0.250 7.01 20000 1 20 0.667
  i1 2.750 0.250 7.04 20000 1 20 0.667
  i1 3.000 2.000 8.03 20000 1 20 0.667
  i1 5.000 0.500 9.08 20000 1 20 0.667
  i1 5.500 0.500 9.05 20000 1 20 0.667
  i1 6.000 0.500 9.05 20000 1 20 0.667
  i1 6.500 0.750 6.11 20000 1 20 0.667
  i1 7.250 0.250 6.07 20000 1 20 0.667
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
