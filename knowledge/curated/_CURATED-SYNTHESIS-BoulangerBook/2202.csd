<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
          instr     2202            ; DRY PLUCK
gasend    init      0                    ; INIT GLOBAL "SEND"
kgate     linseg    p4, .1, 0, 1, 0      ; .1 SECOND RAMP
icps      =         cpspch(p5)           ; P5 IN PCH
asig      pluck     kgate, icps, icps, 0, 1, 0, 0   ; SIMPLE PLUCK
          outs      asig, asig           ; STRAIGHT OUT
gasend    =         gasend+asig          ; ADD TO GLOBAL VAR
          endin

          instr     2203            ; GLOBAL EFFECT INSTRUMENT
atap1     delay     gasend*p4, p6        ; USE GLOBAL VAR FOR INPUTS
atap2     delay     gasend*p5, p7    
          outs      atap1, atap2         ; STEREO ECHOES
gasend    =         0                    ; CLEAR GLOBAL VAR
          endin

</CsInstruments>
<CsScore>
        

; PLAY A SHORT 2-PART HARMONY; NOTE DURS = PLUCK DURS
; INS   ST  DUR AMP PCH     
i 2202  0   .1  15000   7.00        
i 2202  0   .   .   7.04        
i 2202  1   .   .   7.07        
i 2202  1   .   .   8.05        
i 2202  1.5 .   .   8.04        
i 2202  1.5 .   .   8.00        
i 2202  2   .   .   8.10        
i 2202  2   .   .   9.02        
;GLOBAL DELAY INSTR IS ON FOR ENTIRE PASSAGE + LONGEST ECHO
; INS   ST  DUR FAC1    FAC2    ECHO1   ECHO2
i 2203  0   2.5 .7  .5  .3  .4

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
