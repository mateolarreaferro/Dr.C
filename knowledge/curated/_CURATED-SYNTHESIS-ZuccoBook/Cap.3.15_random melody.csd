<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.15_random melody

0dbfs = 1

instr 1

k1	randomh	60,1200,6

a1	oscil	.7,k1,1

out	a1

endin

</CsInstruments>
<CsScore>
f1	0	4096	10	1

i1	0	40

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
