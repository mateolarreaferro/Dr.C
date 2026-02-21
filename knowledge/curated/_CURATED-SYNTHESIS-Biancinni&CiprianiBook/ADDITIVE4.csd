<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	1

k2hrm	expseg 200,p3/2,234,p3/2,200
k3hrm	expseg 300,p3/2,333,p3/2,300
k4hrm	expseg 400,p3/2,376,p3/2,400
k5hrm	expseg 500,p3/2,527,p3/2,500
k6hrm	expseg 600,p3/2,609,p3/2,600
k7hrm 	expseg 700,p3/2,715,p3/2,700
k8hrm 	expseg 800,p3/2,853,p3/2,800

afund	oscili 3900,100,1
ahrm2 	oscili 3900,k2hrm,1
ahrm3	oscili 3900,k3hrm,1
ahrm4	oscili 3900,k4hrm,1
ahrm5	oscili 3900,k5hrm,1
ahrm6	oscili 3900,k6hrm,1
ahrm7	oscili 3900,k7hrm,1
ahrm8	oscili 3900,k8hrm,1

	out	afund+ahrm2+ahrm3+ahrm4+ahrm5+ahrm6+ahrm7+ahrm8
	endin

	instr 	2
k2hrm 	expseg	200,p3/2,220,p3/2,200
k3hrm 	expseg	300,p3/2,320,p3/2,300
k4hrm 	expseg	400,p3/2,420,p3/2,400
k5hrm 	expseg	500,p3/2,520,p3/2,500
k6hrm 	expseg	600,p3/2,620,p3/2,600
k7hrm 	expseg	700,p3/2,720,p3/2,700
k8hrm 	expseg	800,p3/2,820,p3/2,800

afund	oscili 3800,100,1
ahrm2 	oscili 1900,k2hrm,1
ahrm3	oscili 1900,k3hrm,1
ahrm4	oscili 1900,k4hrm,1
ahrm5	oscili 1900,k5hrm,1
ahrm6	oscili 1900,k6hrm,1
ahrm7	oscili 1900,k7hrm,1
ahrm8	oscili 1900,k8hrm,1
ahrm2b 	oscili 1900,200,1
ahrm3b	oscili 1900,300,1
ahrm4b	oscili 1900,400,1
ahrm5b	oscili 1900,500,1
ahrm6b	oscili 1900,600,1
ahrm7b	oscili 1900,700,1
ahrm8b	oscili 1900,800,1
	out	afund+ahrm2+ahrm3+ahrm4+ahrm5+ahrm6+ahrm7+ahrm8+ahrm2b+ahrm3b+ahrm4b+ahrm5b+ahrm6b+ahrm7b+ahrm8b 
	endin
 

	instr 		3
k2hrm 	expseg      200,p3/4,234,p3/4,244,p3/4,234,p3/4,200
k3hrm 	expseg      300,p3/4,333,p3/4,323,p3/4,333,p3/4,300
k4hrm 	expseg      400,p3/4,376,p3/4,386,p3/4,376,p3/4,400
k5hrm 	expseg      500,p3/4,527,p3/4,517,p3/4,527,p3/4,500
k6hrm 	expseg      600,p3/4,609,p3/4,619,p3/4,609,p3/4,600
k7hrm 	expseg      700,p3/4,715,p3/4,705,p3/4,715,p3/4,700
k8hrm 	expseg      800,p3/4,853,p3/4,863,p3/4,853,p3/4,800
k2hrmb	expseg      200,p3/4,234,p3/2,234,p3/4,200
k3hrmb 	expseg      300,p3/4,333,p3/2,333,p3/4,300
k4hrmb 	expseg      400,p3/4,376,p3/2,376,p3/4,400
k5hrmb 	expseg      500,p3/4,527,p3/2,527,p3/4,500
k6hrmb 	expseg      600,p3/4,609,p3/2,609,p3/4,600
k7hrmb 	expseg      700,p3/4,715,p3/2,715,p3/4,700
k8hrmb 	expseg      800,p3/4,853,p3/2,853,p3/4,800

afund 	oscili 	3800,100,1
ahrm2 	oscili 	1900,k2hrm,1
ahrm3	oscili 	1900,k3hrm,1
ahrm4	oscili 	1900,k4hrm,1
ahrm5	oscili 	1900,k5hrm,1
ahrm6	oscili 	1900,k6hrm,1
ahrm7	oscili 	1900,k7hrm,1
ahrm8	oscili 	1900,k8hrm,1
ahrm2b 	oscili 	1900,k2hrmb,1
ahrm3b	oscili 	1900,k3hrmb,1
ahrm4b	oscili 	1900,k4hrmb,1
ahrm5b	oscili 	1900,k5hrmb,1
ahrm6b	oscili 	1900,k6hrmb,1
ahrm7b	oscili 	1900,k7hrmb,1
ahrm8b	oscili 	1900,k8hrmb,1

out 	afund+ahrm2+ahrm3+ahrm4+ahrm5+ahrm6+ahrm7+ahrm8+ahrm2b+ahrm3b+ahrm4b+ahrm5b+ahrm6b+ahrm7b+ahrm8b
	endin

	instr 		4
k2hrm   expseg 	234,1,200,p3-1,200
k3hrm 	expseg 	333,1,300,p3-1,300
k4hrm	expseg 	376,1,400,p3-1,400
k5hrm 	expseg	527,1,500,p3-1,500
k6hrm	expseg	609,1,600,p3-1,600
k7hrm	expseg 	715,1,700,p3-1,700
k8hrm	expseg  853,1,800,p3-1,800

kampodd	linseg	0,.1,4000,.1,2000,2,2000,2,7000,p3-6.2,1000,2,0
kampeven linseg	0,.1,4000,.1,2000,2,2000,2,0,p3-6.2,6000,2,0

afund	oscili 	kampeven,100,1
af	oscili	kampodd,100,1
ahrm2 	oscili 	kampeven,k2hrm,1
ahrm3	oscili 	kampodd,k3hrm,1
ahrm4	oscili 	kampeven,k4hrm,1
ahrm5	oscili 	kampodd,k5hrm,1
ahrm6	oscili 	kampeven,k6hrm,1
ahrm7	oscili 	kampodd,k7hrm,1
ahrm8	oscili 	kampeven,k8hrm,1

	out 	afund+af+ahrm2+ahrm3+ahrm4+ahrm5+ahrm6+ahrm7+ahrm8
	endin


</CsInstruments>
<CsScore>
;additive4.sco
f1 0 4097 10 1
i4 0  8

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
