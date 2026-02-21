<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	
	instr	1

icamp	=	p4	;carrier amplitude (0-32767)
icfrq	=	p5	;carrier freq(Hz)
imfrq	=	p6	;modulator freq(Hz)
indx	=	p7	;modulation index

;----------------------MODULATOR
amod 	oscili	indx*imfrq,imfrq,1 	;modulator amp argument = imfrq * indx 
					;e.g. if imfrq=1000 and indx =.5	
					;then modulator amp= indx*imfrq=500
;----------------------CARRIER
acar	oscili	icamp,icfrq+amod,1 	;amplitude argument = icamp
					;freq argument = icfrq + amod
	out	acar	
	endin 
 
	instr	2

icamp	=	p4	;carrier amp (0-32767)
ifrq	=	p5	;nominal freq
ipk	=	p6	;carrier freq factor
imk	=	p7	;modulator freq factor
indx	=	p8	;modulation index

aout	foscili	icamp, ifrq, ipk, imk, indx, 1
	out	aout
	endin


</CsInstruments>
<CsScore>
;fm.sco 
f1 0 4096 10 1
;     start	dur	car amp	car frq 	mod frq	mod indx
i1 	0	2.9	10000		1000		3		10
i1 	3	.	10000		1000		3		30
i1 	6	.	10000		1000		3		50
i1 	9	.	10000		1000		3		1000

;p1	p2	p3	p4		p5	p6	p7		p8
i2 	12	2.9	10000		1000	1	.003		10
i2 	15	.	10000		1000	1	.003		30
i2 	18	.	10000		1000	1	.003		50
i2 	21	.	10000		1000	1	.003		1000

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
