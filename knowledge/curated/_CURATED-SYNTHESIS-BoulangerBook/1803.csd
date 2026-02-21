<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gkfr      init      0                        ; INITIAL FREQUENCY
gklfo     init      0                        ; INITIAL LFO VALUE

          instr     1804 
gkfr      linseg    p5, p3*.1, p6, p3*.9, p6
          endin     

          instr     1805
gklfo     oscil     p4, p5, 1
          endin     

          instr     1806
kenv      linen     p4, 0.01, p3, 0.01
asig      oscil     kenv, gkfr*(1+gklfo), 1
          out       asig
          endin

</CsInstruments>
<CsScore>


f 1 0   8193    10  1

i 1804  0   0.4 0   440 440
i 1804  +   .   .   pp6 660
i 1804  +   .   .   pp6 550
i 1805  0   1.2  0.14   4.5
i 1806  0   1.2 10000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>8</height>
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
