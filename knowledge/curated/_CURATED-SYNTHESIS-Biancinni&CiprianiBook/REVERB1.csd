<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;reverb1.orc

	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
kenv	linseg	 0,.01,iamp,.1,0,p3-.11,0	;triangle envelope
a1	oscili	kenv,ifrq,1			;direct sound
ar	reverb	a1,3				;3 seconds reverberation time
	out	a1+ar				;direct + reverb sound
	endin
 

</CsInstruments>
<CsScore>
;reverb1.sco
f1	0	4096	10	1
i1	0	1	80	8
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	.	.	9

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
