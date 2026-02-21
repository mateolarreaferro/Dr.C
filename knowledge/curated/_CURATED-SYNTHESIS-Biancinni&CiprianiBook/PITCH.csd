<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr 1
ifreq 	= 	cpspch(p5)
a1	oscil	p4, ifreq, 1
	out 	a1
	endin
 


</CsInstruments>
<CsScore>
;pitch.sco
f1	0	4096	10	1
i1	0	1	10000	8.00
i1	1	1	10000	8.02
i1	2	1	10000	8.04
i1	3	1	10000	8.00

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
