<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

instr 1

idb  =  p4
iamp =  ampdb(idb)
asig	oscil iamp, 220
	print iamp
	outs  asig, asig
endin


</CsInstruments>
<CsScore>
i 1 0 1 50
i 1 + 1 90
i 1 + 1 68
i 1 + 1 80

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
