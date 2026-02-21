<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ==== RED ==== ;
       instr   8                             ; p4 = AMP
ifuncl =       16                            ; p5 = FILTERSWEEP STARTFREQ
                                             ; p6 = FILTERSWEEP ENDFREQ
k1     expon   p5, p3, p6                    ; p7 = BANDWIDTH 
k2     line    p8, p3, p8 * .93              ; p8 = CPS OF rand1
k3     phasor  k2                            ; p9 = CPS OF rand2
k4     table   k3 * ifuncl, 20               ; p10 = REVERB SEND FACTOR     
anoise rand    8000                          
aflt1  reson   anoise, k1, 20 + (k4 * k1 / p7), 1        
k5     linseg  p6 * .9, p3 * .8, p5 * 1.4, p3 * .2, p5 * 1.4
k6     expon   p9 * .97, p3, p9
k7     phasor  k6
k8     tablei  k7 * ifuncl, 21
aflt2  reson   anoise, k5, 30 + (k8 * k5 / p7 * .9), 1
abal   oscil   1000, 1000, 1                  
a3     balance aflt1, abal
a5     balance aflt2, abal
k11    linen   p4, .15, p3, .5
a3     =       a3 * k11
a5     =       a5 * k11
k9     randh   1, k2
aleft  =       ((a3 * k9) * .7) + ((a5 * k9) * .3)     
k10    randh   1, k6
aright =       ((a3 * k10) * .3)+((a5 * k10) * .7)
       outs    aleft, aright
garvb  =       garvb + (a3 * p10)
endin
; ==== SWIRL ==== ;
       instr   99                            ; p4 = PANRATE
k1     oscil   .5, p4, 1
k2     =       .5 + k1
k3     =       1 - k2
asig   reverb  garvb, 2.1
       outs    asig * k2, (asig * k3) * (-1)
garvb  =       0
       endin
</CsInstruments>
<CsScore>
f1   0  8192  10   1
f20  0  16   -2    0   30  40  45  50  40  30  20  10  5  4  3  2  1  0  0  0
f21  0  16   -2    0   20  15  10  9   8   7   6   5   4  3  2  1  0  0
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0   9.9     11.7
; ==== RED ==== ;
; i8:  p4=amp, p5=swpstrt, p6=swpend, p7=bndwt, p8=rnd1:cps, p9=rnd2:cps, p10=rvbsnd 
i8   0   6       11      3000     100    500    8.3    9.8    0.1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
