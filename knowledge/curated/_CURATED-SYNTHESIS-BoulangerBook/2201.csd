<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     2201                     ; PLUCK WITH ECHOES
kgate     linseg    p4, .1, 0, 1, 0
icps      =         cpspch(p5)               ; MAKE TWO SLAPBACK ECHOES,
asig      pluck     kgate, icps, icps, 0, 1, 0, 0   ; .. EACH ONE SOFTER
atap1     delay     asig*.7, p6              ; P6 DELAY IN SEC
atap2     delay     asig*.5, p7              ; P7 DELAY IN SEC
          outs      asig+atap1, asig+atap2   ; ADD STEREO ECHOES
          endin

</CsInstruments>
<CsScore>
; NOTE: THAT P3 MUST BE LONG ENOUGH TO INCLUDE BOTH ECHOES
; INS   ST  DUR AMP     PCH     ECHO1   ECHO2
i 2201  0   .5  20000   7.00    .3     .4
i 2201  1   .   .       7.07        
i 2201  1.5 .   .       8.04        
i 2201  2   .   .       8.10        
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
