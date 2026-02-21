<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;=======================================================================;
; KARSTR          Plucked String Instrument                             ;
;                 Coded by Tom Dimeo                                    ;
;                 Brooklyn College of Music Computer Music Studio       ;
;=======================================================================;
          instr        1
ga1       init      0
i1        =         cpsoct(p5)
i2        =         1/i1-.5/sr
i3        =         p4*10

k1        linseg    1,i2,1,.0001,0,p3-i2-.0001,0
a1        rand      k1
a2        delay     a1+ga1,i2
a1        delay1    a2
a4        line      .498,p3,.48
ga1       =         a4*(a1+a2)
ga1       alpass    ga1,0,i2
a3        =         ga1*i3
a3        tone      a3,(p4-1000)*.5
          out       a3
          endin

</CsInstruments>
<CsScore>
;=======================================================================;
; KARSTR          Score for Plucked String Instrument coded by Dimeo    ;
;=======================================================================;
; KARSTR           p4       p5                                          ;
;                  amp      pch                                         ;
;=======================================================================;
i1   0.00   1.50   5000     6.00
i1   1.50   0.50   5000     6.05
i1   2.00   2.00   5000     7.00
i1   4.00   0.20   5000     7.05
i1   4.20   0.20   5000     8.00
i1   4.40   0.20   5000     8.05
i1   4.60   0.20   5000     9.00
i1   4.80   0.20   5000    10.07
i1   5.00   2.00   5000    10.00
i1   7.00   0.50   5000    11.07
i1   7.50   0.50   5000    11.00
i1   8.00   0.50   5000    12.07
i1   8.50   0.50   5000     6.00
i1   9.00   1.50   5000     6.05
i1  10.50   0.50   5000     7.00
i1  11.00   2.00   5000     7.05
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
