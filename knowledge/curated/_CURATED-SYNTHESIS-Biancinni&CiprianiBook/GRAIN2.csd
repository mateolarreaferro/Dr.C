<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;grain2.orc
	sr = 44100
	kr = 4410
	ksmps = 10
	nchnls = 2

	instr	1
iamp	=	p4		;amp
ipitch	=	p5		;freq
idens	=	p6		;density 
iampoff	=	p7	     	;p7=amp variation range
ifrqoff	=	p8    		;p8=freq variation range
igdur	=	p9		;grain duration
;stereo =	p10		;(1=left, 0=right, .5=center)
igfn	=	1		;igfn = grain envelope function 
iwfn	=	2		;iwfn = grain waveform function 
imgdur	=	.5          ;imgdur = maximum grain duration
a1	grain	iamp,ipitch,idens,iampoff,ifrqoff,igdur,igfn,iwfn,imgdur
	outs	a1*p10,a1*(1-p10)
	endin
 

</CsInstruments>
<CsScore>
;grain2.sco 
f1 0 4096 10 1
f2 0 4096 19 1 .5 270 .5
;ins	act	dur	amp	hz	dens	ampoff		frqoff		dur	st
i1	0	5	10000	500	30	10000		200		.05	.5

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
