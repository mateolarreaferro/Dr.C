<CsoundSynthesizer>
<CsInstruments>
; ==== FOAM ==== ;
       instr   13                            ; p6 = AMP
ifreq  =       octpch(p5)                    ; p7 = VIBRATO RATE
                                             ; p8 = GLIS. FACTOR
k1     line    0, p3, p8
k2     oscil   k1, p7, 1                         
k3     linseg  0, p3 * .7, p6, p3 * .3, 1             
a1     oscil   k3, cpsoct(ifreq + k2), 1              
k4     linseg  0, p3 * .6, p8 * .995, p3 * .4, 0
k5     oscil   k4, p7 * .9, 1, .1
k6     linseg  0, p3 * .9, p6, p3 * .1, 3
a2     oscil   k6, cpsoct((ifreq + .009) + k5), 4, .2 
k7     linseg  p8 * .985, p3 * .7, 0, p3 * .3, 0
k8     oscil   k7, p7 * 1.2, 1, .7
k9     linen   p6, p3 * .5, p3, p3 * .333
a3     oscil   k6, cpsoct((ifreq + .007) + k8), 5, .5 
k10    expseg  1, p3 * .8, p6, p3 * .2, 4
k11    oscil   k10, p7 * .97, 1, .6
k12    expseg  .001, p3 * .99, p8 * .97, p3 * .01, p8 * .97
a4     oscil   k12, cpsoct((ifreq + .005) + k11), 6, .8 
k13    expseg  .002, p3 * .91, p8 * .99, p3 * .09, p8 * .99
k14    oscil   k13, p7 * .99, 1, .4
k15    expseg  .001, p3 *.5, p6, p3 *.1, p6 *.6, p3 *.2, p6 *.97, p3 *.2, .001
a5     oscil   k15, cpsoct((ifreq + .003) + k14), 7, .9 
k16    expseg  p8 * .98, p3 * .81, .003, p3 * .19, .003
k17    oscil   k16, p7 * 1.4, 1, .2
k18    expseg  .001, p3 *.6, p6, p3 *.2, p6 *.8, p3 *.1, p6 *.98, p3 *.1, .001
a6     oscil   k18, cpsoct((ifreq + .001) + k17), 8, .1
       outs    a1 + a3 + a5, a2 + a4 + a6
       endin
</CsInstruments>
<CsScore>
f1   0  8192  10   1
f4   0  2048  10   10  0   9   0   0   8   0   7   0  4  0  2  0  1
f5   0  2048  10   5   3   2   1   0
f6   0  2048  10   8   10  7   4   3   1
f7   0  2048  10   7   9   11  4   2   0   1   1
f8   0  2048  10   0   0   0   0   7   0   0   0   0  2  0  0  0  1  1
; ==== FOAM ==== ;
; i13: p6=amp, p7=vibrat, p8=dropfrq                                             ;
i13  0    6      0     6.064   12000   184    1
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
