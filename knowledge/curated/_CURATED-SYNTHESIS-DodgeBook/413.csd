<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;=======================================================================;
; FIG4_13         DOUBLE CARRIER FM INSTRUMENT  (DODGE P. 121)          ;
;                 CODED BY THOMAS DIMEO                                 ;
;                 BROOKLYN COLLEGE COMPUTER MUSIC STUDIO                ;
;=======================================================================;
               instr          1
i1             =              cpspch(p5)
i2             =              p6
i2             =              (i2/i1)+.5
i2             =              int(i2)
i3             =              p7
i4             =              p8
i5             =              p9*.4
i6             =              p10
i8             =              i5/i4
i9             =              exp(1.5*log(p5/32767))
i10            =              .00311*log(i1)
i11            =              sqrt(p4/32767)
i12            =              (1-i3)*i11
i13            =              i4*i1
i14            =              i9*i3

a1             linen          i12,.1,p3,.08
a2             oscil          i13,i1,1
a8             =              i1+a2
a4             linen          i10,.6,p3,.1
a4             oscil          a4,i6,1
a5             randi          i10,15
a6             linseg         -.03,.07,.03,.03,0,p3-.1,0
a6             =              a4+a5+a6+1

a1             oscili         a1,(a8+a2)*a6,1
a7             =              (a2*i8)+i2
a3             linseg         0,.07,.1,.03,1,p3-.18,1,.02,.1,.06,0
a3             =              a3*(i9*i3)
a3             oscili         a3,a7*a6,1
               out            (a1+a3)*p4
               endin

</CsInstruments>
<CsScore>
;=======================================================================;
; FIG4_13         SCORE FOR DBL CARRIER FM INSTRUMENT FROM DODGE P. 121 ;
;=======================================================================;
; SINE
f1    0     512      9       1        1       0
;=======================================================================;
; FIG4_13        p4      p5      p6      p7      p8      p9      p10    ;
;                amp     pch                                            ;
;=======================================================================;
i1  0.0  2.01    20000   7.07    700     0.04    0.25    5.0     5.0
i1  3.0  2.01    20000   8.00    700     0.02    0.25    2.5     5.3
i1  6.0  2.01    20000   8.07    700     0.03    0.10    1.5     5.6
i1  9.0  2.01    20000   9.00   1100     0.05    0.08    2.5     5.9
i1 12.0  2.01    20000   9.07   1400     0.06    0.07    3.0     6.2
i1 15.0  2.01    20000  10.00   1700     0.07    0.06    3.5     6.5
i1 18.0  2.01    20000  10.07   1700     0.08    0.05    3.0     6.5
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
