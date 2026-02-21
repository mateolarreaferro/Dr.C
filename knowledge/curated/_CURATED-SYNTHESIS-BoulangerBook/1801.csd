<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
          instr     1801      
kfr       linseg    p5, p3*.1, p6, p3*.9, p6           ;p5 = FREQ OF LAST NOTE
asig      oscil     p4, kfr, 1                         ;p6 = FREQ FOR THIS NOTE
          out       asig 
          endin

</CsInstruments>
<CsScore>

        

f 1 0   8193    10  1
                
i 1801  0   0.4 10000   440 440
i 1801  +   .   .       pp6 660
i 1801  +   .   .       pp6 550

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
