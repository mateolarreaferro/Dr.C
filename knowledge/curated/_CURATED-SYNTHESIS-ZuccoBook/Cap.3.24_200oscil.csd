<CsoundSynthesizer>
<CsOptions>
</CsOptions> 
<CsInstruments>
;Esempio Cap.3.24_200oscil

0dbfs = 1

seed	0	;global random,genera valori diversi ad ogni play del file		

instr	1

instrument	=	2
inum=1 

loop:

iamp	random	.1,.6	;valori per ampiezza

ifreq	random	100,12000	;valori per frequenza

inumber	=	p4	;numero di oscillatori

irate	random	.1,20	;velocit‡ melodia			

event_i "i",instrument,0,p3,iamp/(p4*.3),ifreq,irate
loop_lt inum,1,inumber,loop

endin


instr	2	;generatore di sintesi additiva

kfreq	randomh	60,p5,p6	;melodia random
a1	poscil	p4,kfreq,1	;genera un banco di oscillatori

kpan	randomi	0,1,4
al,ar	pan2	a1,kpan

kenv	linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0	;inviluppo declick
outs	al*kenv,ar*kenv

endin

</CsInstruments> 
<CsScore>
f1	0	16384	10	1

;p4	=	numero di oscillatori

i1	0	10	1
s
i1	0	10	10
s
i1	0	10	20
s
i1	0	10	30
s
i1	0	10	40
s
i1	0	10	50
s
i1	0	10	100
s
i1	0	10	200
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
