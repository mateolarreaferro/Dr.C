<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.9_tremolo

0dbfs = 1

instr 1

kenv	linseg	0,p3/2,8,p3/2,0
k1	poscil	.3,kenv,1
iamp	=	p4
ifreq	=	cpspch(p5)
a1	poscil	iamp*(k1+1),ifreq,1
out	a1

endin

</CsInstruments>
<CsScore>
f1	0	16384	10	1	0	1 

i1	0	20	.6	7.00

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
