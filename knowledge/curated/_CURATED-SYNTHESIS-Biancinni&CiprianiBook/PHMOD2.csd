<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;phmod2.orc
	sr	=	44100
	kr	=	44100
	ksmps	=	1
	nchnls	=	1
	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
ifeed	=	p6
icutoff	=	p7
iexcdur	=	p8
afilt	init	0
kenvx	linseg	1,p3-.1,1,.1,0
idel	=	1/ifrq

kdel	linseg 	idel*.95,.05,idel,p3-.05,idel	
; kdel is the modulated delay time, 
; going from 95% to 100% of the nominal delay time (1/ifreq), in .05 seconds

aexc	linseg	iamp,ieccdur,0,p3-ieccdur, iexcdur,0	
asum	=	aecc+afilt*ifeed
a0		delayr	1		; replace the delay opcode with 							; delayr/delayw/deltapi
	delayw	asum
adel	deltapi	kdel		; the adel signal is now picked-up with
				; deltapi, variable delay time is kdel 
afilt	tone	adel,icutoff
aout	atone	afilt*kenvx,30	; high-pass to attenuate the DC offset
	out	aout
	endin
 

</CsInstruments>
<CsScore>
;phmod1b.sco
;ins	act	dur	dB	pitch	feed	fcutoff	iexcdur
i1	0	3	80	7	-1	4000		.01
i1	+	3	80	7	-1	4000		.05
i1	+	3	80	7	-1	4000		.1
i1	+	3	80	7	-1	4000		.2
i1	+	3	80	7	-1	4000		.4

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
