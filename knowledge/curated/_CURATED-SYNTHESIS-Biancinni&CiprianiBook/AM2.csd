<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;am2.orc

	instr	1
kenv	linseg	0,p3,5000		;envelope curve, raising from 0 to 5000
amod	oscili	kenv,1000,1		;determines a variation in the mod index 
acar	oscili	5000+amod,2000,1	;(index goes 0 to 1)
	out	acar
	endin
 

</CsInstruments>
<CsScore>
;am2.sco
f1 0 4096 10 1
i1 0 4

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
