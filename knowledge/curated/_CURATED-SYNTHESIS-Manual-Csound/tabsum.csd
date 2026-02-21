<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1       ;;; Give a value to the increment
  kmax = 256
  knorm tabsum 1, 0, kmax
  gkinc = knorm/10
endin

instr 2
  kmax = 256
  kx = rnd(kmax)
  krnd  tabsum 1, 0, kx
  knorm tabsum 1, 0, kmax
  kvar  = krnd / knorm          ;;; now n [0,1] range
  asig  oscil  kvar, p4, 2
        out    asig
;;; Make randomness give 1 more often
  kc    tab     0, 1
        tablew  kc+gkinc, 0, 1
endin
</CsInstruments>

<CsScore>
f1 0 256 21 1  
f2 0 4096 10 1
i1 0 0.1
i2 0.1 3 440
e

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
