<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   413     
k1      line    2, p3, 1            ; GENERATE THE INVERSE OF THE ENVELOPE
a1      oscil   32000, 440*k1, 1    ; APPLY IT WITH MULTIPLICATION ...
        out     a1                  ; ... INSTEAD OF DIVISION
        endin       

</CsInstruments>
<CsScore>
f 1 0 4096 10 1

i 413 0 5
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1289</x>
 <y>61</y>
 <width>396</width>
 <height>645</height>
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
