<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;;; GENERATION OF NOISE BANDS BY RING MODULATION ;;; FIGURE 3.25 FROM DODGE & JERSE, P.92 


          instr 1
kramp     linseg    0,p3/2,p4,p3/2,0
krcps     =         p5*.05
kamp      randi     kramp,krcps
kfreq     =         p5
aosc      oscil     kamp,kfreq,1
aout      =         aosc
          out       aout
          endin


</CsInstruments>
<CsScore>


;;; SCORE FOR DODGE FIGURE 3.25

f1 0 8192 10 1      ; SINE

;p1   p2    p3     p4    p5
;INST START LENGTH AMP   FREQ
  i1  0.00  1.00   15000 300

e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
