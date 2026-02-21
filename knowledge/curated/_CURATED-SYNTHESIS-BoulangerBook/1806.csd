<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gkvib     init      0    

          instr     1813                     ; VIBRATO
kline     line      p5, p3, p6               ; FROM p5 TO p6 IN p3
kvb       oscil     1, kline, 1    
gkvib     =         kvb*0.01                 ; CHANGE RANGE
          endin          

          instr     1814
asig      oscil     p4, p5*(1+gkvib), 1
          out       asig
          endin     

          instr     1815
asig      oscil     p4, p5*(1+gkvib), 2
          out       asig
          endin

</CsInstruments>
<CsScore>
f 1 0   8193    10  1
f 2 0   2   10  1 

i 1813  0   5   0    3.00  6.00
i 1814  0   5   10000   240
i 1815  0   5   10000   367
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
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
