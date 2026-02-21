<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;Esempio Cap.3.16_random melody2

0dbfs = 1

instr	1

ifunction	=	2
krndmelody	randomh	1,22,8
kpitch	table	krndmelody,ifunction
a1	poscil	.6,cpspch(kpitch),1

out	a1

endin

</CsInstruments>
<CsScore>
;major
f1	0	4096	10	1

f2 0 32 -2 6.07 6.09 6.11 7.00 7.02 7.04 7.06 
              7.07 7.09 7.11 8.00 8.02 8.04 8.06 
              8.07 8.09 8.11 9.00 9.02 9.04 9.06 
              10.07 10.09 10.11 11.00 11.02 11.04 11.06 

i1	0	20
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
