<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
;===== BLUE ===== ;
       instr 2                               ; p6 = AMP   
ifreq  =        cpspch(p5)                   ; p7 = REVERB SEND FACTOR
                                             ; p8 = LFO FREQ 
k1     randi    1, 30                        ; p9 = NUMBER OF HARMONIC      
k2     linseg   0, p3 * .5, 1, p3 * .5, 0    ; p10 = SWEEP RATE   
k3     linseg   .005, p3 * .71, .015, p3 * .29, .01
k4     oscil    k2, p8, 1,.2                   
k5     =        k4 + 2
ksweep linseg   p9, p3 * p10, 1, p3 * (p3 - (p3 * p10)), 1 
kenv   expseg   .001, p3 * .01, p6, p3 * .99, .001
asig   gbuzz    kenv, ifreq + k3, k5, ksweep, k1, 15 
       outs     asig, asig
garvb  =        garvb + (asig * p7) 
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
i99  0.0   6.5     2
;===== BLUE ===== ;
; i2:  p6=amp, p7=rvbsnd, p8=lfofrq, p9=num of harmonics, p10=sweeprate
i2   0.0   4       0      8.029    16600    0.6    23     10     0.52
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
