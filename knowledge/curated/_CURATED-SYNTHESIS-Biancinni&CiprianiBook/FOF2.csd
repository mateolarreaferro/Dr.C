<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	1
iamp	=	p4
ifund	=	p5
iform	=	p6
;ar	fof  xamp, xfund,xform,koct,kband,kris,kdur, kdec,iolaps,ifna, ifnb,itotdur
a1   	fof  iamp, ifund,iform,  0,   40,  .003,.02, .007,    5,    1,    2,   p3
	out  a1
	endin 
 

</CsInstruments>
<CsScore>
;fof2.sco
f1  0  4096  10  1 
f2  0  1024  19  .5  .5  270  .5 
;in	act	dur	amp	fund	form
i1  	0  	3 	15000	200	650
i1  	+  	3 	15000	200	1300
i1  	+  	3 	15000	100	400
i1  	+  	3 	15000	100	1200

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
