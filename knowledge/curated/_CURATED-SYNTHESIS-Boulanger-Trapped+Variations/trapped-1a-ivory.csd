<CsoundSynthesizer>
<CsInstruments>
; ==== IVORY ==== ;
       instr    1                            ; p6 = AMP 
ifreq  =        cpspch(p5)                   ; p7 = VIB RATE
                                             ; p8 = GLIS. DEL TIME (DEFAULT < 1)
aglis  expseg   1, p8, 1, p3 - p8, p9        ; p9 = FREQ DROP FACTOR

k1     line     0, p3, 5                     
k2     oscil    k1, p7, 1                    
k3     linseg   0, p3 * .7, p6, p3 * .3, 0   
a1     oscil    k3, (ifreq + k2) * aglis, 1     

k4     linseg   0, p3 * .6, 6, p3 * .4, 0
k5     oscil    k4, p7 * .9, 1, 1.4
k6     linseg   0, p3 * .9, p6, p3 * .1, 0
a3     oscil    k6, ((ifreq + .009) + k5) * aglis, 9, .2
 
k7     linseg   9, p3 * .7, 1, p3 * .3, 1
k8     oscil    k7, p7 * 1.2, 1, .7
k9     linen    p6, p3 * .5, p3, p3 * .333
a5     oscil    k9, ((ifreq + .007) + k8) * aglis, 10, .3
 
k10    expseg   1, p3 * .99, 3.1, p3 * .01, 3.1
k11    oscil    k10, p7 * .97, 1, .6
k12    expseg   .001, p3 * .8, p6, p3 * .2, .001
a7     oscil    k12,((ifreq + .005) + k11) * aglis, 11, .5
 
k13    expseg   1, p3 * .4, 3, p3 * .6, .02
k14    oscil    k13, p7 * .99, 1, .4
k15    expseg   .001, p3 *.5, p6, p3 *.1, p6 *.6, p3 *.2, p6 *.97, p3 *.2, .001
a9     oscil    k15, ((ifreq + .003) + k14) * aglis, 12, .8
 
k16    expseg   4, p3 * .91, 1, p3 * .09, 1
k17    oscil    k16, p7 * 1.4, 1, .2
k18    expseg   .001, p3 *.6, p6, p3 *.2, p6 *.8, p3 *.1, p6 *.98, p3 *.1, .001
a11    oscil    k18, ((ifreq + .001) + k17) * aglis, 13, 1.3 

       outs     a1 + a3 + a5, a7 + a9 + a11
       endin

</CsInstruments>
<CsScore>
f1   0  8192  10   1
f9   0  2048  10   10  9   8   7   6   5   4   3   2  1
f10  0  2048  10   10  0   9   0   8   0   7   0   6  0  5
f11  0  2048  10   10  10  9   0   0   0   3   2   0  0  1
f12  0  2048  10   10  0   0   0   5   0   0   0   0  0  3
f13  0  2048  10   10  0   0   0   0   3   1
; ==== IVORY ==== ;
; i1:  p6=amp, p7=vibrat, p8=glisdeltime (default < 1), p9=frqdrop
i1   0.0    8.0   0      8.057   12000    0.01  .8   0.99
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
