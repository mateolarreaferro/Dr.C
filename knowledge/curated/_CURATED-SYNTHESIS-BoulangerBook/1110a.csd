<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;-------------------------------------
       instr 1110
;--------------------------------; PARAMETER LIST
;p4  : AMPLITUDE
;p5  : CARRIER
;p6  : ATTACK
;p7  : DECAY
;p8  : MODULATOR FREQUENCY
;p9  : CARRIER FUNCTION TABLE
;p10 : MODULATOR TABLE
;--------------------------------
kenv    linen   p4,p6,p3,p7     ; ENVELOPE
acarr   oscil   1,p5,p9         ; CARRIER
amod    oscil   1,p8,p10        ; MODULATOR
aoutm   =       acarr*amod      ; MODULATED SIGNAL
        out     kenv*aoutm      ; OUTPUT
        endin

</CsInstruments>
<CsScore>
;1110A.SCO
;            (C) RAJMIL FISCHMAN, 1997
;-------------------------------------
;CARRIER WAVEFORM
f 1 0 8192 10 1
;MODULATOR WAVEFORM
f 2 0 8192 10 1 .8 .7 .6 .5
;---------------------------------------------------------
;            p3  p4     p5   p6   p7    p8     p9     p10
;INSTR START DUR AMP    CARR ATT  DEC   MOD    CARR   MOD
;                                       FREQ   FUNC   FUNC
;---------------------------------------------------------
i 1110    0     2   15000  300  .3   .3    300    1      2
i 1110    3     2   .      300  .    .     297.03 .      .
i 1110    6     2   .      300  .    .     212.13 .      .
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
