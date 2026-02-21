<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.20_Generative1

0dbfs = 1

gifn	ftgen	1,0,1024,10,1
gifn	ftgen	2,0,1024,10,1,0,1
gifn	ftgen	3,0,1024,10,1,0,0,1
gifn	ftgen	4,0,1024,10,1,0,0,0,1
gifn	ftgen	5,0,1024,10,1,0,0,0,0,1
gifn	ftgen	6,0,1024,10,1,0,1,0,0,0,1
gifn	ftgen	7,0,1024,10,1,0,0,1,0,0,0,1
gifn	ftgen	8,0,1024,10,1,0,0,0,1,0,0,0,1
gifn	ftgen	9,0,1024,10,1,0,0,0,0,1,0,0,1,1
gifn	ftgen	10,0,1024,10,1,0,0,0,0,0,1,1,0,0,1
gifn	ftgen	11,0,1024,10,1,0,0,0,0,1,1,0,0,0,0,1
gifn	ftgen	12,0,1024,10,1,0,0,0,1,1,0,0,0,0,0,0,1
gifn	ftgen	13,0,1024,10,1,0,0,0,1,1,0,0,0,0,0,0,0,1
gifn	ftgen	14,0,1024,10,1,0,0,1,0,0,1,0,0,0,0,0,0,0,1
gifn	ftgen	15,0,1024,10,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,1
gifn	ftgen	16,0,1024,10,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1


instr	1

krndtime	linseg	.1,p3/4,12,p3/4,.2,p3/4,20,p3/4,.1	;crea accelerandi e rallentandi
krnddur	random	.1,2	;genera valori casuali per le durate
ktrig1	metro	krndtime	;intervallo di tempo tra un evento e il successivo
kdur	=	krnddur	;durata di ogni evento
kwhen	=	0	;attacco (p2)

;variante di schedkwhen che permette di indicare il nome dello strumento
schedkwhennamed	ktrig1,0,100,"synth",kwhen,kdur	
endin


instr	synth
ifunction	=	200	;tabella con scala maggiore in pitch
krndmelody	=	rnd (21)
kpitch	table	krndmelody,ifunction
ifn	=	rnd (15)	;sceglie un numero di gen in modo casuale
a1	oscili	.1,1+cpspch(kpitch),1+ifn	;valori di pitch in tabella
;random pan
kpan	=	birnd(1)
al,ar	pan2	a1,kpan,2
kenv	linseg 0,0.02,1,p3-0.05,1,0.02,0,0.01,0	;declick
outs	al*kenv,ar*kenv
endin


</CsInstruments>
<CsScore>

f200 0 32 -2  6.07 6.09 6.11 7.00 7.02 7.04 7.06 
              7.07 7.09 7.11 8.00 8.02 8.04 8.06 
              8.07 8.09 8.11 9.00 9.02 9.04 9.06 
              10.07 10.09 10.11 11.00 11.02 11.04 11.06



i1	0	30

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
