<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;limit.orc

	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
kenv	linseg	0,.01,iamp,p3-.01,0	;generate a triangle envelope...
a1	oscil	kenv,ifrq,1		;...and apply it to some periodic signal 
krms	rms	a1			;get the rms power of that signal...
a2	limit	a1,-p6,p6		;...and limit it between -p6 and +p6
a3	gain	a2,krms		;scale the result... 								;...to match the initial amplitude level 
	out	a3
	endin


</CsInstruments>
<CsScore>
;limit.sco
f1	0	4096	10	1 .5 .4 .3 .2 .1
;instr	act	dur	dB	pch	limit
i1	0	.9	90	8	30000	
i1	1	.	.	.	20000
i1	2	.	.	.	10000
i1	3	.	.	.	 5000
i1	4	.	.	.	 1000

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
