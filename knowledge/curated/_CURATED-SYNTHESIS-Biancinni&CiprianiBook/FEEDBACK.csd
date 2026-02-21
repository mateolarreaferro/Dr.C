<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;feedback.orc


ga1	init	0

	instr	1		;instr 1 generates a plucked sound (see chap.16)
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
ga1	pluck	iamp,ifrq,ifrq,0,1
	endin

	instr 	2
kamp	linseg 0, .002, 1, p3-.004, 1, .002, 0
irate 	=	p4		;oscillator frequency for flanging effect
idepth	=	p5/10000	;amount of flange shift
ifeed	=	p6		;feedback level
ideloff =	p7/10000	;fixed delay
adel1	init	0

;the input signal gets delayed, the delay being modulated at a rate of .001 
;seconds. The direct signal is mixed with the delayed, and the result 
;is fed back into the feedback loop 

asig1	=	ga1 + ifeed*adel1
aosc1	oscil	idepth, irate, 1
aosc1	=	aosc1+idepth+ideloff/2
atemp	delayr	2*idepth+ideloff
adel1	deltapi	aosc1
      	delayw	asig1
	out	ga1+adel1
ga1	=	0
	endin


</CsInstruments>
<CsScore>
;feedback.sco
f1 0 4096 10 1
;ins	act	dur	dB	pitch
i1	0	.5	80	8		;two arpeggiato major chords
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	.	.	9
i1	+	.	.	8
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	.	.	9
;ins	act	dur	rate	depth	feedb	deloff
i2	0	5	.5	10	.5	10
s						;end section

i1	0	.5	80	8
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	.	.	9
i1	+	.	.	8
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	.	.	9
;ins	act	dur	rate	depth	feedb	deloff
i2	0	5	.5	10	.8	20
 
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
