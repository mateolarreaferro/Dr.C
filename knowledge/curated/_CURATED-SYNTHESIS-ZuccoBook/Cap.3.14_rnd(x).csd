<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap3.14_rnd(x)

0dbfs = 1

instr 1

irandom	=	rnd(8)	;crea numeri casuali compresi tra 0 e 8
a1	poscil	.6,220,irandom+1 
out	a1

endin

</CsInstruments>
<CsScore>
f1 0 4096 10 1
f2 0 4096 10 0 1
f3 0 4096 10 0 1 1
f4 0 4096 10 1 0 0 1
f5 0 4096 10 0 0 1 0 1
f6 0 4096 10 0 1 0 0 0 1
f7 0 4096 10 1 0 0 1 0 0 1
f8 0 4096 10 1 0 1 0 1 0 1 0 1
f9 0 4096 10 0 1 0 1 0 1 0 1 0 1

r	40
i1	0	.1

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
