<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1.0

instr 1
	krate linseg 1, p3, 40
	ktrig metro krate
	kx sc_phasor ktrig, krate/kr, 0, 1
	asine oscili 0.2, kx*500+500
	outch 1, asine
endin
	
instr 2
	krate linseg 1, p3, 40
	atrig = mpulse(1, 1/krate)
	ax sc_phasor atrig, krate/sr, 0, 1
	asine oscili 0.2, ax*500+500
	outch 2, asine
endin

</CsInstruments>
<CsScore>
i1 0 20
i2 0 20
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
