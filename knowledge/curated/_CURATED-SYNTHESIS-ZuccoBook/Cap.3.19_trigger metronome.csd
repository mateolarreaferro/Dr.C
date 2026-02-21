<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.19_trigger metronome

0dbfs = 1

instr	1
ktrig	metro	p4	;intervallo di tempo tra un evento e il successivo
kdur	=	p5	;durata di ogni evento
schedkwhen	ktrig,0,1,2,0,kdur
endin

instr	2
a1	poscil	.6,220,1
kenv	line	1,p3,0
out	a1*kenv
endin

</CsInstruments>
<CsScore>
f1	0	4096	10	1	1	1

i1	0	10	1	1
s	
i1	0	10	.5	2
s
i1	0	5	60	.1
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
