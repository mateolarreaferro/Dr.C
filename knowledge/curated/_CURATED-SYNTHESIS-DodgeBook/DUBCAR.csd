<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; dubcar.orc

; THIS INSTRUMENT IMPLEMENTS DOUBLE CARRIER FM TO IMPART A FORMANT AT 1500 Hz.


		instr 1

; p4		=		FREQ IN Hz.
; p5		=		AMP
; p6		=		MODULATION INDEX
; p7		=		fc2 AMP FACTOR

i1		=		p6*p4				; IMAX
i2		=		p7					; FACTOR FOR REDUCING AMP OF fc2
i3		=		int((1500/p4)+.5)		; FORMANT AT FREQ OF HARMONIC CLOSEST TO 1500 Hz
i3		=		i3 * p4				; fc2
i4		=		p4					; fc1

ampenv1	linen	i1,p3*.1,p3,p3*.9
ampenv2	linen	p5,.01,p3,.01
ampenv3	linen	ampenv2*.2,.04,p3,.04

a1		oscili	ampenv1,i4,1
a2		oscili	ampenv2,a1+p4,1
a3		=		i2*a1
a4		oscili	ampenv3,a3+i3,1
		out		a2+a4

		endin

</CsInstruments>
<CsScore>
; dubcar.s

; This is a sample score for the double carrier instrument

; sine wave
f1 0 512 9 1 1 0

f0 1
i1      0       .1      261     10000   2.6     .2
i1      .5      .5      440     .       .       .
i1      1.5     1.5     880     .       .       .
i1      4       3       261     .       .       .
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
