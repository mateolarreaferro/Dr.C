<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr 	135
idur	=		p3
iamp	=		p4
ifrq	=		p5
iatk	=		p6
irel	=		p7
irat1	=		p8
irat2	=		p9
imsdel	=		p10
kenv	expseg	.001, iatk, iamp, idur/8, iamp*.3, idur-(iatk+irel+idur/8), iamp*.7, irel,.01
krate	line	irat1, idur, irat2
alfo	oscil	imsdel, krate/idur, 19
anoise	rand	ifrq
adel4	vdelay	anoise, alfo, imsdel
adel3	vdelay	adel4, alfo, imsdel
adel2	vdelay	adel3, alfo, imsdel
adel1	vdelay	adel2, alfo, imsdel
adel0	vdelay	adel1, alfo, imsdel
amix	=		adel0+adel1+adel2+adel3+adel4		
		out		kenv*amix
		dispfft	amix, idur, 1024
		endin

</CsInstruments>
<CsScore>

f19 0 1024 -8 .1 	512 .9 512 .1

;ins	strt	dur amp	frq   atk	rel	rat1	rat2	msdel  
;==========================================================
f0 1
f0 2
f0 3
f0 4
f0 5
i 135		0		6	.5	10000 .1	1	.3   	10  	6
i 135		6.5		6	.5	10000 .1	2	.01  	1  		5
f0 7
f0 8
f0 9
f0 10
f0 11
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>388</width>
 <height>8</height>
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
