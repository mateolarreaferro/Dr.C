<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

; plays a sine wav, forces a stop after 2 seconds
instr 1
	; generate a line from 0 to 1 over 2 seconds
	kStop line 0, 2, 1

	; launch instrument 2 once kStop signal is greater than 1
	if(kStop>=1) then
		schedulek 2, 0, 1
	endif

	; print kStop signal every .1 seconds
	printk .1, kStop

	; make some noise
	aSig oscil 1, 440
	outs aSig, aSig
endin

; forces an instant exit of csound
instr 2
	exitnow
endin

</CsInstruments>
<CsScore>
; play oscil instrument infinitely
i 1 0 z
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
