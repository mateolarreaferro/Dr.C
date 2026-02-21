<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   508
k1      expon   p4, p3, .001
a1      foscil  k1,cpspch(p5),1,.5,p6,1
        out     a1
        endin

</CsInstruments>
<CsScore>
f1  0 4096 10 1


r4 NN
i 508 0 .25 10000   8.00    2
i .   +  .  >       8.04    3
i .   +  .  >       8.02    5
i .   +  .  20000   7.07    8
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1289</x>
 <y>61</y>
 <width>388</width>
 <height>585</height>
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
