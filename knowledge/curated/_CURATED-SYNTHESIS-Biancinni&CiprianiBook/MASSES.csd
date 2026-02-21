<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;masses.orc

	instr	1
iamp	=	ampdb(p4)
ifrmin	=	p5
ifrmax	=	p6
ifrrng	=	ifrmax-ifrmin	;frequency range
idurmin	=	p7
idurmax	=	p8
idurrng	=	idurmax-idurmin	;duration range

from_there:	
;----------------------------------------- get a freq value 
kfrq	rand	ifrrng,-1	; second argument (seed) is set to -1 
				; not to get identical random patterns
kfrq	=	abs(kfrq)
ifrq	=	ifrmin+i(kfrq)
;----------------------------------------- get a duration value
kdur	rand	idurrng,-1
kdur	=	abs(kdur)
idur	=	idurmin+i(kdur)
;----------------------------------------- envelope
kenv	linseg	0,.01,iamp,idur-.01,0
;----------------------------------------- re-initialization
	timout	0,idur,contin
	reinit	from_there
contin:
	rireturn
;----------------------------------------- synthesis
a1	oscili	kenv,ifrq,1
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
