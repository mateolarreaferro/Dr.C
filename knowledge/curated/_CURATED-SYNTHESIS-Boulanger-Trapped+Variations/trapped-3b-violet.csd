<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ==== VIOLET ==== ;
       instr   3                             ; p6 = AMP
ifreq  =       cpspch(p5)                    ; p7 = REVERB SEND FACTOR
                                             ; p8 = RAND FREQ
k3     expseg  1, p3 * .5, 30 ,p3 * .5, 2            
k4     expseg  10, p3 *.7, p8, p3 *.3, 6         
k8     linen   p6, p3 * .333, p3, p3 * .333
k13    line    0, p3, -1
k14    randh   k3, k4, .5
a1     oscil   k8, ifreq + (p5 * .05) + k14 + k13, 1, .1 
k1     expseg  1, p3 * .8, 6, p3 *.2, 1
k6     linseg  .4, p3 * .9, p8 * .96, p3 * .1, 0
k7     linseg  8, p3 * .2, 10, p3 * .76, 2
kenv2  expseg  .001, p3 * .4, p6 * .99, p3 * .6, .0001
k15    randh   k6, k7
a2     buzz    kenv2, ifreq + (p5 * .009) + k15 + k13, k1, 1, .2 
kenv1  linen   p6, p3 * .25, p3, p3 * .4
k16    randh   k4 * 1.4, k7 * 2.1, .2
a3     oscil   kenv1, ifreq + (p5 * .1) + k16 + k13, 16, .3
amix   =       a1 + a2 + a3
       outs    a1 + a3, a2 + a3
garvb  =       garvb + (amix * p7)
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
f16  0  2048  9    1   3   0   3   1   0   6   1   0
; ==== SWIRL ==== ;
; i99: p4=pancps  ; 
i99  0    9.5     1
; ==== VIOLET ==== ;
; i3:  p6=amp, p7=rvbsnd, p8=rndfrq 
i3   0    6.5     0      5.067   4000    0.6    47
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
