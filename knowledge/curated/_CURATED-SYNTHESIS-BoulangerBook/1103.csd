<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>



;----------------------------------------- 
        instr 1103
;-----------------------------------------------;PARAMETER LIST
;p4 : OVERALL AMPLITUDE
;p5 : REFERENCE FREQUENCY (FUNDAMENTAL IF SPECTRUM IS HARMONIC)
;p6,p8,p10,p12,p14,p16,p18 : RELATIVE AMPLITUDES OF COMPONENTS
;p7,p9,p11,p13,p15,p17,p19 : RELATIVE FREQUENCIES OF COMPONENTS
;--------------------------------------------------------------      
kenv    linen   p4,.1,p3,.1                     ; OVERALL ENVELOPE
;-----------------------------------------------; COMPONENTS
a1      oscil   p6,p5*p7,1                      ; 1st COMPONENT
a2      oscil   p8,p5*p9,1                      ; 2nd COMPONENT
a3      oscil   p10,p5*p11,1                    ; 3rd COMPONENT
a4      oscil   p12,p5*p13,1                    ; 4th COMPONENT
a5      oscil   p14,p5*p15,1                    ; 5th COMPONENT
a6      oscil   p16,p5*p17,1                    ; 6th COMPONENT
a7      oscil   p18,p5*p19,1                    ; 7th COMPONENT
        out     kenv*(a1+a2+a3+a4+a5+a6+a7)/7   ; MIX AND OUTPUT 
        endin


</CsInstruments>
<CsScore>
; 1103.SCO  PRODUCES HARMONIC SOUND FOLLOWED BY INHARMONIC ONE
;             (C) RAJMIL FISCHMAN, 1997
;---------------------------------------------------------------
;SINEWAVE
f 1 0 8192 10 1
;--------------------------------------------------------------
;            p3      p4      p5     p6,p8... p18   p7,p9... p19
;INSTR  START   DUR  OVERALL FUND   RELATIVE       RELATIVE
;                    AMP     FREQ   AMPLITUDES     FREQUENCIES
;--------------------------------------------------------------
;HARMONIC SOUND
i 1103      0       2    20000   280    1              1
                                    .68            2
                                    .79            3
                                    .67            4
                                    .59            5
                                    .82            6
                                    .34            7
;INHARMONIC SOUND
i 1103      3       2    20000   280    1              1
                                    .68            1.35
                                    .79            1.78
                                    .67            2.13
                                    .59            2.55
                                    .82            3.23
                                    .34            3.47
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
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
