<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.3.4_loopseg

0dbfs = 1

instr	1

kfreq	=	p4	;velocit� loop
ktrig	=	0	;attiva loopseg
itime0	=	0	;definisce segmenti
kvalue0 	=	0
itime1 	=	1
kvalue1 	= .5	;ampiezza
itime2	=	1
kvalue2 	=	0

ksig	loopseg	kfreq,ktrig,itime0,kvalue0,itime1,kvalue1,itime2,kvalue2

a1	oscil	ksig,220,1

out	a1

endin

</CsInstruments>
<CsScore>

f1	0	16384	10	1	0	1	0	1	0	1

i1	0	4	2  
i1	5	5	.2  
i1	11	10	8 

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
