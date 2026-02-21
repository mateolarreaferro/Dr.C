<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 4.8.cl.orc

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
c fig4.8.cl.scr
f 1 0 512 5 .001 64 1 384 1 64 .001
f 2 0 512 5 .001 64 1 448 1
f 3 0 512 9 1 1 0
f 0 2 
s
  i1 0.000 0.750 8.00 20000 7 2 0.667
  i1 0.750 0.250 8.04 20000 7 2 0.667
  i1 1.000 1.000 8.07 20000 7 2 0.667
  i1 2.000 0.250 9.00 20000 7 2 0.667
  i1 2.250 0.250 9.00 20000 7 2 0.667
  i1 2.500 0.250 9.00 20000 7 2 0.667
  i1 2.750 0.250 9.00 20000 7 2 0.667
  i1 3.000 2.000 9.05 20000 7 2 0.667
  i1 5.000 0.500 10.00 20000 7 2 0.667
  i1 5.500 0.500 10.05 20000 7 2 0.667
  i1 6.000 0.500 11.00 20000 7 2 0.667
  i1 6.500 0.750 8.00 20000 7 2 0.667
  i1 7.250 0.250 8.04 20000 7 2 0.667
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
