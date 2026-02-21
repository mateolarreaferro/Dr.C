<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
		instr	126
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
iatk	=		p6
irel	=		p7
ivibdel	=		p8
imoddpt	=		p9
imodfrq	=		p10
iharm	=		p11
kenv	linen	iamp, iatk, idur, irel
kvibenv	linseg	0, ivibdel, 1, idur-ivibdel, .3
klfo	oscil	kvibenv*imoddpt, imodfrq, 1	
asig   	buzz   	kenv, ifrq+klfo, iharm, 1
       	out  	asig
		endin

</CsInstruments>
<CsScore>
;Function  1 uses the GEN10 subroutine to compute a sine wave

f 1  0 4096 10   1    

;ins	st	dur	amp	frq		atk	rel	lfodel	lfodpth	lfofrq	harm1	
;=================================================================
i 126     0	2.2	70	6.09	.1	 .3	1		 6		5		10
i 126     2	2.2	73	6.11	.2	 .4	.5		 5		6		9
i 126     4	2.2	77	7.01	.01	 .5	.8		 4		5		12
i 126     6	2.2	80	7.02	.3	 .3	1.6		 7		7		6
i 126     8	6.2	70	6.04	1.5	 .3	2		 6		4.7		8
i 126     8	6.2	73	6.08	 .9	 .4	1.5		 5		6		11
i 126     8	6.2	77	6.11	3.01 .5	.18		 4		5		5
i 126     8	6.2	80	7.04	2.4	 .3	3.6		 5.3	5.6		7

</CsScore>
</CsoundSynthesizer>


<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
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
