<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; chownFM.orc
; CHOWNING'S FM INSTRUMENT BASIC FM INSTRUMENT
 
          instr 1
 
inotedur  =         p3
imaxamp   =         ampdb(p4)
icarrfreq =         p5
imodfreq  =         p6
ilowndx   =         p7
indxdiff  =         p8-p7
                    
; PARAMETERS DEFINING THE ADSR AMPLITUDE ENVELOPE
; TIMES ARE A PERCENTAGE OF p3
; attack amp  =     p9     
; decay amp   =     p10    
; sustain amp =     p11    
; release amp =     p12    
; end amp     =     p13
; attack lngth =    p14
; decay lngth  =    p15
; sustain lngth =   p16
; release lngth =   p17

; PARAMETERS DEFINING THE ADSR FREQ DEVIATION ENVELOPE
; TIMES ARE A PERCENTAGE OF p3
; attack amp  =     p18    
; decay amp   =     p19    
; sustain amp =     p20    
; release amp =     p21    
; end amp     =     p22
; attack lngth =    p23
; decay lngth  =    p24
; sustain lngth =   p25
; release lngth =   p26

aampenv   linseg    p9,p14*p3,p10,p15*p3,p11,p16*p3,p12,p17*p3,p13
adevenv   linseg    p18,p23*p3,p19,p24*p3,p20,p25*p3,p21,p26*p3,p22
 
amodosc   oscili    (ilowndx+indxdiff*adevenv)*imodfreq,imodfreq,1
acarosc   oscili    imaxamp*aampenv,icarrfreq+amodosc,1

          out       acarosc
          endin

</CsInstruments>
<CsScore>
f1 0 4096 10 1

;                             final amplitude envelope              index(deviation) envelope
;                             values               time             valuestime  
;p1 p2 p3  p4  p5  p6  p7 p8  p9  p10 p11 p12 p13  p14 p15 p16 p17  p18 p19 p20 p21 p22  p23 p24 p25 p26
;in st dur amp car mod i1 i2  atk dec sus rel end  atk dec sus rel  atk dec sus rel end  atk dec sus rel

i1  0  0.6 88  440 440 0  5   0.0 1.0 .75 .66 0.0  .17 .17 .49 .17  0.0 1.0 .75 .66 0.0  .17 .17 .49 .17
s
f0 1
s

; chowdrum.sco
; DRUM SOUNDS WITH CHOWNING FM

f1 0 4096 10 1

;                             final amplitude envelope               index(deviation) envelope
;                             values               time              valuestime  
;p1 p2 p3  p4  p5  p6  p7 p8  p9  p10 p11 p12 p13  p14 p15 p16 p17  p18 p19 p20 p21 p22  p23 p24 p25 p26
;in st dur amp car mod i1 i2  atk dec sus rel end  atk dec sus rel  atk dec sus rel end  atk dec sus rel

i1   0   0.2 88   80  55 0  5   .75 .8  1.0 .15 .0  .125 .125 .25 .5  1.0 .0 .0  .0  .0  .125 .25 .25 .25
i1   +   0.2 88  411 377 0  5   .75 .8  1.0 .15 .0  .125 .125 .25 .5  1.0 .0 .0  .0  .0  .125 .25 .25 .25
i1   +   0.2 88  200 161 0  5   .75 .8  1.0 .15 .0  .125 .125 .25 .5  1.0 .0 .0  .0  .0  .125 .25 .25 .25
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
