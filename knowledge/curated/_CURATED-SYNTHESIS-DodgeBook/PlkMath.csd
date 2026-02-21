<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

  
          instr 1
ga1       init      0
i1        =         cpsoct(p4)
i2        =         1/i1-.5/20000.
i3        =         p5*10
k1        linseg    1.,i2,1.,.0001,0,p3-(i2)-.0001,0
a1        rand      k1
a2        delay     a1+ga1,i2
a1        delay1    a2
a4        line      .498,p3,.48
ga1       =         a4*(a1+a2)
ga1       alpass    ga1,0,i2
a3        =         ga1*i3
a3        tone      a3,(p5-1000)*.5
          out       a3
          endin

</CsInstruments>
<CsScore>
  i1  0.000 1.500  6.00 5000
  i1  1.500 0.500  6.05 5000
  i1  2.000 2.000  7.00 5000
  i1  4.000 0.200  7.05 5000
  i1  4.200 0.200  8.00 5000
  i1  4.400 0.200  8.05 5000
  i1  4.600 0.200  9.00 5000
  i1  4.800 0.200 10.07 5000
  i1  5.000 2.000 10.00 5000
  i1  7.000 0.500 11.07 5000
  i1  7.500 0.500 11.00 5000
  i1  8.000 0.500 12.07 5000
  i1  8.500 0.500  6.00 5000
  i1  9.000 1.500  6.05 5000
  i1 10.500 0.500  7.00 5000
  i1 11.000 2.000  7.05 5000
e
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
