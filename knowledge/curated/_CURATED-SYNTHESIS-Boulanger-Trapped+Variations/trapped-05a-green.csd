<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ===== GREEN ===== ;
        instr  5                             ; p6 = AMP    
ifreq   =      cpspch(p5)                    ; p7 = REVERB SEND FACTOR
                                             ; p8 = PAN DIRECTION 
k1     line    p9, p3, 1                     ; ... (1.0 = L -> R, 0.1 = R -> L)
k2     line    1, p3, p10                    ; p9 = CARRIER FREQ  
k4     expon   2, p3, p12                    ; p10 = MODULATOR FREQ
k5     linseg  0, p3 * .8, 8, p3 * .2, 8     ; p11 = MODULATION INDEX
k7     randh   p11, k4                       ; p12 = RAND FREQ                  
k6     oscil   k4, k5, 1, .3     
kenv1  linen   p6, .03, p3, .2     
a1     foscil  kenv1, ifreq + k6, k1, k2, k7, 1
kenv2  linen   p6, .1, p3, .1
a2     oscil   kenv2, ifreq * 1.001, 1
amix   =       a1 + a2
kpan   linseg  int(p8), p3 * .7, frac(p8), p3 * .3, int(p8)
       outs    amix * kpan, amix * (1 - kpan)
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
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0     5       13.3
; ===== GREEN ===== ;
; i5: p6=amp, p7=rvbatn, p8=pan:1.0, p9=carfrq, p10=modfrq, p11=modndx, p12=rndfrq  ;
i5   0     1        7.6    6.0    5000   0.4    1.0    8      3    17  34
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
