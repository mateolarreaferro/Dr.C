<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
        instr   1413
k1      linseg  100, p3/4, 0, p3/4, 100, p3/2, 100  ;kband
k2      linseg  .003, p3/2, .003,p3/4, .01, p3/4, .003  ;kris
a1      fof     15000, 100, 440, 0, k1, k2, .02, .007, 3, 1, 2, p3  
        out     a1
        endin

</CsInstruments>
<CsScore>
f 1 0   4096    10  1
f 2 0   1024    19  .5 .5 270 .5
                
i 1413   0   10
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
