<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ===== TAUPE ===== ;
        instr  10                            
ifreq   =      cpspch(p5)                    ; p5 = FREQ     
                                             ; p6 = AMP 
k2      randh  p8, p9, .1                    ; p7 = REVERB SEND FACTOR 
k3      randh  p8 * .98, p9 * .91, .2        ; p8 = RAND AMP     
k4      randh  p8 * 1.2, p9 * .96, .3        ; p9 = RAND FREQ    
k5      randh  p8 * .9, p9 * 1.3      
kenv    linen  p6, p3 *.1, p3, p3 * .8                         
a1      oscil  kenv, ifreq + k2, 1, .2             
a2      oscil  kenv * .91, (ifreq + .004) + k3, 2, .3
a3      oscil  kenv * .85, (ifreq + .006) + k4, 3, .5
a4      oscil  kenv * .95, (ifreq + .009) + k5, 4, .8
amix    =      a1 + a2 + a3 + a4
        outs   a1 + a3, a2 + a4
garvb   =      garvb + (amix * p7)
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
f2   0  512   10   10  8   0   6   0   4   0   1
f3   0  512   10   10  0   5   5   0   4   3   0   1
f4   0  2048  10   10  0   9   0   0   8   0   7   0  4  0  2  0  1
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0   5.8     2
; ===== TAUPE ===== ;
; i10: p4=0,p5=frq,p6=amp,p7=rvbsnd,p8=rndamp,p9=rndfrq    
i10  0     1.6     0.4    9.01    6000   0.3    21     31
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
