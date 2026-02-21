<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1 ; Create random numbers at k-rate in the range -1 to 1 at krate
   
k1 urandom                              ; with a uniform distribution.
;printks "k1=%f\\n", 0.1, k1
asig1    poscil.2, k1 * 500 + 100
asig2    poscil.2, k1 * 500 + 200
outs    asig1, asig2    
endin

</CsInstruments>
<CsScore>
i 1 0 3
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
