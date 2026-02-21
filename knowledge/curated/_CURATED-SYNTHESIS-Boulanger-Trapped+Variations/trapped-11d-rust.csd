<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
gadel  init     0
; ==== RUST ==== ;
       instr   11                            ; p4 = DELAY SEND FACTOR
ifreq  =       cpspch(p5)                    ; p5 = FREQ             
                                             ; p6 = AMP
k1     expseg  1, p3 * .5, 40, p3 * .5, 2    ; p7 = REVERB SEND FACTOR
k2     expseg  10, p3 * .72, 35, p3 * .28, 6
k3     linen   p6, p3* .333, p3, p3 * .333
k4     randh   k1, k2, .5
a4     oscil   k3, ifreq + (p5 * .05) + k4, 1, .1 
k5     linseg  .4, p3 * .9, 26, p3 * .1, 0
k6     linseg  8, p3 * .24, 20, p3 * .76, 2
k7     linen   p6, p3 * .5, p3, p3 * .46
k8     randh   k5, k6, .4
a3     oscil   k7, ifreq + (p5 * .03) + k8, 14, .3 
k9     expseg  1, p3 * .7, 50, p3 * .3, 2
k10    expseg  10, p3 * .3, 45, p3 * .7, 6
k11    linen   p6, p3 * .25, p3, p3 * .25
k12    randh   k9, k10, .5
a2     oscil   k11, ifreq + (p5 * .02) + k12, 1, .1 
k13    linseg  .4, p3 * .6, 46, p3 * .4, 0
k14    linseg  18, p3 * .1, 50, p3 * .9, 2
k15    linen   p6, p3 * .2, p3, p3 * .3
k16    randh   k13, k14, .8
a1     oscil   k15, ifreq + (p5 * .01) + k16, 14, .3 
amix   =       a1 + a2 + a3 + a4
       outs    a1 + a3, a2 + a4
garvb  =       garvb + (amix * p7)
gadel  =       gadel + (amix * p4)
       endin
; ===== SMEAR ===== ;
        instr  98
asig    delay  gadel, .08
        outs   asig, asig
gadel   =      0
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
f14  0  512   9    1   3   0   3   1   0   9  .333   180
; ==== SMEAR ==== ;
i98  0      11
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0      11      0.618
; ==== RUST ==== ;
; i11: p4=delsnd, p5=frq, p6=amp, p7=rvbsnd
i11  0    8       0.42    9.02     2200   0.52
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
