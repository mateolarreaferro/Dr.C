<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.23_Melodia_infinita

0dbfs = 1

gifn	ftgen	1,0,1024,10,1
gifn	ftgen	2,0,1024,10,1,1
gifn	ftgen	3,0,1024,10,1,0,1
gifn	ftgen	4,0,1024,10,1,0,0,1
gifn	ftgen	5,0,1024,10,1,0,0,0,1


instr	1

indx	=	1
incr	=	1
iattack	=	0
loop:
idur	=	rnd(1)	
iattack	=	iattack+idur
event_i	"i",2,iattack,idur	
loop_lt	indx,incr,1000,loop

endin


instr 2

iscale	=	200	;tabella con note in pitch
kmelody	=	rnd(15)	;sceglie una nota dalla tabella
kpitch	table	kmelody+1,iscale	;legge la funzione con le note
kamp	=	rnd(1)	;genera valori random per l'ampiezza
ifn	=	rnd(4)	;sceglie una forma d'onda diversa ad ogni evento
a1	poscil	.1+kamp,cpspch(kpitch),ifn+1	;oscillatore
aenv    line	.7,p3,0	;inviluppo per l'ampiezza

krndpan	=	rnd(1)	;valori random per pan
aL,aR	pan2	a1,krndpan	;random pan
outs	aL*aenv,aR*aenv	;uscita stereo con inviluppo

endin 


</CsInstruments>
<CsScore>

f200 0 16 -2  7.00 7.05 7.06 7.10 8.02 8.00 8.05 8.06 8.10 9.02 9.00 9.05 9.06 9.10 10.02 10.00
             
i1	0	1000

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
