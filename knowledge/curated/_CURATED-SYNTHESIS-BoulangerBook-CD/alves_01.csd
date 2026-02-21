<CsoundSynthesizer>
<CsOptions>

</CsOptions>

<CsInstruments>
sr	=	44100
kr	=	4410
ksmps	=	10
nchnls	=	1

giref	init	440	 
 	
giref1 init 440	 	 
 	 	 	 
 	instr 1	 	;number this instrument 1 so it gets called first
giref	=	p7	 
 	endin	 	 




	instr	202	 
ioct	=	int(p5)	;returns the octave
ipchclass	=	100*frac(p5)	;returns the pitch class number
ilookup	=	12*(ioct-6)+ipchclass	;octaves below 6 are not valid
ifreq	tablei	ilookup, 1	;tuning table is fn table #1
 		; go on to use ifreq as normal
asig	oscils p4*32000, ifreq, 0
out asig
endin



	instr	203
ioct	=	int(p5)	; the octave
ipchclass	=	100*frac(p5)	; the pitch class # (0-47)
ifreq	=	cpsoct(ioct+ipchclass/48)	; covert it to oct format
 		; go on to use ifreq as normal
asig	oscils p4*32000, ifreq, 0
out asig
endin



	instr	204	 
ifreq	cps2pch	p5, 48	; 48 = # of pitches per octave
 	 	; go on to use ifreq as normal

ifreq	cps2pch	p5, -1	;refer to multiplier table #1
asig	oscils p4*32000, ifreq, 0
out asig
endin



 	instr	205	 
ioct	=	int(p5)	;returns the octave part of the pitch #
ipchclass	=	100*frac(p5)	;returns the pitch class number (0-11)
ipch	tablei	ipchclass, 1	;any fraction left will be truncated
ioctfact	pow	2, ioct-8	;the 8th octave is in the table
ifreq	=	ipch*ioctfact	;each octave is a power of two
 		; go on to use ifreq as normal
asig	oscils p4*32000, ifreq, 0
	
out		asig
	
	endin


	 	 
 	instr 2306	 	 
ioct	pow	2, p7-8	;get octave factor
ifreq	=	giref*ioct*p5/p6	;freq = 1/1 ref*oct*num/den
asig	oscils p4*32000, ifreq, 0
out asig
endin




	instr 207	 	 	 
 	if	p7=0 igoto suc	 	 
giref1	=	p7	 	;if p7 != 0, it is the new 1/1
ifreq	=	giref1*p5/p6	 	;calculate freq
igoto	cont	 	 	;go on to the rest of the instr
suc:	 	 	 
ifreq	=	giref1*p5/p6	 	;if p7 = 0, use last reference
giref1	=	ifreq	 	;and set it to current freq

cont:	 
asig	oscils p4*32000, ifreq, 0
out asig
endin



	instr 208	 	 
ioct	=	octpch(p5)	;convert from pch to oct format
istretch	=	ioct*1215/1200	;multiply by stretch factor
ifreq	=	cpsoct(istretch)	;go on to use ifreq as normal
asig	oscils p4*32000, ifreq, 0
out asig
endin

	instr	209	 
itritave	=	int(p5)	;returns the tritave number
istepno	=	100*frac(p5)	;returns the step # (00 to 12)
ifact	pow	3, itritave+istepno/13	;multiplication factor
ifreq	=	ifact*cpspch(1.00)	;1.00 (C1) is the base pitch
asig	oscils p4*32000, ifreq, 0
out asig
endin

</CsInstruments>
<CsScore>

;F1 is tuning table for Gamelan

f1	0	64	-2	59	62	62	73	73	80	84	86	93	102
 	109	110	118	126	128	146	145	159	167	172	189	204	219
 	220	234	248	257	287	294	321	332	348	381	406	437	439
 	471	501	519	580	597	641	671	698	778	817	898	886	946
 	1040	1041	1202	1248	1318	1388	1432	1604	1656	1824	1820	1935	2134
 	2142

;F2 is sine for oscil




;F10 is a multiplier table for pitch conversion
; Bhatkande's theoretical North Indian Tuning (subset of 2TET)

f10	0 16	-2	1.000000	1.065041	1.134313	1.208089
 	1.246758	1.327849	1.414214	1.506196	1.604160	1.708495	1.819619
 	1.877861	 	 	 	 	 	 

;F11 is a multiplier tuning table for one-quarter-comma meantone temperament

f11 0	16	-2	1.000000	1.044906	1.118034	1.196279
 	1.250000	1.337481	1.397542	1.495349	1.562500	1.671850	1.788854
 	1.869185	 

; Score Excerpt 1 (figure 2.6)
    
; Measure 1
; p1	p2		p3		p4	p5
; instr	start	dur		amp	pitch

i 205	0		0.5		0.2	7.32
i 205	+		.		0.3	7.34
i 205	+		.		0.4	7.36
i 205	+		.		0.5	7.38
i 205	+		.		0.4	7.36
i 205	+		.		0.3	7.34
; Measure 2
i 205	+		.		0.2	7.32
i 205	+		.		0.3	7.34
i 205	+		.		0.4	7.36
i 205	+		.		0.5	7.38
i 205	+		.		0.4	7.36
i 205	+		.		0.3	7.34
i 205	+		.		0.2	7.32

s    

; Score Excerpt 2 (figure 2.7) 

; using p-fields to express just intonation as ratio of octave, with p5 and p6 as numerator and denominator of the ratio, and p7 as the octave multiplier

;p1		p2			p3		p4	p5	p6	p7	 
;instr	start		dur		amp	num	den	octave	 

i2306		0		0.125	0.9	7	4	10	;7/4 ratio
i2306		0		0.5		0.9	1	1	6	;1/1
i2306		0		0.5		0.9	1	1	7	;1/1
i2306		0		29.0	0.9	1	1	5	;1/1
i2306		0		29.0	0.9	1	1	6	;1/1
i2306		0.125	0.125	0.9	11	8	10	;11/8
i2306		0.250	0.125	0.9	1	1	9	;1/1
i2306		0.375	0.125	0.9	7	4	10	;7/4
i2306		0.5		0.125	0.9	3	2	10	;3/2
i2306		0.5		0.5		0.9	3	2	7	;3/2
i2306		0.5		0.5		0.9	7	6	8	;7/6
s







</CsScore>
</CsoundSynthesizer>

<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: -900 -1504 396 974
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView nobackground {59367, 11822, 65535}
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
ioGraph {26, 118} {350, 150} table 0.000000 1.000000 
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1323</x>
 <y>61</y>
 <width>396</width>
 <height>974</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider1</objectName>
  <x>5</x>
  <y>5</y>
  <width>20</width>
  <height>100</height>
  <uuid>{7b939956-5c8a-465d-b135-236b70f375f4}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBGraph">
  <objectName/>
  <x>26</x>
  <y>118</y>
  <width>350</width>
  <height>150</height>
  <uuid>{a8fe05bf-c7d9-4548-bad3-42003bca8043}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <value>0</value>
  <objectName2/>
  <zoomx>1.00000000</zoomx>
  <zoomy>1.00000000</zoomy>
  <dispx>1.00000000</dispx>
  <dispy>1.00000000</dispy>
  <modex>lin</modex>
  <modey>lin</modey>
  <showSelector>true</showSelector>
  <showGrid>true</showGrid>
  <showTableInfo>true</showTableInfo>
  <showScrollbars>true</showScrollbars>
  <enableTables>true</enableTables>
  <enableDisplays>true</enableDisplays>
  <all>true</all>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
