<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
;===== BLACK ======;
       instr   4                             ; p6 = AMP 
ifreq  =       cpspch(p5)                    ; p7 = FILTERSWEEP STRTFREQ
                                             ; p8 = FILTERSWEEP ENDFREQ
k1     expon   p7, p3, p8                    ; p9 = BANDWIDTH
anoise rand    8000                          ; p10 = REVERB SEND FACTOR 
a1     reson   anoise, k1, k1 / p9, 1            
k2     oscil   .6, 11.3, 1, .1               
k3     expseg  .001,p3 * .001, p6, p3 * .999, .001   
a2     oscil   k3, ifreq + k2, 15 
       outs   (a1 * .8) + a2, (a1 * .6) + (a2 * .7)
garvb  =      garvb + (a2 * p10)
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
f15  0  8192  9    1   1   90 
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0     4       22
; ==== BLACK ==== ;
; i4: p6=amp, p7=fltrswp:strtval, p8=fltrswp:endval, p9=bdwth, p10=rvbsnd
i4   0     1       0      3.75   28200   6000   4000   30     0.5
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
