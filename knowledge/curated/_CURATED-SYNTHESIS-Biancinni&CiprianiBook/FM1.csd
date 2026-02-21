<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;fm1.orc
	instr	1
icamp	=	p4	;1st carrier amp
icfrq	=	p5	;1st carrier freq
imfrq	=	p6	;modulator freq
indx	=	p7	;max index value
icamp2 	=	p8	;2nd carrier amp
icfrq2	=	p9	;2nd carrier freq 
icamp3 	=	p10	;3rd carrier amp
icfrq3	=	p11	;3rd carrier freq

kenvcar  linseg	 0,p3/2,icamp,p3/2,0 	;1st indx envelope
kenvcar2 linseg	 0,p3/2,icamp2,p3/2,0 	;2nd indx envelope
kenvcar3 linseg	 0,p3/2,icamp3,p3/2,0	;3rd indx evnelope
kenvindx linseg	0,p3/4,indx,p3/4,0,p3/4,indx,p3/4,0

acar1	foscili	kenvcar,1,icfrq,imfrq,kenvindx,1
acar2	foscili	kenvcar2,1,icfrq2,imfrq,kenvindx,1
acar3	foscili	kenvcar3,1,icfrq3,imfrq,kenvindx,1

	out	acar1+acar2+acar3

	endin

</CsInstruments>
<CsScore>
;fm1.sco
f1 0 4096 10 1
;   		icamp	icfrq	imfrq	indx	icamp2	  icfrq2 	icamp3		icfrq3 
i1  0	6	12000	100	100	5	12000	  200		8000		300
i1  7	6	12000	100	113	5	12000	  258		8000		356
i1 14	6	12000	100	107	5	12000	  111		8000		117

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
