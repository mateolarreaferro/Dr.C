<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;chromscale.orc

	instr	1
iamp	=	ampdb(p4)
ipitch	=	p5			;start pitch
ioctst	=	int(p5)		;octave of start pitch
ioctend	=	int(p6) 		;octave of end pitch 
isemist	=	frac(p5)*100		;start pitch class
isemiend =	frac(p6)*100		;end pitch class
isemirng = (ioctend-ioctst)*12+(isemiend-isemist)+1	
						;total number of pitches to play
idur	=	p3/isemirng		;duration for each partial event

from_there:
ifrq	=	cpspch(ipitch) 	;pitch to Hz conversion
kenv	linseg	0,.01,iamp,idur-.01,0	;envelope 
	timout	0,idur,contin	;re-init instrument every idur seconds
ipitch	=	ipitch+.01		;and increment pitch for next event

	reinit 	from_there
contin:
	rireturn
a1	oscili	kenv,ifrq,1		;sound synthesis
	out	a1
	endin
 

</CsInstruments>
<CsScore>
;chromscale.sco
f1	0	4096	10	1	.3	.3	.2	0	.4
;p1	p2	p3	p4	p5	p6
;ins	act	dur	dB	start	end
i1	0	3	80	8	8.07

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
