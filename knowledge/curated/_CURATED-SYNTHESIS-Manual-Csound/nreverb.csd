<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

gaout init  0

instr 1
a1	oscili	.5, 440
outs	a1, a1
 
gaout = gaout+a1
endin

instr 99

a2	nreverb	gaout, 2, .3
outs	a2*.15, a2*.15		;volume of reverb		
	 
gaout = 0
endin

</CsInstruments>
<CsScore>

i 1 0 .5
i 1 1 .5
i 1 2 .5
i 1 3 .5
i 1 4 .5
i 99 0 9 
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
