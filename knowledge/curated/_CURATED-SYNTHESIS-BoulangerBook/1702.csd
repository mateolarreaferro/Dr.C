<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
          instr     1702      
kgate     oscil     p4, 4, 2            ; ifn 2 HAS LINEAR ENVELOPE SHAPE; AMP=p4
asig      oscili    kgate, 1000, 1      ; MAKE A 1 KHz BEEP TONE, USING FUNCTION 1
          out       asig 
          endin


</CsInstruments>
<CsScore>
f 1 0   8192    10  1                       
;LINEAR ENVELOPE FUNCTION                                       
f 2 0   512 7   0   41  1   266 1   205 0
;         START  DUR          AMP         
i 1702      0      4       20000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>2</height>
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
