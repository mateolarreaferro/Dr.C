<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;stereo.orc
		instr 1
asine 		oscil 	10000,1000,1
asquare	oscil	10000,220,2
		outs	asine,asquare      	;asine on left channel, asquare on right 
		endin
;
		instr 2 
awn		rand	10000
		outs	awn,awn		;awn on both left and right channels
		endin
 


</CsInstruments>
<CsScore>
;stereo.sco
f1	0	4096	10	1
f2	0	4096	7	1	2048	1	0	-1	2048	-1
i1	0	5
i2	6	5	

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
