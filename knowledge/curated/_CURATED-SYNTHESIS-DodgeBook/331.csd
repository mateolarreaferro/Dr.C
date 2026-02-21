<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


;;; DESIGN TO PRODUCE GRADUAL CHANGE OF OCTAVE, FROM RISSET ;;; FIGURE 3.31 FROM DODGE & JERSE, P.99 

		instr 1
iphsoff 	=	(65/5)*.01

ka1		=		p4
kf1		=		1/p3
iph1 	=		0
kamp1 	oscil 	ka1,kf1,2,iph1
kfreq1 	=		p5
asig1 	oscil 	kamp1,kfreq1,1

ka2		=		p4
kf2		=		1/p3
iph2 	=		iph1+iphsoff
kamp2 	oscil 	ka2,kf2,2,iph2
kfreq2 	=		p5*2
asig2 	oscil 	kamp2,kfreq2,1

ka3		=		p4
kf3		=		1/p3
iph3 	=		iph2+iphsoff
kamp3 	oscil 	ka3,kf3,2,iph3
kfreq3 	=		p5*3
asig3 	oscil 	kamp3,kfreq3,1

ka4		=		p4
kf4		=		1/p3
iph4 	=		iph3+iphsoff
kamp4 	oscil 	ka4,kf4,2,iph4
kfreq4 	=		p5*4
asig4 	oscil 	kamp4,kfreq4,1

ka5		=		p4
kf5		=		1/p3
iph5 	=		iph4+iphsoff
kamp5 	oscil 	ka5,kf5,2,iph5
kfreq5 	=		p5*5
asig5 	oscil 	kamp5,kfreq5,1

add		=		asig1+asig2+asig3+asig4+asig5
kenv 	linseg 	0,p3/2,1,p3/2,0
aout 	=		add*kenv
		out		aout
		endin



</CsInstruments>
<CsScore>
;;; SCORE FOR 3.31

f1 0 8192 10 1
f2 0 128 8 0 .5 0 63.5 1 63.5 0 .5 0
;p1 p2 p3	p4 p5
;inst start length amp freq
i1 0.00 15.00 5000 100

e
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
