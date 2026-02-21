<CsoundSynthesizer>
<CsOptions>
</CsOptions> 
<CsInstruments>
;Esempio Cap.13.1_Hipersaw

0dbfs = 1

	
instr	1	

iamp	=	p4

kdetune	=	p6

krnd1	poscil	kdetune,.1,1
krnd2	poscil	kdetune,.2,1
krnd3	poscil	kdetune,.3,1
krnd4	poscil	kdetune,.4,1
krnd5	poscil	kdetune,.5,1


a1	vco2	iamp,p5,0
a2	vco2	iamp,p5+kdetune,0
a3	vco2	iamp,p5+(kdetune+krnd1)*.1,0
a4	vco2	iamp,p5+(kdetune+krnd2)*.1,0
a5	vco2	iamp,p5+(kdetune+krnd3)*.1,0
a6	vco2	iamp,p5+(kdetune+krnd4)*.1,0
a7	vco2	iamp,p5+(kdetune+krnd5)*.1,0


asum	sum	a1,a2,a3,a4,a5,a6,a7

kcut	=	p7
kreso	=	p8

afilt	moogladder	asum,kcut,kreso

aout	clip	afilt,0,.9

kenv	adsr	0.1,.3,1,0

out	aout*kenv


endin








</CsInstruments> 
<CsScore>
f1	0	16384	10	1


i1	0	5	.6	120	5	12000	.82



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
