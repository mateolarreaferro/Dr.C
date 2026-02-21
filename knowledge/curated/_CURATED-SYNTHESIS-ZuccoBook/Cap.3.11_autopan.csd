<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.11_autopan

0dbfs = 1

instr	1

a1	rand	.6
k1	oscil	.5,p4,1 ;p4 controlla la velocit‡ di rotazione
kpanl	=	k1   
kpanr	=	1-k1
outs	a1*kpanl,a1*kpanr

endin

instr	2
;random pan
a1	rand	.6
kpan	randi	1,1,-1	;valori random tra 0 e 1 con interpolazione
al,ar	pan2	a1,kpan,2
outs	al,ar

endin

</CsInstruments>
<CsScore>
f1	0	4096	10	1

i1	0	4	3
s
i1	0	4	.5
s
i2	0	20 
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
