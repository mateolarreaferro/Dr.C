<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 5.26.ORC


instr          1

i1=cpspch(p4)
i2=int((80000/i1)+.5)
i3=1/32767

a1             linen     p5,p6,p3,p7
k1             linen     p5,p6,p3,p7
a2             buzz      a1,i1,i2,5
a2             reson     a2,i1,i1,1,0
a2             reson     a2,500,500,1,0
a2             reson     a2,1500,750,1,0
a2             reson     a2,3000,1200,1,0
a2             balance   a2,a1
k1             =         (k1*i3)*8000
a1             reson     a2,0.,k1,1,0
out            a1
     
endin

</CsInstruments>
<CsScore>
c fig5.26.scr
f 1 0 512 5 1 512 .001
f 2 0 512 7 1 64 0 448 0
f 3 0 512 9 1 1 0
f 5 0 1025 9 .25 1 90
  i1 0.000 0.750 6.00 4000 0.010 0.010
  i1 0.750 0.250 6.00 4000 0.010 0.010
  i1 1.000 1.000 6.00 4000 0.010 0.010
  i1 2.000 0.250 7.01 4000 0.010 0.010
  i1 2.250 0.250 7.09 4000 0.010 0.010
  i1 2.500 0.250 7.01 4000 0.010 0.010
  i1 2.750 0.250 7.04 4000 0.010 0.010
  i1 3.000 2.000 8.03 4000 0.010 0.010
  i1 5.000 0.500 9.08 4000 0.010 0.010
  i1 5.500 0.500 9.05 4000 0.010 0.010
  i1 6.000 0.500 9.05 4000 0.010 0.010
  i1 6.500 0.750 6.00 4000 0.010 0.010
  i1 7.250 0.250 6.00 4000 0.010 0.010
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
