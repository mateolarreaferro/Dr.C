<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1602
k1        gauss     p5
k2        gauss     p6
a1        oscili    p4/2, 333, 1
a2        oscili    p4/2, 333+k1, 1
a3        oscili    p4/2, 333+k2, 1
          outs      a1+a2, a1+a3
          endin

</CsInstruments>
<CsScore>
f 1 0   8192    10  1   

i 1602  0   2   10000   33  33
i 1602  +   .   15000   33  33
i 1602  +   .   20000   33  33

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
