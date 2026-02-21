<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;phimonics.orc

sr = 44100
kr = 4410
ksmps = 10
nchnls = 1

instr 1
imaxamp =	10000
ipchclass	=	100*frac(p5)
iphi	=	(1+sqrt(5))/2
ifact	pow iphi,ipchclass/9
ifreq1	=	cpspch(6.00) * ifact
iamp1	tablei 1+ipchclass/9,1
ifreq2	=	ifreq1*iphi
iamp2	tablei 2+ipchclass/9,1
ifact	pow iphi,2
ifreq3	=	ifreq1*ifact
iamp3	tablei 3+ipchclass/9,1
ifact	pow iphi,3
ifreq4	=	ifreq1*ifact
iamp4	tablei 4+ipchclass/9,1
ifact	pow iphi,4
ifreq5	=	ifreq1*ifact
iamp5	tablei 5+ipchclass/9,1
ifact	pow iphi,5
ifreq6	=	ifreq1*ifact
iamp6	tablei 6+ipchclass/9,1
ifact	pow iphi,6
ifreq7	=	ifreq1*ifact
iamp7	tablei 7+ipchclass/9,1
ifact	pow iphi,7
ifreq8	=	ifreq1*ifact
iamp8	tablei 8+ipchclass/9,1
kenv	linseg	0,0.05,p4,p3-0.05,0		; p4 is max amp
asig1	oscili	iamp1,ifreq1,2 			; fn table #2 is a sine wave
asig2	oscili	iamp2,ifreq2,2
asig3	oscili	iamp3,ifreq3,2
asig4	oscili	iamp4,ifreq4,2
asig5	oscili	iamp5,ifreq5,2
asig6	oscili	iamp6,ifreq6,2
asig7	oscili	iamp7,ifreq7,2
asig8	oscili	iamp8,ifreq8,2
		out		kenv*imaxamp*(asig1+asig2+asig3+asig4+asig5+asig6+asig7+asig8) 
endin

</CsInstruments>
<CsScore>
; Bill Alves alves@hmc.edu
; phimonics.sco
; gaussian envelope
f1	0	8	20	9
; sine wave
f2	0	8192 10	1

; instr start dur	amp	pitch
i1	0	1	1	8.00
i1	+	.	1	8.01
i1	+	.	1	8.02
i1	+	.	1	8.03
i1	+	.	1	8.04
i1	+	.	1	8.05
i1	+	.	1	8.06
i1	+	.	1	8.07
i1	+	.	1	8.08
i1	+	.	1	9.00
i1	+	.	1	9.01
i1	+	.	1	9.02
i1	+	.	1	9.03
i1	+	.	1	9.04
i1	+	.	1	9.05
i1	+	.	1	9.06
i1	+	.	1	9.07
i1	+	.	1	9.08
i1	+	.	1	10.00
i1	+	.	1	10.01
i1	+	.	1	10.02
i1	+	.	1	10.03
i1	+	.	1	10.04
i1	+	.	1	10.05
i1	+	.	1	10.06
i1	+	.	1	10.07
i1	+	.	1	10.08
i1	+	.	1	11.00
e
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
