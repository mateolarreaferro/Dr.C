<CsoundSynthesizer>
<CsInstruments>
garvb  init     0
; ==== TEAL ==== ;
       instr   12                            ; p6 = AMP
ifreq  =       octpch(p5)                    ; p7 = FILTERSWEEP STARTFREQ
ifuncl =       8                             ; p8 = FILTERSWEEP PEAKFREQ
                                             ; p9 = BANDWDTH
k1     linseg  0, p3 * .8, 9, p3 * .2, 1     ; p10 = REVERB SEND FACTOR
k2     phasor  k1                         
k3     table   k2 * ifuncl, 22                    
k4     expseg  p7, p3 * .7, p8, p3 * .3, p7 * .9     
anoise rand    8000                       
aflt   reson   anoise, k4, k4 / p9, 1
kenv1  expseg  .001, p3 *.1, p6, p3 *.1, p6 *.5, p3 *.3, p6 *.8, p3 *.5,.001
a3     oscil   kenv1, cpsoct(ifreq + k3) + aflt * .8, 1
       outs    a3,(a3 * .98) + (aflt * .3)
garvb  =       garvb + (anoise * p10)
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
f22  0  9    -2   .001 .004 .007 .003 .002 .005 .009 .006
; ==== SWIRL ==== ;
; i99: p4=pancps  ;
i99  0.1   1.1     243
; ==== TEAL ==== ;
; i12: p6=amp, p7=swpstrt, p8=swppeak, p9=bndwth, p10=rvbsnd
i12  0.1   1.1     11     11.02    500   1500   300    4      0.5
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
