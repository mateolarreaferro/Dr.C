<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; FIG 5.24a.orc

          instr 1
i1        =         cpspch(p4)
i2        =         int((8000/i1)+.5)
i3        =         1/32767

a1        linen     p5,p6,p3,p7
k1        linen     p5,p6,p3,p7
a2        buzz      a1,i1,i2,5
k1        =         (k1*i3)*5000.
a1        reson     a2,0.,k1,1,0

          out       a1
          endin

</CsInstruments>
<CsScore>
c fig 5.24ns.scr1
f 1 0 512 7 0 512 1
f 4 0 512 5 1 512 3
f 5 0 1025 9 .25 1 90
f 2 0 512 9 .5 1 0
  i1 0.000 4.000 6.00 32000 2.000 2.000
  i1 4.000 4.000 7.00 32000 2.000 2.000
  i1 8.000 4.000 8.00 32000 2.000 2.000
  i1 12.000 4.000 9.00 32000 2.000 2.000
  i1 16.000 4.000 10.00 32000 2.000 2.000
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
