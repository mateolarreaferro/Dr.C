<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr   133
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		p5
icut1	=		p6				
icut2	=		p7
iresgn	=		p8
kcut	expon	icut1, idur, icut2
aplk 	pluck 	iamp, ifrq, ifrq, 0, 1
abpf	butterbp	aplk, kcut, kcut*.2
alpf	butterlp	aplk, kcut				
amix	=     alpf+(abpf*iresgn)
		out		amix
		dispfft	amix, idur, 1024
		endin

</CsInstruments>
<CsScore>
;ins	st		dur ampdb 	frq		fc1		fc2	resgn
;======================================================================
i 133		0		.1	90		440		1000	20	 1
i.		+		.	<		<		<		.	 <
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	60		55		60		20	 30
i.		.		.	<		<		<		<	 <
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		.	.		.		.		.	 .
i.		.		5	80		880		2000	200	 5
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
