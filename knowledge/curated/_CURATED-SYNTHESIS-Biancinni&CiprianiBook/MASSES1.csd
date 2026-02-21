<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;masses1.orc
	instr	1
iamp	=	ampdb(p4)
irem	=	p3			;remainder time
ifrmin	=	p5
ifrmax	=	p6
ifrrng	=	ifrmax-ifrmin	;freq range
idurmin	=	p7
idurmax	=	p8
idurrng	=	idurmax-idurmin	;dur range

from_there:

kfrq	rand	ifrrng/2,-1
kfrq	=	abs(kfrq)
ifrq	=	ifrmin+i(kfrq)
kdur	rand	idurrng/2,-1
kdur	=	abs(kdur)
idur	=	idurmin+i(kdur)
irem	=	irem-idur		;get the remainder time
	if	irem<idur goto nosound 	;if remainder time is not enough
					;then no sound is generated
					;(jump to the "nosound" label)
kenv	linseg	0,.01,iamp,idur-.01,0
	timout	0,idur,contin
	reinit	from_there
contin:
	rireturn
a1	oscili	kenv,ifrq,1
nosound:
	out	a1
	endin


</CsInstruments>
<CsScore>
;masses.sco
f1	0	4096	10	1	.3	.3	.2	0	.4
;p1	p2	p3	p4	p5	p6
;ins	act	dur	dB	min.freq	max.freq	min.dur	max.dur
i1	0	3	80	400		600		.1		.2

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
