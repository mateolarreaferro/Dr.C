<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr      1903
areedbell init  0
ifqc      =          cpspch(p5)
ifco      =          p7
ibore     =          1/ifqc-15/sr

; I GOT THE ENVELOPE FROM PERRY COOKE'S CLARINET
kenv1     linseg     0, .005, .55 + .3*p6, p3 - .015, .55 + .3*p6, .01, 0
kenvibr   linseg     0, .1, 0, .9, 1, p3-1, 1    ; VIBRATO ENVELOPE

; SUPPOSEDLY HAS SOMETHING TO DO WITH REED STIFFNESS?
kemboff   =          p8

; BREATH PRESSURE
avibr     oscil      .1*kenvibr, 5, 3
apressm   =          kenv1 + avibr

; REFLECTION FILTER FROM THE BELL IS LOWPASS
arefilt   tone      areedbell, ifco

; THE DELAY FROM BELL TO REED
abellreed delay     arefilt, ibore

; BACK PRESSURE AND REED TABLE LOOK UP
asum2     =         - apressm -.95*arefilt - kemboff
areedtab  tablei    asum2/4+.34, p9, 1, .5
amult1    =         asum2 * areedtab

; FORWARD PRESSURE
asum1     =         apressm + amult1

areedbell delay     asum1, ibore

aofilt    atone     areedbell, ifco

          out       aofilt*p4

          endin

</CsInstruments>
<CsScore>
; TABLE FOR REED PHYSICAL MODEL
f1 0 256 7 1 80 1 156 -1 40 -1

; SINE
f3 0 1024 10 1

t 0 600

; CLARINET
;   START  DUR    AMP      PITCH   PRESS  FILTER     EMBOUCHURE  REED TABLE
;               (20000) (8.00-9.00) (0-2) (500-1200)   (0-1)      
i 1903    0    16     16000      8.00     1.5  1000         .2            1
i 1903    +     4     .         8.01     1.8  1000         .2            1
i 1903    .     2     .         8.03     1.6  1000         .2            1
i 1903    .     2     .         8.04     1.7  1000         .2            1
i 1903    .     2     .         8.05     1.7  1000         .2            1
i 1903    .     2     .         9.03     1.7  1000         .2            1
i 1903    .     4     .         8.00     1.7  1000         .2            1
i 1903    +    16     .         9.00     1.8  1000         .2            1

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
 <height>180</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
