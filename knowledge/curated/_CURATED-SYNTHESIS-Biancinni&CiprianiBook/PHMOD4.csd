<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

	instr	1

adelay1	init	0	; initializes the adelay1 variable
a3	init	0	; and the a3 variable

ifrq	=	cpspch(p5) 	; pitch to Hz conversion
idelay1	=	1/ifrq		; set the delay of the 1st delay line
iamp	=	ampdb(p4)*10
iatk	=	p6		; duration of the attack transient 
ifeed	=	p7		; feedback factor
imaxemb	=	p8		; max value for the embouchure
icutoff	=	p9		; cutoff freq for low-pass filter

kembofs linseg 	0,.1,imaxemb,p3-.1,0 ; pressure applied against embouchure
amouthp linseg 	0,iatk,1,p3-iatk,1,.001,0 ; air flow pressure
avibr	oscil	.05,5,1	; oscillator for vibrato
amouthp	=	amouthp+avibr
a1	=	amouthp - a3 * ifeed
adelay1	delay	a1,idelay1
ahp1	atone	adelay1,50	; four high-pass filters ...
ahp2	atone	ahp1,50	; ...in series ...
ahp3	atone	ahp2,50	; ...equivalent to a 4th order ...
ahp	atone	ahp3,50	; ...high-pass
afilt	tone	adelay1,icutoff	; signal after reflection energy loss
adelay2	delay	afilt,idelay1
a2	=	adelay2 + amouthp + kembofs
k2	downsamp a2 ; abs value converter works only at krate!
			         ; downsamp opcode discussed in section 17.2
ktab	table	abs(k2),99,2
a3	=	a2 * ktab	
kenv	linseg	1,p3-.1,1,.1,0
aout	=	ahp*iamp*kenv
	out	aout
	endin


</CsInstruments>
<CsScore>
;phmod4.sco
; clarinet.sco: 
; incipit of "Peter and the Wolf - The Cat" by Sergeij Sergey Prokofiev
f 1	0	4096	10	1	
f 99	0	4096	7	0	3072	1	1024	1	
t0	80
;					atk   feedback	embouchure	cutoff
i 1	0.	0.25	90.	8.07	0.05	1.	0.	6000.
i 1	0.5	0.25	90.	9	.	.	.	.
i 1	1.	1.	90.	9.04	.	.	.	.
i 1	2.	0.25	90.	9	.	.	.	.
i 1	2.5	0.25	90.	8.07	.	.	.	.
i 1	3.	1.	90.	8.06	.	.	.	.
i 1	4.	0.25	90.	8.07	.	.	.	.
i 1	4.5	0.25	90.	9	.	.	.	.
i 1	5.	0.25	90.	9.04	.	.	.	.
i 1	5.5	0.25	90.	9.07	.	.	.	.
i 1	6.	1.25	90.	9.05	.	.	.	.
i 1	7.5	0.25	90.	9.04	.	.	.	.
i 1	8.	0.25	90.	9.07	.	.	.	.
i 1	8.5	0.25	90.	9.05	.	.	.	.
i 1	9.	0.25	90.	9.04	.	.	.	.
i 1	9.5	0.25	90.	9.02	.	.	.	.
i 1	10.	0.25	90.	9.05	.	.	.	.
i 1	10.5	0.25	90.	9.04	.	.	.	.
i 1	11.	0.25	90.	9.02	.	.	.	.
i 1	11.5	0.25	90.	9	.	.	.	.
i 1	12.	0.25	90.	9.04	.	.	.	.
i 1	12.5	0.25	90.	9.02	.	.	.	.
i 1	13.	1.	90.	8.11	.	.	.	.
i 1	14.	1.	90.	9	.	.	.	.
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
