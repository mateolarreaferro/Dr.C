<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
        instr   2001
itwopi  =       2*3.141592653589793238
a1      phasor  440
a2      =       32767*sin(itwopi*a1)
        out     a2
        endin

</CsInstruments>
<CsScore>
    

i 2001  0   5
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
