<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1	; unfiltered noise

kenv	linseg	0, p3*.5, 1, p3*.5, 0	;envelope
asig	rand	0.7			;white noise
	outs	asig*kenv, asig*kenv

endin

instr 2	; filtered noise

kenv	linseg	0, p3*.5, 1, p3*.5, 0	;envelope
asig	rand	0.7
kcf	line	300, p3, 2000
afilt	resonx	asig, kcf, 300, 4
asig	balance afilt, asig
	outs	asig*kenv, asig*kenv

endin
</CsInstruments>
<CsScore>

i 1 0 2
i 2 3 2

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
