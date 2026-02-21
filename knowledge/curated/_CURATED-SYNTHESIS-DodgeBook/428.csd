<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

instr          1
; WAVESHAPER DRUM (P145)
i1             =         1/p3
i2             =         cpspch(p4)
;
;SCALING FACTOR CODE
;
a1             oscili    p5,i1,2
a2             oscili    a1,i2,3
;
; AUDIO CODE
;
a3             linseg    1,.04,0,p3-.04,0
a4             oscili    a3,i2*.7071,3
;
;
; INLINE CODE FOR TRANSFER FUNCTION:
; f(x)=1+.841x-.707x**2-.595x**3+.5x**4+.42x**5-.354x**6-.279x**7+.25x**8+.21x**9
;
a5             =         a4*a4
a6             =         a5*a4
a7             =         a5*a5
a8             =         a7*a4
a9             =         a6*a6
a10            =         a9*a4
a11            =         a10*a4
a12            =         a11*a4
;
a13            =         1+.841*a4-.707*a5-.595*a6+.5*a7+.42*a8-.354*a9-.297*a10+.25*a11+.21*a12
;
a14            =         a13*a2
;
out            a14
;
endin

</CsInstruments>
<CsScore>
f 1 0 512 7 1 102 0 410 0
f 2 0 512 7 0 16 .2 16 .38 16 .54 16 .68 16 .8 16 .9 16 .98 8 1 2 1 6 .96 64 .8313 32 .5704 80 .164 48 .0521 44 .0159 20 .0092 64 .005 32 0
f 3 0 512 9 1 1 0

  i1 0.000  .2  6.00 20000
  i1 +        .      6.05 20000
  i1 .        .      7.00 20000
  i1 .        .      7.05 20000
  i1 .        .      8.00 20000
  i1 .        .      8.05 20000
  i1 .        .      9.00 20000
  i1 .        .      8.07 20000
  i1 .        .      8.00 20000
  i1 .        .      7.07 20000
  i1 .        .      7.00 20000
  i1 .        .      6.07 20000
  i1 .        .      6.00 20000

s
f0 1
s

  i1 0.000 0.750 6.00 20000
  i1 0.750 0.250 6.05 20000
  i1 1.000 1.000 7.00 20000
  i1 2.000 0.200 7.05 20000
  i1 2.200 0.200 8.00 20000
  i1 2.400 0.200 8.05 20000
  i1 2.600 0.200 9.00 20000
  i1 2.800 0.200 8.07 20000
  i1 3.000 2.000 8.00 20000
  i1 5.000 0.250 7.07 20000
  i1 5.250 0.250 7.00 20000
  i1 5.500 0.250 6.07 20000
  i1 5.750 0.250 6.00 20000
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
