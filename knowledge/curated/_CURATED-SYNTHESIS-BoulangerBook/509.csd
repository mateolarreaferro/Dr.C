<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   509
k1      expon   p4, p3, .001
a1      foscil  k1,cpspch(p5), 1, 3,11,1
        out     a1
        endin

</CsInstruments>
<CsScore>
f1  0 4096 10 1

r3  CNT         
i 509   0   [0.3*$CNT.]      10000  6.0
i 509   +   [($CNT./3)+0.2]  15000  7.0
e       

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1289</x>
 <y>61</y>
 <width>396</width>
 <height>645</height>
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
