<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>



instr 1

idb  =  p4
iamp =  ampdbfs(idb)
asig	oscil iamp, 220, 1
	print iamp
	outs  asig, asig
endin


</CsInstruments>
<CsScore>
;sine wave.
f 1 0 16384 10 1

i 1 0 1 -1
i 1 + 1 -5
i 1 + 1 -6
i 1 + 1 -20
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
