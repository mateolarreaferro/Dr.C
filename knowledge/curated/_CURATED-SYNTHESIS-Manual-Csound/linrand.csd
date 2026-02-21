<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1  	; every run time same values

klin	linrand 100
	printk .2, klin			; look 
aout	oscili 0.8, 440+klin, 1		; & listen
	outs	aout, aout
endin

instr 2		; every run time different values

	seed 0
klin	linrand 100
	printk .2, klin			; look 
aout	oscili 0.8, 440+klin, 1		; & listen
	outs	aout, aout
endin

</CsInstruments>
<CsScore>
; sine wave
f 1 0 16384 10 1

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
