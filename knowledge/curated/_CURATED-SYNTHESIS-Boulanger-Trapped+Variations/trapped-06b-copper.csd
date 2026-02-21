<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ===== COPPER ===== ;
        instr  6                             ; p5 = FILTERSWEEP STARTFREQ
ifuncl  =      8                             ; p6 = FILTERSWEEP ENDFREQ
                                             ; p7 = BANDWIDTH
k1      phasor p4                            ; p8 = REVERB SEND FACTOR
k2      table  k1 * ifuncl, 19               ; p9 = AMP       
anoise  rand   8000                        
k3      expon  p5, p3, p6                         
a1      reson  anoise, k3 * k2, k3 / p7, 1 
kenv    linen  p9, .01, p3, .05
asig    =      a1 * kenv
        outs   asig, asig
garvb   =      garvb + (asig * p8)
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
f1   0  8192 10   1
f19  0  16   2    1   7   10  7   6   5   4   2   1   1  1  1  1  1  1  1
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0    7       7
; ===== COPPER ===== ;
; i6: p5=swpfrq:strt, p6=swpfrq:end, p7=bndwth, p8=rvbsnd, p9=amp
i6   0    4.3     17     6000     9000   100    0.4    9.9
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
