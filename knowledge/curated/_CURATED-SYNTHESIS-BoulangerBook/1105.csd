<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


;-------------------------------------- 
        instr 1105              ; USES RAND TO GENERATE WHITE NOISE
;-------------------------------; PARAMETER LIST
;p4  : AMPLITUDE
;p5  : NOT USED
;p6  : ATTACK
;p7  : DECAY
;-------------------------------
kenv    linen   p4,p6,p3,p7     ; ENVELOPE
asig    rand    kenv            ; NOISE SOURCE
        out     asig            ; OUTPUT
        endin


        instr 1106              ; USES BUZZ TO GENERATE A TRAIN OF PULSES
;-------------------------------; PARAMETER LIST
;p4  : AMPLITUDE
;p5  : FUNDAMENTAL
;p6  : ATTACK
;p7  : DECAY
;-------------------------------
iinh     =      int(sr/2/p5)    ; MAXIMUM NUMBER OF HARMONICS
kenv    linen   p4,p6,p3,p7     ; ENVELOPE
asig    buzz    kenv,p5,iinh,1  ; OSCILLATOR
        out     asig            ; OUTPUT
        endin



</CsInstruments>
<CsScore>
;1105.SCO   NOISE AND TRAIN OF PULSES GENERATORS
;             (C) RAJMIL FISCHMAN, 1997
;------------------------------------------------
;SINEWAVE
f1 0 8192 10 1
;NOISE WITH RAND
;------------------------------------------
;            p3   p4    p5     p6     p7      
;INSTR START DUR  AMP   UNUSED ATTACK DECAY      
;------------------------------------------
i 1105     0     2    9000  0      .1     .1
s
;TRAIN OF PULSES WITH BUZZ
;------------------------------------------
;            p3   p4    p5     p6     p7      
;INSTR START DUR  AMP   FREQ   ATTACK DECAY      
;------------------------------------------
i 1106     1.5   2    30000 75     .1     .1 
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
