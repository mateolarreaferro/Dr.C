<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1
	
instr 1

ienv = p4				;choose envelope in score

if (ienv == 0) kthen 	
  kenv adsr 0.05, 0.05, 0.95, 0.05	;sustained envelope
elseif (ienv == 1) kthen 
  kenv adsr 0.5, 1, 0.5, 0.5		;triangular envelope
elseif (ienv == 2) kthen 
  kenv adsr 1, 1, 1, 0			;ramp up
endif

aout   vco2 .1, 110, 10
aout   = aout * kenv
       outs aout, aout

endin

</CsInstruments>
<CsScore>

i1 0 2  0
i1 3 2  1
i1 6 2  2

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
