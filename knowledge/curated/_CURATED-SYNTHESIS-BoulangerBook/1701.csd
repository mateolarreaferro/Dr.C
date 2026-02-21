<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1701 
start:    timout    0, .25, continue    ; BRANCH TO CONTINUE FOR .25secs, THEN...
          reinit    start               ; REINIT ALL, BEGINNING WITH THE TIMOUT
continue:           
kgate     linen     p4, .02, .25, .1    ; MAKE A .25-SECOND LINEAR ENVELOPE
asig      oscili    kgate, 1000, 1      ; MAKE A 1 kHz BEEP TONE, USING f1
          out       asig 
          endin                         ; REINIT WILL END HERE, IF NO RIRETURN

</CsInstruments>
<CsScore>
f 1 0   8192    10  1                       
;             START   DUR    AMP         
i    1701     0       4      20000
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>180</height>
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
