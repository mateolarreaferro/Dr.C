<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

idmp = p4
a1   line 2, p3, 2			;preset amplitude increase
a2   sandpaper 1, 0.01, 128, idmp	;sandpaper needs a little amp help at these settings
asig product a1, a2			;increase amplitude
     outs asig, asig
          
endin
</CsInstruments>
<CsScore>
i1 0 1 0.5
i1 + 1 0.95

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
