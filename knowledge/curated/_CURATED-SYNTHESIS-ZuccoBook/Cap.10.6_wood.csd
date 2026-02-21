<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.10.6_wood.csd

instr	1
;eccitatore Red Cedar wood plate
;[1, 1.47, 2.09, 2.56] 
kpitch	=	cpspch(p5)/2
kq	=	100
apulse	mpulse	1,2
amode1	mode	apulse,kpitch*1,kq
amode2  mode	apulse,kpitch*1.47,kq
amode3  mode	apulse,kpitch*2.09,kq
amode4  mode	apulse,kpitch*2.56,kq
aecc	sum	amode1,amode2,amode3,amode4

;risonatore membrana
;p5	=	pitch base
;p6	=	damping
a1	mode	aecc,cpspch(p5)*1,p6
a2	mode 	aecc,cpspch(p5)*1.59334,p6
a3	mode 	aecc,cpspch(p5)*2.13555,p6
a4	mode	aecc,cpspch(p5)*2.65307,p6
a5	mode	aecc,cpspch(p5)*2.29542,p6
a6	mode	aecc,cpspch(p5)*2.9173,p6
a7	mode 	aecc,cpspch(p5)*3.50015,p6
a8	mode	aecc,cpspch(p5)*4.05893,p6
a9	mode 	aecc,cpspch(p5)*3.59848,p6
a10	mode 	aecc,cpspch(p5)*4.23044,p6
a11	mode	aecc,cpspch(p5)*4.83189,p6
a12	mode	aecc,cpspch(p5)*5.41212,p6
a13	mode	aecc,cpspch(p5)*4.90328,p6
a14	mode	aecc,cpspch(p5)*5.5404,p6
a15	mode	aecc,cpspch(p5)*6.15261,p6
a16	mode	aecc,cpspch(p5)*6.74621,p6
aresonator	=	(a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11+a12+a13+a14+a15+a16)/16
aout	balance	aresonator,aecc 

outs	(aout+aecc)*p4,(aout+aecc)*p4

endin

</CsInstruments>
<CsScore>
i1	0	4	10000	6.05	1000
s
i1	0	4	10000	7.02	1000
s
i1	0	4	10000	7.07	1000
s
i1	0	4	10000	8.05	1000
s
i1	0	4	10000	8.01	1000
s
</CsScore>

</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
