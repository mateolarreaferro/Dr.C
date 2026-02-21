<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


	instr	1

; waveshaping (non-linear distorsion)

ifrq	=	p5
iamp	=	ampdb(p4)

kenv	linseg	 0,.1,.5,p3-.1,0
a1	oscil	kenv, ifrq, 1   	;sinusoid with envelope 
					;scaled between -.5 and .5

a2	=	a1 + .5		;add offset of .5, so
					;sinusoid now oscillates between 0 and 1
a3	table	a2, 2, 1		;use the sinusoid signal, a2, to index 
					;table n.2 (index mode=1, normalized) 
a4	=	a3 * iamp		;amplitude scaling 
	out	a4
	endin
 

</CsInstruments>
<CsScore>
;dnl0.sco
f1 0 4096 10 1					;sinusoid
f 2 0  4096  7  -1 1635 -1 827 1 1635 1	;waveshaper function (see 
					;fig.14-4)
i1	0	3	80	200

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
