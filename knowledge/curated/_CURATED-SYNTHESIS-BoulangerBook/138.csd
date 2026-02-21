<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr 		= 		44100
kr 		= 		4410
ksmps 	= 		10
nchnls 	= 		2

garvb	init	0

		instr   138 ;sweeping fm with vibrato & discrete pan
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
ifc		=		p6
ifm		=		p7
iatk	=		p8
irel	=		p9
indx1	=		p10
indx2	=		p11
indxtim	=		p12	
ilfodep	=		p13
ilfofrq	=		p14		
ipan	=		p15		
irvbsnd	=		p16		
kampenv	expseg	.01, iatk, iamp, idur/9, iamp*.6, idur-(iatk+irel+idur/9), iamp*.7, irel,.01
klfo	oscil	ilfodep, ilfofrq, 1
kindex  expon  	indx1, indxtim, indx2
asig   	foscil 	kampenv, ifrq+klfo, ifc, ifm, kindex, 1
		outs     asig*ipan, asig*(1-ipan)
garvb	=		garvb+(asig*irvbsnd)
		endin
				
		instr 	199
idur	=		p3					
irvbtim	=		p4
ihiatn	=		p5
arvb	nreverb	garvb, irvbtim, ihiatn
		outs		arvb, arvb
garvb	=		0
		endin


</CsInstruments>
<CsScore>
f1  0 4096 10   1    

;		st	dur	rvbtim	hfroll	
;===================================================================
i 199 	0	22	1.3  	.1

;		st	dr 	amp	frq		fc	fm	atk	rel	ndx1	ndx2	ndxtim  lfodep	lfofrq	pan	rvbsnd
;=================================================================================
i 138	0	2	80	8.09	1	2	.01	.2	20		4		.5		7		5		1	.1  
i 138	2	2	80	.		2	1	. 	. 	10		1		.8		.		6		0	.2  
i 138	5	.2	80	.		1	2	. 	.1	30		.		.01		9		4		1	.1  
i 138	+	.	79	.		2	1	.	.	<		<		<		<		<		<	< 
i 138	+	.	78	.		1	3	.	.	.		.		.		.		.		.	.  
i 138	+	.	77	.		3	1	.	.	.		.		.		.		.		.	.  
i 138	+	.	76	.		1	4	.	.	.		.		.		.		.		.	.  
i 138	+	.	75	.		4	1	.	.	.		.		.		.		.		.	.  
i 138	+	.	74	.		1	5	.	.	.		.		.		.		.		.	.  
i 138	+	.	73	.		5	1	.	.	.		.		.		.		.		.	.  
i 138	+	.	72	.		1	6	.	.	.		.		.		.		.		.	.  
i 138	+	1	71	.		6	1	.	.	10		3		.2		4		10		0	.04  
i 138	+	.2	71	.		6	1	.	.	<		<		<		<		<		<	< 
i 138	+	.	72	.		1	6	.	.	.		.		.		.		.		.	.  
i 138	+	.	73	.		5	1	.	.	.		.		.		.		.		.	.  
i 138	+	.	74	.		1	5	.	.	.		.		.		.		.		.	.  
i 138	+	.	75	.		4	1	.	.	.		.		.		.		.		.	.  
i 138	+	.	76	.		1	4	.	.	.		.		.		.		.		.	.  
i 138	+	.	77	.		3	1	.	.	.		.		.		.		.		.	.  
i 138	+	.	78	.		1	3	.	.	.		.		.		.		.		.	.  
i 138	+	.	79	.		2	1	.	.	.		.		.		.		.		.	. 
i 138	+	.2	80	.		1	2	. 	.1	30		1		.01		9		4		1	.1  
i 138	+	2	80	.		2	1	.  	.2	10		4		.8		7		6		1	.2  
i 138	2.5	4	80	.		1	2	. 	. 	20		4		.5		.		5		0	.1  
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>384</width>
 <height>150</height>
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
