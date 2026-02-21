<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1811
asig      oscil     p4, p5, 1
          out       asig
          endin      

          instr     1812
asig      oscil     p4, p5, 2
          out       asig
          endin

</CsInstruments>
<CsScore>
f 1 0   8193    10  1
f 2 0   2   10  1 

i 1811  0   5   10000   240
i 1812  0   5   10000   367
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
