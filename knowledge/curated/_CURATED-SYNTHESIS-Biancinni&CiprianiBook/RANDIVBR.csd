<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;randivbr.orc

		instr	1
iamp		=	p4
ifrq		=	p5
kenv		linseg	0,p3/4,iamp,p3/2,iamp,p3/4,0
kvibr		randi	p7,p6,-1
a1		oscili	kenv,ifrq*(1+kvibr),1
		out	a1
		endin
 

</CsInstruments>
<CsScore>
;randivbr.sco
f1	0	4096	10	1
i1	0	3	10000	440	8	.01	;vibrato depth...
i1	+	3	10000	440	8	.02	;...gets wider...
i1	+	3	10000	440	8	.03	;...and...
i1	+	3	10000	440	8	.04	;...wider

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
