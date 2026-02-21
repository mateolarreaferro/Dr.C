<CsoundSynthesizer>
<CsInstruments>

        0dbfs = 1
        
    instr 1
        a1 lfo 0.3, 1, 4
        a2 vactrol a1
        a3 oscili 2, 440
           out     a1*a3,a2*a3
     endin
                    
</CsInstruments>
<CsScore>
    i1 0 3
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
