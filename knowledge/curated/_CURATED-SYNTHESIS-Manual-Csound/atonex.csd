<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1	; unfiltered noise

asig	rand	0.7	; white noise
	outs	asig, asig

endin

instr 2	; filtered noise

asig	rand	0.7
khp	line	100, p3, 3000
afilt	atonex	asig, khp, 32

; Clip the filtered signal's amplitude to 85 dB.
a1	clip afilt, 2, ampdb(85)
	outs a1, a1
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
