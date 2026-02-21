<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;--------------------------------------
        instr 1110      
;-------------------------------; PARAMETER LIST
;p4  : AMPLITUDE
;p5  : CARRIER
;p6  : ATTACK
;p7  : DECAY
;p8  : MODULATOR FREQUENCY
;p9  : CARRIER FUNCTION TABLE
;p10 : MODULATOR TABLE
;-------------------------------
kenv    linen  p4, p6, p3, p7   ; ENVELOPE
acarr   oscil  1, p5, p9        ; CARRIER
amod    oscil  1, p8, p10       ; MODULATOR
aoutm   =      acarr*amod       ; MODULATED SIGNAL
        out    kenv*aoutm       ; OUTPUT
        endin

</CsInstruments>
<CsScore>
;1110.SCO
;            (C) RAJMIL FISCHMAN, 1997
;---------------------------------------
;SINEWAVE CARIER WAVEFORM
f 1 0 4096 10 1
;5 HARMONIC MODULATOR WAVEFORM
f 2 0 4096 10 1 .95 .86 .77 .68
;--------------------------------------------------
;            p3  p4    p5   p6  p7  p8   p10   p11
;INSTR START DUR AMP   CARR ATT DEC MOD  CARR  MOD
;                      FREQ         FREQ FUNC  FUNC
;--------------------------------------------------
;CARRIER: 440 HZ      MODULATOR: 110 HZ
i 1110    0     2   15000 440  .3  .3  110  1     2
;CARRIER: 440 Hz      MODULATOR: 134 Hz
i 1110    3     2   15000 440  .3  .3  134  1     2
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
