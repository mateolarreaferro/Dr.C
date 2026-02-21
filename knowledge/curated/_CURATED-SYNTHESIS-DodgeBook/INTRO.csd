<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; INTRO.O - A SIMPLE ORCHESTRA WITH ONE INSTRUMENT.  THIS INSTRUMENT 
; CONSISTS OF ONE OSCILLATOR WITH AMPLITUDE DEFINED BY A LINEN STATEMENT


; p3           =         DURATION OF A NOTE
; p4           =         MAN AMPLITUDE FOR LINEN STATEMENT
; p5           =         FREQUENCY IN HZ
; p6           =         ATTACK TIME IN SECONDS
; p7           =         DECAY TIME IN SECONDS

               instr     1
k1             linen     p4,p6,p3,p7
a1             oscili    k1,p5,1
               out       a1
               endin

</CsInstruments>
<CsScore>
; INTRO.S - A SIMPLE SCORE USING INSTRUMENT 1 FROM INTRO.O

; WAVEFORM FOR THE OSCILLATOR - A SINE WAVE

f1 0 1024       9       1       1       0

;       start   dur     amp     freq    attack  decay
i1      1       3.5     10000   263.6   .5      1.5
i1      2       .       .       349.2   .       .
i1      3       .       .       392.2   2.0     .1
i1      4       .       .       523.2   .       .
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
