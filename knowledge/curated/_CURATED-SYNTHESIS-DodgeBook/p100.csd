<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; THIS IS THE INSTRUMENT FROM DODGE&JERSE P.100, RISSET'S INHARMONIQUE 


          instr 1
a1        oscil     1,1/p3,5

          ; P3 DURATION

a2        =         ampdb(p4)*a1

          ; P4 PEAK AMPLITUDE

a3        oscil     100,1/p3,7
a4        randh     1,a3
a5        =         .2*a1
a6        =         a5*a4
a7        =         1+a6
a8        =         a7*p5

          ; P5 BANDWIDTH

a9        randi     a2,a8

a10       =         a4*.2
a11       =         1+a10
a12       oscil     p6,1/p3,8

          ; P6 CENTER FREQ

a13       =         a12*a11
a14       oscil     a9,a13,1
          out       a14
          endin





</CsInstruments>
<CsScore>
Score for inharmonique (Dodge & Jerse p.100)

f1 0 512 10 1
f5 0 512 7 0 46 .166 31 1.0 46 .22 46 1.0 23 .38 10 1.0 10 .5 31 1.0 62 .5 118 .25 89 0
f7 0 512 7 1.0 139 1.0 46 .55 93 .55 46 .5 46 .5 15 .27 127 .27 

f8 0 512 7 1.0 201 1.0 311 .25

i1 0 3 80 10 500
i1 3 3 90 50 1000

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
