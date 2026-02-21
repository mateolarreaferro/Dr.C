<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Table-based Rezzy Synth with Distortion


	instr	1007	; tb-303 EMULATOR
idur	=	p3
iamp	=	p4
ifqc	=	cpspch(p5)
irez	=	p7
itabl1	=	p8
kaenv	linseg	0, .01, 1, p3-.02, 1, .01, 0	; ampenv
kfco	linseg	p6, .5*p3, .2*p6, .5*p3, .1*p6	; FrqSweep
ka1	=	100/irez/sqrt(kfco)-1	; attempts to separate...
ka2	=	1000/kfco	; ...Freq. from Res.
aynm1	init	0	; Initialize Yn-1 to zero
aynm2	init	0	; Initialize Yn-2 to zero 
axn	oscil	iamp, ifqc, itabl1	; osc

; Replace the differential eqUation with a difference equation.
ayn	=	((ka1+2*ka2)*aynm1-ka2*aynm2+axn)/(1+ka1+ka2)
atemp	tone	axn, kfco
aclip1	=	(ayn-atemp)/100000
aclip	tablei	aclip1, 7, 1, .5
aout	=	aclip*20000+atemp
aynm2	=	aynm1
aynm1	=	ayn
	out	kaenv*aout	; Amp envelope and output
	endin

</CsInstruments>
<CsScore>
f	1	0	1024	10	1	; sine
f	2	0	256	7	-1 128 -1 0 1 128 1	; square
f	3	0	256	7	1 256 -1	; saw
f	4	0	256	7	-1 128 1 128 -1	; tri
f	5	0	256	7	1 64 1 0 -1 192 -1	; pulse
f	6	0	8192	7	0 2048 0 0 -1 2048 -1 0 1 2048 1 0 0 2048 0
f	7	0	1024	8	-.8 42 -.78 400 -.7 140 .7 400 .78 42 .8
r	4	NN
t	0	400
; Distortion Filter Instrument TB-303
;	ins	sta	Dur	Amp	Pitch	Fc	Q	tab
i	1007	0	1	5000	6.07	5	50	3
i	1007	+	.	<	6.07	<	.	3
i	1007	.	.	<	6.05	<	.	3
i	1007	.	.	<	6.02	<	.	3
i	1007	.	.	<	6.07	<	.	3
i	1007	.	.	<	6.02	<	.	3
i	1007	.	.	<	6.10	<	.	3
i	1007	.	.	8000	6.06	100	20	3
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
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
