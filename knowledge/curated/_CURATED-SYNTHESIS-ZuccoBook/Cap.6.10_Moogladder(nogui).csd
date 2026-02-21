<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.10_Moogladder(nogui)
0dbfs = 1

ga1	init	0

turnon	1	;attiva gli strumenti per un tempo indefinito
turnon	2

;step sequencer
instr	1

ifunction	=	2

krate	=	.5
kstep	poscil	8,krate,1;genera valori per indice della tabella
kpitch	table	abs(kstep),ifunction	;(abs restituisce il valore assoluto di kstep)
a1	vco2	.6,cpspch(kpitch),0;oscillatore Vco sawtooth
vincr	ga1,a1	;manda il segnale al filtro attivo
endin

instr	2

kfreq	randomi	60,10000,2
kreso	randomi	.1,.9,2	

;riceve la variabile globale ga1(VCO)
afilt	moogladder	ga1,kfreq,kreso	;filtro moog

out	afilt

clear	ga1	;evita effetti di accumulo	
endin
	
</CsInstruments>
<CsScore>
f1	0	4096	10	1
f2 0 8 -2 6.00 6.03 6.05 6.06 6.07 6.11 7.00 7.03 

f0	3600

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
