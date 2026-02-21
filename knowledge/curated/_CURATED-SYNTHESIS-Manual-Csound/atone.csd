<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs = 1

instr 1 ;white noise

asig	rand 1
	outs asig, asig

endin


instr 2 ;filtered noise

asig	rand 1
khp	init 4000
asig	atone asig, khp
	outs asig, asig

endin

</CsInstruments>
<CsScore>

i 1 0 2
i 2 2 2
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
