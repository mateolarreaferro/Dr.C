<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1

asig1 vco  1, 440, 2, 0.4, 1
asig2 vco  1, 800, 3, 0.5, 1
asig  =    asig1+asig2              ; will go out of range
outs  tanh(asig), tanh(asig)        ; but tanh is a limiter

endin

</CsInstruments>
<CsScore>
f1 0 65536 10 1 ; sine

i 1 0 1
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
