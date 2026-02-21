<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1820
igm       =         1.618
klin      line      3, p3, 0
afm1      foscil    1, p5, 1, p5*igm, klin, 1
asig      linen     afm1, 0.01, p3, 0.04
          out       asig*p4
          endin


</CsInstruments>
<CsScore>
f 1 0   8193    10  1

i 1820  0   3   20000   125
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
