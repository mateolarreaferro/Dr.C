<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.9.5_partikkel

0dbfs = 1

giSquare	ftgen	1,0,4097,7,1,2048,1,0,-1,2048,-1
giSaw	ftgen	2,0,8193,7,1,8291,-1
giSine	ftgen	3,0,65537,10,1
giTri	ftgen	4,0,8193,7,0,2048,1,4096,-1,2048,0
giCosine	ftgen	5,0,8193,9,1,1,90
giattack	ftgen	6,0,8193,19,0.5,1,270,1	
gidecay	ftgen	7,0,8193,19,0.5,1,90,1	


;partikkel instrument

instr	1


kamp	=	p4
kgrainfreq	=	p5*.1	;rate (.1 a 200)
kdistr	=	0	;distribuzione periodica dei grani
idisttab	=	-1	;(default)distribuzione dei grani(-1 si annulla)
async	=	0	;no sync input
kenv2amt	=	0	;nessun inviluppo secondario
ienv2tab	=	-1	;default inviluppo secondario
iattack	=	giattack	;inviluppo attack 
idecay	=	gidecay	;inviluppo decay 
ksus	=	0.5	;sustain per il singolo grano
kratio	=	0.5	;bilanciamento tra attack and decay time
kdur	=	p6	;grain size (.1 a 20)
igain	=	-1	;(default) no gain per grano
kwavfreq	=	p5	;frequenza dei grani (valore costante)
ksweep	=	0	;frequenza sweep (0=no sweep)
istarttab	=	-1	;default frequency sweep start 
ifreqendtab	=	-1	;default frequency sweep end 
afminput	poscil	p7,p8,3
awavfm	=	afminput	;oscil FM input
ifmamptab	=	-1	;default FM scaling (=1)
kfmenv	=	-1	;default FM envelope (flat)
icosine	=	giCosine	;cosine tabella
kTrainCps	=	kgrainfreq	;trainlet cps uguale a grain rate 
kpartials	=	3	;numero di parziali in trainlet
kchroma	=	1	;bilanciamento di parziali in trainlet
ichmasks	=	-1	;(default)all grains to output 1
krndmask	=	p9	;componente random di grainrate (.1 a .9)
kwave1	=	p10	;sorgente in ingresso
kwave2	=	p10   
kwave3	=	p10		
kwave4	=	p10		
iwaveamp	=	-1	;(default)quattro sorgenti mixate
apos1	=	0	;fase di ogni sorgente
apos2	=	0			
apos3	=	0			
apos4	=	0			
kkey1	=	1	;trasposizione di ogni sorgente
kkey2	=	1	
kkey3	=	1			
kkey4	=	1			
imax_grains	=	100	;massimo numero di grani

a1	partikkel	kgrainfreq,kdistr,idisttab,async,kenv2amt,ienv2tab,\
	iattack,idecay,ksus,kratio,kdur, kamp,igain,\
	kwavfreq,ksweep,istarttab,ifreqendtab,awavfm,\
	ifmamptab,kfmenv,icosine,kTrainCps,kpartials,\
	kchroma,ichmasks,krndmask,kwave1,kwave2,kwave3,kwave4,\
	iwaveamp,apos1,apos2,apos3,apos4,\
	kkey1,kkey2,kkey3,kkey4,imax_grains
	
aout	clip	a1,0,.9

outs	aout,aout

endin

</CsInstruments>
<CsScore>
;p4 = amp
;p5 = ;rate 
;p6 = ;grain size 
;p7,p8 = fm amp/freq
;p9;componente random di grainrate (.1 a .9)
;p10 = waveform

i1	0	10	1	200	20	0	0	0	1
s
i1	0	10	1	100	1	0	0	.5	4
s
i1	0	10	1	400	8	2	3	.9	3
s
i1	0	10	1	1000	2	0	0	.3	3
s
i1	0	10	1	2000	8	1	3	.9	3
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
