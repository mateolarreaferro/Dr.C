<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;---------------------------------------
        instr 1112              ; BASIC WAVESHAPING INSTRUMENT
;-------------------------------; PARAMETER LIST
;p4 : AMPLITUDE
;p5 : FREQUENCY
;p6 : ATTACK
;p7 : DECAY
;p8 : OSCILLATOR FUNCTION
;p9 : WAVESHAPING FUNCTION
;-------------------------------
ioffset =       ftlen(p9)/2-1    ; OFFSET
kenv    linen   p4, p6, p3, p7   ; ENVELOPE
ain     oscil   ioffset, p5, p8  ; INPUT 
awsh    tablei  ain,p9,0,ioffset ; WAVESHAPING VALUE
        out     kenv*awsh        ; OUTPUT
        endin


</CsInstruments>
<CsScore>
;1112.SCO
;             (C) RAJMIL FISCHMAN, 1997
;--------------------------------------
;INPUT OSCILLATOR: SINWAVE
f 1 0 8192 10 1
;WAVESHAPING FUNCTIONS
;NO DISTORTION (LINEAR)
f 2 0 8192 7 -1 8192  1
;CLOSE TO LINEAR FUNCTION (SECOND HALF OF COSINE)
f 3 0 8192 9 0.5 1 270
;HEAVIER DISTORTION (DISCONTINUOUS FUNCTION)
f 4 0 8192 7 -1 2048 -1 0 0.3 2048 0 0 -0.5 2048 0 0 0.8 2048 0.8
;--------------------------------------------------
;            p3   p4    p5   p6     p7    p8   p9
;INSTR START DUR  AMP   FREQ ATTACK DECAY OSC  WSH
;                                         FUNC FUNC
;--------------------------------------------------
i 1112    0     1    20000 440  .1     .1    1     2
i 1112    1.5   1    .     .    .1     .1    1     3
i 1112    3     1    .     .    .1     .1    1     4
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
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
