<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; fig4.11.b.orc


instr          1
i7             =         cpspch(p4)
i2             =         p6
i2             =         (i2/i7)+.5
i2             =         int(i2)
i3             =         p7
i4             =         p8
i5             =         p9*.4
i6             =         p10
i8             =         i5/i4
i9             =         exp(1.5*log(p5/32767))
i10            =         .00311*log(i7)
i11            =         sqrt(p5/32767)
i12            =         (1-i3)*i11
i13            =         i4*i7
i14            =         i9*i3

a1             linen     i12,.1,p3,.08
a2             oscil     i13,i7,3
a8             =         i7+a2
a4             linen     i10,.6,p3,.1
a4             oscil     a4,i6,3
a5             randi     i10,15
a6             linseg    -.03,.07,.03,.03,0,p3-.1,0
a6             =         a4+a5+a6+1.
a1             oscili    a1,(a8+a2)*a6,3
a7             =         (a2*i8)+i2
a3             linseg    0,.07,.1,.03,1.,p3-.18,1,.02,.1,.06,0
a3             =         a3*(i9*i3)
a3             oscili    a3,a7*a6,3

out            (a1+a3)*p5

endin

</CsInstruments>
<CsScore>
c fig4.11a.scr
f 3 0 512 9 1 1 0
f 4 0 512 -7 3000 71 3000 168 2300 100 2100 71 2000 102 2000
f 5 0 512 -7 .025 71 .02 102 .025 71 .05 268 .06
f 6 0 512 -7 .25 71 .25 102 .08 .05 339 .05
f 7 0 512 -7 5 71 2.3 102 1.5 237 2.5 102 2.3
f 8 0 512 -7 5 512 6.5
  i1 0.000 2.010 7.07 20000 700 0.040 0.250 5.000 5.000
  i1 3.000 2.010 8.00 20000 700 0.020 0.250 2.500 5.300
  i1 6.000 2.010 8.07 20000 700 0.030 0.100 1.500 5.600
  i1 9.000 2.010 9.00 20000 1100 0.050 0.080 2.500 5.900
  i1 12.000 2.010 9.07 20000 1400 0.060 0.070 3.000 6.200
  i1 15.000 2.010 10.00 20000 1700 0.070 0.060 3.500 6.500
  i1 18.000 2.010 10.07 20000 1700 0.080 0.050 3.000 6.500
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
