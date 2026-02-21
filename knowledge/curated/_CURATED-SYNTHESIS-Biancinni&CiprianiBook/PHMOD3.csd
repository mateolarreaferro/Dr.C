<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	3
ifrq	=	cpspch(p5)
idel1	=	1/ifrq
idel2	=	1/ifrq*p7
iamp	=	ampdb(p4)
afilt1	init	0
afilt2	init	0
ifeed	=	p6
kexc	linseg	1,.01,0,p3-.01,0		
aexc	rand	kexc
asum	=	aexc +afilt1*ifeed+afilt2*ifeed
adel1	delay	asum,idel1
afilt1	tone	adel1,p8
adel2	delay	asum,idel2
afilt2	tone	adel2,p9
aout	=	(afilt1+afilt2)*iamp
aout	atone	aout,30
out		aout
	endin 
 

</CsInstruments>
<CsScore>
;phmod3.sco
;instrument 3: STROKEN PLATE
;ins	act	dur	dB	pitch	feed	ratio	      fc1	fc2
i3	0	3	86	7	.5	1.02		18000	18000
i3	+	.	.	7	.	1.07		. 	.
i3	+	.	.	7	.	1.11		. 	.
i3	+	.	.	7	.	1.17		. 	.
i3	+	.	.	7	.	1.27		. 	.
i3	+	.	.	7	.	1.47		. 	.
i3	+	.	.	7	.	1.77		. 	.
i3	+	.	.	7	.	1.87		. 	.
i3	+	.	.	7	.	2.17		. 	.

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
