<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1703 
kphrase   linen     1, p3*.5, p3, p3*.5      ; GRADUAL RISE&FALL IN AMP OVER p3
kdur      line      .1, p3, 1                ; kdur CHANGES FROM .1 TO 1 OVER p3
start:    timout    0, i(kdur), continue     ; BRANCH TO CONTINUE FOR kdur SECS,
          reinit    start                    ; THEN REINIT ALL, BEGINNING WITH
continue:                                    ; ... THE TIMOUT
kgate     oscil1    0, p4, .1, 2             ; f2 HAS ENVSHAPE; DUR FIXED AT .1 
asig      oscili    kgate, 1000, 1           ; MAKE a1 KHz BEEP TONE, USING f1
          out       asig*kphrase             ; APPLY THE OVERALL PHRASE DYNAMIC
          endin                              ; REINITIALIZATION STOPS HERE

</CsInstruments>
<CsScore>
f 1 0   8192    10  1                       
;LINEAR ENVELOPE FUNCTION                                       
f 2 0   512 7   0   41  1   266 1   205 0
;         start    dur     amp         
i    1703      0      4       20000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
 <height>210</height>
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
