<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.10_controllare il suono stereo

0dbfs = 1

instr	1

a1	rand	.6

outs	a1*p4,a1*p5	

endin

instr	2

a1	rand	.6
kpan 	linseg	0,p3/2,1,p3/2,0    
kpanl	=	kpan   
kpanr	=	1-kpan  

outs	a1*kpanl, a1*kpanr

endin

instr	3

a1	rand	.6
kpan 	linseg	0,p3/2,1,p3/2,0      
kpanl	=	sqrt(kpan)    ; esempio di Curtis Roads
kpanr	=	sqrt(1-kpan)  

outs	a1*kpanl, a1*kpanr

endin

instr	4

asound	rand	.6
kpan 	linseg	0,p3/2,1,p3/2,0     
a1,a2	pan2	asound,kpan

outs	a1,a2

endin
</CsInstruments>
<CsScore>

i1	0	2	0	1
i1	3	2	1	0
i2	6	6
i3	14	5
i4	20	5
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
