<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;Esempio Cap.6.9_statevar-dissolvenze


0dbfs = 1


instr 1

a1	rand	1

kcutoff	=	1000
kQ	=	.9
iosamps	=	20	;oversampling del processamento
				;,aumenta la componente acuta di Q
ahp,alp,abp,abr	statevar	a1,kcutoff,kQ,iosamps

k1	line	0,p3,1	
k2	linseg	1,p3/2,0,p3/2,1

aout1	=	ahp*k1	;uscita moltiplicata per 0 e 1
aout2	=	alp*k2
aout3	=	abp*(1-k1)
aout4	=	abr*(1-k2)

aright	sum	aout1,aout2
aleft	sum	aout3,aout4
	
aclip1	clip	aright,0,.9
aclip2	clip	aleft,0,.9

outs	aclip1,aclip2	;uscita stereo

endin	

</CsInstruments>
<CsScore>
f1	0	4096	10	1

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
