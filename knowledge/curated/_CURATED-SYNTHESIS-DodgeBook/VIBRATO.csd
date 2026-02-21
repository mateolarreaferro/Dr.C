<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; Vibrato.o



                                   ;P4=FREQUENCY IN HZ
                                   ;P5=AMP
                                   ;P6=VIBRATO WIDTH AS A PERCENTAGE OF CENTER FREQUENCY
                                   ;P7=VIBRATO FREQUENCY

               instr     1
kdev           randi     p6,125              ;RANDOM VIBRATO WIDTH DEVIATION OF +/- P6
avib           oscil     p6,p7,1             ;VIBRATO HAS THE SHAPE OF A SINE WAVE
avib           =         (avib+kdev)+1       ;ADD 1 FOR MULTIPLICATION

afreq          =         avib*p4             ;APPLY VIBRATO TO P4 (FREQ IN SCORE)
aenv           linen     p5,.01,p3,.05       ;AMPLITUDE ENVELOPE
asig           oscili    aenv,afreq,1        ;SINE WAVE WITH VIBRATO AND AMPLITUDE ENVELOPE
               out       asig
               endin


</CsInstruments>
<CsScore>

; Vibrato.s

; Sine wave
f1      0       512    9       1       1       0

;       start   dur     freq    amp     vibwidth        vibfreq
i1      1       3       440     15000   .0075           6
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
