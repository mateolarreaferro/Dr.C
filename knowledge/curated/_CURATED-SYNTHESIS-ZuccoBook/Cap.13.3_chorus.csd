<CsoundSynthesizer> 
<CsOptions> 
</CsOptions>
<CsInstruments>
;Esempio Cap.13.3_chorus

0dbfs = 1

opcode	chorus,a,akk

asig,kdepth,krate	xin   

k1ch	randi	kdepth/2,krate,1
ar1	vdelay	asig,kdepth/2+k1ch,10
k2ch	randi	kdepth/2,krate*1.1,.2
ar2	vdelay	asig,kdepth/2+k2ch,10
k3ch	randi	kdepth/2,krate*0.9,.2
ar3	vdelay	asig,kdepth/2+k3ch,10
k4ch	randi	kdepth/2,krate*0.8,.1
ar4	vdelay	asig,kdepth/2+k4ch,10

aout	=	(ar1+ar2+ar3+ar4)/4

xout	aout             

endop



instr	1

a1	pluck	.9,110,440,0,1

kdepth	=	3
krate	=	5

afx	chorus	a1,kdepth,krate


outs	afx,afx


endin

</CsInstruments>
<CsScore>

i1	0	4

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
