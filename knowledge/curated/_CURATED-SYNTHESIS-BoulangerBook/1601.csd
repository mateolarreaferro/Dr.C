<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1601
kband     line      p5, p3, p6
aenv      linseg    0, p3*.01, 1, p3*.8, .6, p3*.1, 0
a1        rand      p4
abp       butterbp  a1, 333, kband
          out       abp*aenv
          endin 


</CsInstruments>
<CsScore>
i 1601  0  7  30000  0  666
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
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
