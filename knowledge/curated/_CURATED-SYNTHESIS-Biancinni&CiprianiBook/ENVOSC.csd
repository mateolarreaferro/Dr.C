<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	1
iamp	=	p4
ifrq	=	p5
kenv	oscil1	0,iamp,p3,2
a1	oscil	kenv,ifrq,1
	out	a1
	endin
 

</CsInstruments>
<CsScore>
;envosc.sco
f1	0	4096	10	1
f2	0	4096	7	0	512	1	2560	1	1024	0
i1	0	2	10000	500

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
