<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;scale.orc

	instr	1

;first separate the integer part (octaves) from the fractional part 
;(semitones) of p5 

ioct	=	int(p5)	;octaves 
isem	=	frac(p5)*100	;semitones, multiplied by 100 (hence 8.01 yields 1, 				;8.11 yields 11 etc). These numbers are used, then, 				;as index to function table n.2, returning new 				;pitch values: each tempered pitch is 						;replaced by some non-tempered pitch stored in the 				;table

isem1		table	isem,2,0	;takes a value from function table 2, at the
					;position specified by isem
					;(3rd argument = 0, i.e no index scaling: 					;therefore, isem=0 takes the first value, 					;isem =1 takes the second, isem =3 the 					;fourth, etc.) 

ifrq	=	cpspch(ioct+isem1) 	;convert octave+chroma to Hertz
iamp	=	ampdb(p4)
a1	oscili	iamp, ifrq, 1
	out	a1
	endin

	instr	2

;use table to build a non-equally tempered tuning system, with interpolation

ioct	=	int(p5)		;octave 
isem	=	frac(p5)*100		;semitone, multiplied by 100 
					 
isem1	tablei	isem, 2, 0		;same as instr 1, but interpolated table 					;read, isem1 can be fractional.
ifrq	=	cpspch(ioct+isem1) 	;convert octave+chroma to Hertz
iamp	=	ampdb(p4)		;convert dB values to absolute amplitude
a1	oscil	iamp, ifrq, 1
	out	a1
	endin


</CsInstruments>
<CsScore>
;scale.sco
f1 0 4097 10 1 ;(sine for oscili)
f2  0  17 -2 0 .015 .02 .035 .04 .055 .06 .075 .08 .095 .10 .115 0 0 0 0 0
;the above GEN02 is negative, i.e. normalization is omitted
;new pitches replace the traditional pitches C-C#-D-D#...B. 
;As the table has 17 locations(= a-power-of-two-plus-1), 5 void p-fields 
;must be appended to the utilizable locations

i1 	0 	.5 	80 	8	;instrument 1 has a non-interpolated table 					;read, therefore only integer numbers 						;(semitones) can be used as index to the 					;function table
i1 	+ 	.5 	80 	8.04
i1 	+ 	.5 	80 	8.07
i1 	+ 	.5 	80 	8.10

i2 	3	.5 	80 	8     ;instrument 2 has an interpolated table read 					;(tablei), therefore it is possible to use 					;non-integer values (smaller than semitones) 					;to index the function table (in this 						;example quarter-tones are used)
i. 	+ 	. 	80 	8.005
i. 	+ 	. 	80 	8.01
i. 	+ 	. 	80 	8.015
i. 	+ 	. 	80 	8.02
i. 	+ 	. 	80 	8.025
i. 	+ 	. 	80 	8.03
i. 	+ 	. 	80 	8.035
i. 	+ 	.	80 	8.04
i. 	+ 	. 	80 	8.045
 
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
