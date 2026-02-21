<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 4.8.br2.or


          instr 1

i1        =         1/p3
i2        =         cpspch(p4)
i3        =         i2*p8
i4        =         i3*(p7-p6)
i5        =         i3*p6

a1        oscil     p5,i1,1
a2        oscil     i4,i1,1
a2        oscili    a2+i5,i3,3
a1        oscili    a1,i2+a2,3

          out       a1

          endin

</CsInstruments>
<CsScore>
c fig4.8.br2.scr
f 1 0 512 5 1 512 .001
f 2 0 512 7 1 64 0 448 0
f 3 0 512 9 1 1 0
  i1 0.000 2.000 6.00 20000 1.400 10 0.667
  i1 2.000 2.000 6.07 20000 1.400 10 0.667
  i1 4.000 2.000 7.00 20000 1.400 10 0.667
  i1 6.000 2.000 7.07 20000 1.400 10 0.667
  i1 8.000 2.000 8.00 20000 1.400 10 0.667
  i1 10.000 2.000 8.07 20000 1.400 10 0.667
  i1 12.000 2.000 9.00 20000 1.400 10 0.667
  i1 14.000 2.000 9.07 20000 1.400 10 0.667
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
