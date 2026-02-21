<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;reverb2.orc


garev	init	0

	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
kenv	linseg	0,.01,iamp,.1,0,p3-.11,0	;envelope
a1	oscili	kenv,ifrq,1			;signal to be reverberated
garev	=	garev+a1			;turn audio var to global var
	out	a1				;output (only direct sound)
	endin

	instr	99
arev	reverb	 garev,3
	out	arev				;output (only reverb sound)
garev	=	0				;clear garev, to avoid accumulation
	endin
 

</CsInstruments>
<CsScore>
;reverb2.sco
f1	0	4096	10	1
i1	0	1	80	8
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	.	.	9
i99	0	10

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
