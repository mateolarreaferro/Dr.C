<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;pluck.orc

	instr	1
ifrq	=	cpspch(p5)
iamp	=	ampdb(p4)
a1	pluck	iamp,ifrq,ifrq,0,1	;true Karplus-Strong
	out	a1
	endin

 

</CsInstruments>
<CsScore>
;pluck.sco
i1	0	1	80	8
i1	+	.	.	8.04
i1	+	.	.	8.07
i1	+	2	.	9

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
