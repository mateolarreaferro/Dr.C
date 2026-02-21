<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gadrysig  init      0                        ; INITIALIZE GLOBAL VARIABLE

          instr     2301
kenv      linseg    9000, .1, 1000, p3-.1, 0    ; ENVELOPE
anoise    randi     kenv, sr/2, .5           ; CREATE NOISE BURST
gadrysig  =         gadrysig+anoise          ; ADD BURST TO GLOBAL VAR
          endin

          instr     2302
irevtime  =         p4
areverb   reverb    gadrysig, irevtime       ; REVERBERATE SIGNAL
          out       areverb                  ; OUTPUT SIGNAL
gadrysig  =         0                        ; ZERO OUT GLOBAL VARIABLE
          endin

</CsInstruments>
<CsScore>


; INS   ST  DUR
i 2301  0   .15
; INS   ST  DUR REVERB_TIME
i 2302  0   5.3 5
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
