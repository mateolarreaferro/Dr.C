<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

			instr 	901
inotedur	=		p3
imaxamp		=		ampdb(p4)
icarrfreq	=		p5
imodfreq	=		p6
ilowndx		=		p7
indxdiff	=		p8-p7

; PARAMETERS DEFINING THE ADSR AMPLITUDE ENVELOPE
; TIMES ARE A PERCENTAGE OF p3
;   attack amp  = p9     attack length  = p14
;   decay amp   = p10    decay length   = p15
;   sustain amp = p11    sustain length = p16
;   release amp = p12    release length = p17
;   end amp     = p13

; PARAMETERS DEFINING THE ADSR FREQ DEVIATION ENVELOPE
; TIMES ARE A PERCENTAGE OF p3
;   attack amp  = p18    attack length  = p23
;   decay amp   = p19    decay length   = p24
;   sustain amp = p20    sustain length = p25
;   release amp = p21    release length = p26
;   end amp     = p22

aampenv		linseg	p9, p14*p3, p10, p15*p3, p11, p16*p3, p12, p17*p3, p13
adevenv		linseg	p18, p23*p3, p19, p24*p3, p20, p25*p3, p21, p26*p3, p22
amodosc		oscili	(ilowndx+indxdiff*adevenv)*imodfreq, imodfreq, 1
acarosc		oscili	imaxamp*aampenv, icarrfreq+amodosc, 1
			out		acarosc
			endin

</CsInstruments>
<CsScore>
;TRUMPET SOUND WITH CHOWNING FM

f1 0 4096 10 1
;                             FINAL AMPLITUDE ENVELOPE              INDEX(DEVIATION) ENVELOPE
;                             VALUES               TIME             VALUESTIME  
;p1 p2 p3  p4  p5  p6  p7 p8  p9  p10 p11 p12 p13  p14 p15 p16 p17  p18 p19 p20 p21 p22  p23 p24 p25 p26
;IN ST DUR AMP CAR MOD I1 I2  ATK DEC SUS REL END  ATK DEC SUS REL  ATK DEC SUS REL END  ATK DEC SUS REL

i 901  0  0.6 88  440 440 0  5   0.0 1.0 .75 .66 0.0  .17 .17 .49 .17  0.0 1.0 .75 .66 0.0  .17 .17 .49 .17
s
f0 2
s
; chowdrum.sco
; DRUM SOUNDS WITH CHOWNING FM

f1 0 4096 10 1
;                             FINAL AMPLITUDE ENVELOPE               INDEX(DEVIATION) ENVELOPE
;                             VALUES               TIME              VALUESTIME  
;p1 p2 p3  p4  p5  p6  p7 p8  p9  p10 p11 p12 p13  p14 p15 p16 p17  p18 p19 p20 p21 p22  p23 p24 p25 p26
;IN ST DUR AMP CAR MOD I1 I2  ATK DEC SUS REL END  ATK DEC SUS REL  ATK DEC SUS REL END  ATK DEC SUS REL

i 901   0   0.2 88   80  55 0  5   .75 .8  1.0 .15 .0  .125 .125 .25 .5  1.0 .0 .0  .0  .0  .125 .25 .25 .25
i 901  .2   0.2 88  411 377 0  5   .75 .8  1.0 .15 .0  .125 .125 .25 .5  1.0 .0 .0  .0  .0  .125 .25 .25 .25
i 901  .4   0.2 88  200 161 0  5   .75 .8  1.0 .15 .0  .125 .125 .25 .5  1.0 .0 .0  .0  .0  .125 .25 .25 .25
s
f0 2
s
; chowmorf.sco
; INTERPOLATION FROM A DRUM TO A TRUMPET WITH CHOWNING FM

; NOTE DURATIONS FOR EACH EVENT WERE CALCULATED FROM AN EXPONENTIALFUNCTION AS FOLLOWS
;         EVENTNUM = NUMBER OF THE EVENT IN THE NOTE LIST, 0-19 FOR THE 20NOTE EVENTS BELOW
;         p3 = .2 + (2^(eventnum/2)/2^10)*.4
; THIS CREATES AN EXPONENTIAL INCREASE IN EACH NOTE GOING FROM .2 SECONDSDURATION FOR THE DRUM
; TO .6 SECONDS DURATION FOR THE TRUMPET 

f1 0 4096 10 1
;                                 FINAL AMPLITUDE ENVELOPEINDEX (DEVIATION) ENVELOPE
;                                 VALUES               TIMEVALUES               TIME  
;p1 p2 p3    p4  p5 p6 p7 p8  p9  p10 p11 p12 p13  p14 p15 p16 p17  p18 p19p20 p21 p22  p23 p24 p25 p26
;IN ST DUR   AMP C  M  I1 I2  ATK DEC SUS REL END  ATK DEC SUS REL  ATK DECSUS REL END  ATK DEC SUS REL
  
i 901  0  0.2    88 200 161  0  25  .75 .8 1.0 .15  .0 .125 .125 .25 .5  1.0  .0  .0  .0  .0 .125 .25 .25 .25  
i 901  +  0.2005  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2007  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2011  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2016  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2022  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2031  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2044  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2062  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2088  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2125  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2177  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2225  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2353  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.25    <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.2707  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.3     <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.3414  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.4     <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.4828  <   <   <  <  <   <   <   <   <   <    <   <    <   <    <   <   <   <   <    <   <   <   <
i 901  +  0.6    88 440 440  0  5  .0  1.0 .75 .66 .0  .17  .17  .49 .17  .0  1.0 .75 .66 .0  .17 .17 .49 .17
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
