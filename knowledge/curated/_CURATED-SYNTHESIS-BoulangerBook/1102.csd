<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          
;------------------------------------------------------- 
        instr 1102
;-------------------------------;PARAMETER LIST
; p4: amplitude
; p5: frequency
; p6: attack
; p7: decay
; p8: function table
;-------------------------------;
kenv    linen   p4, p6, p3, p7  ; ENVELOPE
asig    oscili  kenv, p5, p8    ; OSCILLATOR
;-------------------------------; OUTPUT
        out     asig            
        endin

</CsInstruments>
<CsScore>
;1102.SCO
;            (C) RAJMIL FISCHMAN, 1997
;---------------------------------------
;WAVEFORM FOR SOUND 1
f 1 0 8192 10 500  750  1000 1250 1000 750  500
;WAVEFORM FOR SOUND 2
f 2 0 8192 10 1000 1500 2000 2500 2000 1500 1000
;WAVEFORM FOR SOUND 3
f 3 0 8192 10 3500 0    3000 0    2500 0    2000 0 1500 0 1000 0 500
;---------------------------------------------
;           p3  p4     p5   p6     p7    p8
;INST START DUR AMP    FREQ ATTACK DECAY FUNC
;---------------------------------------------
i 1102    0     2   20000  100  .05    0.5   1    ;SOUND 2
i 1102    3     2   20000  110  .05    0.5   2    ;SOUND 2
i 1102    6     2   20000  110  .05    0.5   3    ;SOUND 3
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
