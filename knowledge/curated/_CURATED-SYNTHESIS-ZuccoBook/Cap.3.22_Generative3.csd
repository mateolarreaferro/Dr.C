<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.22_Generative3

0dbfs = 1

instr	1	;strumento di controllo per instr 2,instr 3	

indx	=	1	;(indx = indx + incr,se indx < inumber si attiva il loop)	
incr	=	1	
inumber	=	200	;numero di iterazioni
instrument1	=	2	;numero strumento (p1)
instrument2	=	3	;numero strumento (p1)
iamp	=	.6	;ampiezza oscillatore
ifreq1	=	1000	;frequenza1
ifreq2	=	20	;frequenza2
idelay	=	0	;attacco (p2)
idur	=	.1	;durata evento (p3)

sequence:	;inizia il processo di loop

ifreq1	=	ifreq1 - 5	;genera una scala discendente (incremento = 5)
ifreq2	=	ifreq2 + 5	;genera una scala ascendente (incremento = 5)
idelay	=	idelay + .1	;intervallo tra ogni evento
event_i	"i",instrument1,idelay,idur,iamp,ifreq1	;genera due scale con attacco diverso
event_i "i",instrument2,idelay+.1,idur,iamp,ifreq2
loop_lt indx,incr,inumber,sequence	;genera sequenza

endin

instr	2	;generatore controllato da instr 1
a1	poscil	p4/2,p5,1
kenv    linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0
out	a1*kenv
endin

instr	3	;generatore controllato da instr 1
a1	pluck	p4/2,p5,p5*2,0,1
kenv    linseg	0,0.02,1,p3-0.05,1,0.02,0,0.01,0
out	a1*kenv
endin
</CsInstruments>
<CsScore>
f1	0	4096	10	10	9	8	7	6	5	4	3

i1	0	20



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
