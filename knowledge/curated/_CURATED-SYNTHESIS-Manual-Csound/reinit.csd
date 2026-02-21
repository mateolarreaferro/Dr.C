<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

reset:
        timout 0, p3/p4, contin         
        reinit reset

contin:
        kLine expon 440, p3/p4, 880
        aSig poscil 1, kLine
        outs aSig, aSig
        rireturn

endin

</CsInstruments>
<CsScore>

i1 0 10 10
i1 + 10 50      
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
