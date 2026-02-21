<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

seed 0

instr 1

kmin    init 220; Choose a random frequency between 220 and 440 Hz.
kmax    init 440
kcps    init 10; Generate new random numbers at 10 Hz.
imode   =    p4
ifstval =    p5
  
;printf_i "\nMode: %d\n", 1, imode
k1 randomh kmin, kmax, kcps, imode, ifstval
;printk2 k1
asig    poscil  1, k1
outs    asig, asig
endin

</CsInstruments>
<CsScore>
; each time with a different mode.
i 1 0 1
i 1 2 1 2 330
i 1 4 1 3
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
