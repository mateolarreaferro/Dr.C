<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)

;ar	envlpx	kamp, irise, idur, idec, ifn, iatss, iatdec

k1	envlpx	iamp, .2,    p3,    .2,   2,    .5,    .01 
a1	oscil	k1, ifrq, 1
	out	a1
	endin
 

</CsInstruments>
<CsScore>
;envlpx.sco
;funzione per oscil (5 armoniche)
f1 0 4096 10 1 .5 .3 .2 .1
;
;attack function table (for use in envlpx), brass-like, 
;notice table size is 4097, and the last value is 1
f2 0  4097  7  0 2102 .873 856 .426 1139 1
i1 0 4	  80	8

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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
