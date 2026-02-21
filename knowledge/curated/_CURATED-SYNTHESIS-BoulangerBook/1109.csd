<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;--------------------------------------
        instr 1108              ; USED TO PLAY PURE SINEWAVES
;-------------------------------; PARAMETER LIST
;p4  :AMPLITUDE
;p5  :CARRIER
;p6  :ATTACK
;p7  :DECAY
;p8  :FUNCTION TABLE
;-------------------------------
kenv    linen   p4, p6, p3, p7  ; ENVELOPE
asig    oscili  kenv, p5, p8    ; OSCILLATOR
;-------------------------------; OUTPUT
        out     asig
        endin


        instr 1109              ; SIDE BANDS ONLY
;-------------------------------; PARAMETER LIST
;p4  : AMPLITUDE
;p5  : CARRIER
;p6  : ATTACK
;p7  : DECAY
;p8  : MODULATOR
;p9  : FUNCTION
;-------------------------------
kenv    linen   p4, p6, p3, p7  ; ENVELOPE
acarr   oscili  1, p5, p9       ; CARRIER
amod    oscili  1, p8, p9       ; MODULATOR
asig    =       acarr*amod      ; MODULATION
        out     kenv*asig       ; OUTPUT
        endin

</CsInstruments>
<CsScore>
;1109.SCO  SINEWAVE MODULATING SINEWAVE
;            (C) RAJMIL FISCHMAN, 1997
;----------------------------------------
;sinewave
f 1 0 8192 10 1      

;SECTION 1      CARRIER 400 HZ, MODULATOR 10 HZ
;----------------------------------------------
;            p3  p4     p5    p6     p7    p8
;INSTR START DUR AMP    FREQ  ATTACK DECAY FUNC
;----------------------------------------------
i 1108     0     2   15000  400   .3     .3    1
i 1108     3     2   15000  10    .3     .3    1
;---------------------------------------------------
;            p3  p4     p5    p6     p7    p8   p9
;INSTR START DUR AMP    CARR  ATTACK DECAY MOD  MOD
;                       FREQ               FREQ FUNC
;---------------------------------------------------
i 1109     6     2   25000  400   .3     .3    10   1
s
;SECTION 2      CARRIER 400 HZ, MODULATOR 170 HZ
;----------------------------------------------
;            p3  p4     p5    p6     p7    p8
;INSTR START DUR AMP    FREQ  ATTACK DECAY FUNC
;----------------------------------------------
i 1108     1     2   15000  400   .3     .3    1
i 1108     4     2   15000  170   .3     .3    1
;---------------------------------------------------
;            p3  p4     p5    p6     p7    p8   p9
;INSTR START DUR AMP    CARR  ATTACK DECAY MOD  MOD
;                       FREQ               FREQ FUNC
;---------------------------------------------------
i 1109     7     2   25000  400   .3     .3    170  1
s
;SECTION 3      CARRIER 400 HZ, MODULATOR 385 HZ
;----------------------------------------------
;            p3  p4     p5    p6     p7    p8
;INSTR START DUR AMP    FREQ  ATTACK DECAY FUNC
;----------------------------------------------
i 1108     1     2   15000  400   .3     .3    1
i 1108     4     2   15000  385   .3     .3    1
;---------------------------------------------------
;            p3  p4     p5    p6     p7    p8   p9
;INSTR START DUR AMP    CARR  ATTACK DECAY MOD  MOD
;                       FREQ               FREQ FUNC
;---------------------------------------------------
i 1109     7     2   25000  400   .3     .3    385  1
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
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
