<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   404                         
a1      oscil   5, 1, 1             ; GENERATE THE VIBRATO
a2      oscil   15000, 440+a1, 1    ; USE IT ON AN OSCILATOR
        out     a2                  ; AND PLAY THE RESULT
        endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1 
i 404  0  10 
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1323</x>
 <y>61</y>
 <width>396</width>
 <height>687</height>
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
