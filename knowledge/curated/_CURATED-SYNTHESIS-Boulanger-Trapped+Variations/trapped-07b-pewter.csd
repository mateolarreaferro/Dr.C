<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ==== PEWTER ==== ;
       instr   7                             ; p4 = AMP
ifuncl =       512                           ; p5 = FREQ
ifreq  =       cpspch(p5)                    ; p6 = BEGIN PHASE POINT        
                                             ; p7 = END PHASE POINT
a1     oscil   1, ifreq, p10                 ; p8 = CTRL OSC AMP (.1 -> 1)   
k1     linseg  p6, p3 * .5, p7, p3 * .5, p6  ; p9 = CTRL OSC FUNC      
a3     oscili  p8, ifreq + k1, p9            ; p10 = MAIN OSC FUNC (f2 OR f3)
a4     phasor  ifreq                         ; ...(FUNCTION LENGTH MUST BE 512!) 
a5     table   (a4 + a3) * ifuncl, p10       ; p11 = REVERB SEND FACTOR    
kenv   linen   p4, p3 * .4, p3, p3 * .5            
asig   =       kenv * ((a1 + a5) * .2)                  
       outs    asig, asig
garvb  =       garvb + (asig * p11)                      
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
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0     8     1.7
; ==== PEWTER ==== ;
; i7: p4=amp, p5=frq, p6=strtphse, p7=endphse, p8=ctrlamp(.1-1), p9=ctrlfnc, p10=audfnc(f2,f3,f14, p11=rvbsnd  
i7   0     5     60000   3   .99   0.1    0.63    3      2    0.12                            
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
