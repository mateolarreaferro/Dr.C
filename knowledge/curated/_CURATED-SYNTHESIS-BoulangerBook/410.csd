<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   410         
a1      oscil   p5, 440, 1          ; GENERATE A SIGNAL
a2      =       sin(a1)             ; USE A VALUE CONVERTER
        out     a2*p4               ; AND PLAY THE OUTPUT
        endin

</CsInstruments>
<CsScore>
f 1 0 512 10 1

i 410 0 2 10000 1
s
i 410 0 2 10000 10 
s
i 410 0 2 10000 100


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
