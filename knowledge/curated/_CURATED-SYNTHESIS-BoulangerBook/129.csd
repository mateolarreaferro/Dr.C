<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr	129
idur	=		p3
iamp	=		p4
ifrq	=		p5
iatk	=		p6
irel	=		p7
icut1	=		p8
icut2	=		p9
kenv	linen	iamp, iatk, idur, irel
kcut	expon	icut1, idur, icut2
anoise	rand	ifrq	
afilt	tone	anoise, kcut
       	out  	afilt*kenv
		dispfft	afilt, idur, 4096
		endin
		
		instr	130
idur	=		p3
iamp	=		p4
ifrq	=		p5
iatk	=		p6
irel	=		p7
icut1	=		p8
icut2	=		p9
kenv	linen	iamp, iatk, idur, irel
kcut	expon	icut1, idur, icut2
anoise	rand	ifrq	
afilt2	tone	anoise, kcut
afilt1	tone	afilt2, kcut
       	out  	afilt1*kenv
		dispfft	afilt1, idur, 4096
		endin
		
		instr	131
idur	=		p3
iamp	=		p4
ifrq	=		p5
iatk	=		p6
irel	=		p7
icut1	=		p8
icut2	=		p9
kenv	linen	iamp, iatk, idur, irel
kcut	expon	icut1, idur, icut2
anoise	rand	ifrq	
afilt3	tone	anoise, kcut
afilt2	tone	afilt3, kcut
afilt1	tone	afilt2, kcut
       	out  	afilt1*kenv
		dispfft	afilt1, idur, 4096
		endin
		
		instr	132
idur	=		p3
iamp	=		p4
ifrq	=		p5
iatk	=		p6
irel	=		p7
icut1	=		p8
icut2	=		p9
kenv	linen	iamp, iatk, idur, irel
kcut	expon	icut1, idur, icut2
anoise	rand	ifrq	
afilt4	tone	anoise, kcut
afilt3	tone	afilt4, kcut
afilt2	tone	afilt3, kcut
afilt1	tone	afilt2, kcut
       	out  	afilt1*kenv
		dispfft	afilt1, idur, 4096
		endin

</CsInstruments>
<CsScore>
a 0 0 2

;ins	st		dur amp frq     atk	rel	cut1	cut2	
;==================================================
i 129		2		1.5	3	20000	.1	.1	 500	500
i 130		4		1.5	3	20000	.1	.1	 500	500			
i 131		6		1.5	3	20000	.1	.1	 500	500
i 132		8		1.5	3	20000	.1	.1	 500	500
i 129		10		1.2	1	20000	.01	.01	 5000	40
i 130		11		1.2	1	20000	.01	.01	 5000	40				
i 131		12		1.2	1	20000	.01	.01	 5000	40
i 132		13		1.2	1	20000	.01	.01	 5000	40
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
 <height>240</height>
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
