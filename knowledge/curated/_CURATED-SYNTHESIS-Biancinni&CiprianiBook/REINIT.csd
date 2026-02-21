<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;reinit.orc

	instr	1
iamp	=	ampdb(p4)
ifrq	=	cpspch(p5)
kenv	linseg	 0,.01,iamp,p3-.01,0
a1	oscili	 kenv,ifrq,1
	out	a1
	endin
 

</CsInstruments>
<CsScore>
;reinit.sco
f1	0	4096	10	1
i1	0	.1	80	8	; repeat 6 times
i1	+	.	.	.
i1	+	.	.	.
i1	+	.	.	.
i1	+	.	.	.
i1	+	.	.	.
i1	.7	.1	80	9	; repeat 3 times
i1	+	.	.	.
i1	+	.	.	.
i1	1.1	.1	80	8.04	; repeat 4 times
i1	+	.	.	.
i1	+	.	.	.
i1	+	.	.	.

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
