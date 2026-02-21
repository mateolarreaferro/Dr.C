<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap2.2



instr	1   

a1	oscil	1,220,1	;variabile a1 con frequenza 220 e funzione 1
a2	oscil	1,440,2	;variabile a2 con frequenza 440 e funzione 2
a3	oscil	1,880,3	;variabile a3 con frequenza 880 e funzione 3
asomma	sum	a1,a2,a3	;variabile asomma in cui sommiamo a1,a2,a3

out	asomma*.3	;uscita audio mono della variabile asomma

endin 

</CsInstruments>
<CsScore>

f1	0	4096	10	1	;una sola fondamentale
f2	0	4096	10	1 	1	;fondamentale + seconda  armonica
f3	0	4096	10	1 	0	1	;fondamentale + terza    armonica

i1	0	4	;instr 1 con attacco immediato e durata di 4 secondi
i1	5	4	;attacco al quinto secondo e durata di 4 secondi

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
