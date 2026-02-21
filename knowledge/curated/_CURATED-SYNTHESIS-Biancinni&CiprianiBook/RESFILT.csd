<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;resfilt.orc	


	instr	1
ifrq	=		p5		;cutoff freq
ibw	=		ifrq/p6	;calculates the bandwidth 
					;as a fraction of the cutoff frequency
kfrq	line		0,p3,10000	;control signal for the sweep
a1	oscili		p4,kfrq,1	;gliding sine wave
;------------------------------- filters
af1	butterlp	a1,ifrq*2	;low-pass
af2	butterbp	a1,ifrq,ibw	;band-passs
;------------------------------- sum of filtered signals
aout	=		(af1+af2)/2
	out		aout
	endin
 

</CsInstruments>
<CsScore>
;resfilt.sco 
f1 0 4096 10 1
;in	act	dur	amp	ifrq	Q
i1	0	5	15000	2000	1
i1	+	.	15000	2000	2
i1	+	.	15000	2000	4
i1	+	.	15000	2000	8  

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
