<CsoundSynthesizer>
<CsOptions>
</CsOptions> 
<CsInstruments>
;Esempio Cap.13.2_Hipersaw-udo

0dbfs = 1

;UDO Hipersaw
opcode	Hipersaw,a,kkkkk	

gisine	ftgen	0,0,4096,10,1

kamp,kcps,kdetune,kcut,kreso	xin             

krnd1	poscil	kdetune,.1,gisine
krnd2	poscil	kdetune,.2,gisine
krnd3	poscil	kdetune,.3,gisine
krnd4	poscil	kdetune,.4,gisine
krnd5	poscil	kdetune,.5,gisine


a1	vco2	kamp,kcps,0
a2	vco2	kamp,kcps+kdetune,0
a3	vco2	kamp,kcps+(kdetune+krnd1)*.1,0
a4	vco2	kamp,kcps+(kdetune+krnd2)*.1,0
a5	vco2	kamp,kcps+(kdetune+krnd3)*.1,0
a6	vco2	kamp,kcps+(kdetune+krnd4)*.1,0
a7	vco2	kamp,kcps+(kdetune+krnd5)*.1,0


asum	sum	a1,a2,a3,a4,a5,a6,a7

afilt	moogladder	asum,kcut,kreso

aout	clip	afilt,0,.9

xout	aout                 ; write output

endop
;end UDO


;applicazione Hipersaw

instr	1	

iamp	=	p4	
ifreq	=	p5
kdetune	=	p6	
kcut	=	p7
kreso	=	p8

a1	Hipersaw	iamp,ifreq,kdetune,kcut,kreso

kenv	adsr	0.1,.3,1,0

out	a1*kenv


endin


</CsInstruments> 
<CsScore>


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
