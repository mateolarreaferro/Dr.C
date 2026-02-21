<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	; White noise signal

asig rand 0.5
     outs asig, asig

endin



instr 2	; filtered noise

asig rand 0.7
alp  butterlp asig, 1000	  ;cutting frequencies above 1 KHz
     outs alp, alp

endin

</CsInstruments>
<CsScore>

i 1 0 2
i 2 2.5 2
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
