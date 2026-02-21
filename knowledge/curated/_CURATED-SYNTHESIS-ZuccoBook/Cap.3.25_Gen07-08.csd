<CsoundSynthesizer>
<CsOptions>
</CsOptions> 
<CsInstruments>
;Esempio Cap.3.25_Gen07-08

0dbfs = 1

instr	1	;gen07 come inviluppo

iamp	=	.6
ienv	=	2
isine	=	1

kenv	poscil	iamp,1/p3,ienv

a1	poscil	kenv,440,isine

out	a1


endin


instr	2	;gen07 come forma d'onda

iamp	=	.6
iwave	=	2

a1	poscil	iamp,220,iwave

out	a1


endin


instr	3	;gen08 come inviluppo

iamp	=	.6
ienv	=	3
isine	=	1

kenv	poscil	iamp,1/p3,ienv

a1	poscil	kenv,440,isine

out	a1


endin



</CsInstruments> 
<CsScore>
f1	0	16384	10	1
f2	0	1024	7	1	1024	-1 ;saw down
f3	0	65	8	0	16	1	16	1	16	0	17	0

i1	0	5
s
i2	0	5
s
i3	0	5	


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
