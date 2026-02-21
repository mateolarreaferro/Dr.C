<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.8_Bandpass filter(nogui)

0dbfs = 1

instr	1

klfo	poscil	3,5,1	;lfo
a1	buzz	1,110+klfo,100,1
a2	buzz	1,220+klfo,100,1
asum	sum	a1,a2	;somma di due signal buzz
kfreq	randomi	1000,4000,1	;curva random per filtro
kband	=	p4	;larghezza di banda
afilt	butterbp	asum,kfreq,kband	;filtro passabanda
aout	balance	afilt,asum	;bilanciamento audio dei due segnali	
out	aout

endin

</CsInstruments>
<CsScore>
f1	0	16384	10	1

i1	0	10	10
s
i1	0	10	100
s
i1	0	10	1000
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
