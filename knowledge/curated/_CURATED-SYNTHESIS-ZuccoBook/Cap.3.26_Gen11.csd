<CsoundSynthesizer>
<CsOptions>
</CsOptions> 
<CsInstruments>
;Esempio Cap.3.26_Gen11


0dbfs = 1	

instr	1	;gen11

iamp	=	.6
iwave	=	p4

kenv	adsr	.6,.3,1,0

a1	poscil	iamp*kenv,220,iwave

out	a1


endin








</CsInstruments> 
<CsScore>
f1	0	16384	11	10	1
f2	0	16384	11	10	5
f3	0	16384	11	20	1
f4	0	16384	11	40	10


i1	0	5	1
s
i1	0	5	2
s
i1	0	5	3
s
i1	0	5	4
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
