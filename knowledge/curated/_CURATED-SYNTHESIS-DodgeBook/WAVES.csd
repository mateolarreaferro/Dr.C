<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; INSTRUMENT FOR THE WAVES


;p4            =         freq expressed in octave.point.decimal notation
;p5            =         amp

               instr     1
i1             =         cpsoct(p4)                              ;CONVERT OCT.NOTATION TO HZ
a1             oscili    p5,i1,1                                 ;USE OSCILI FOR CLEAN SOUND
aenv           linseg    0,p3/2,1,p3/2,0,.01,0                   ;TACK ON GUARD POINTS TO AVOID CLICKS
out            aenv*a1                                           ;MULTIPLY AUDIO SIGNAL BY AMP ENVELOPE
               endin


</CsInstruments>
<CsScore>
; SCORE FOR THE WAVES

f1 0 512 9 1 1 0

;       start   dur     freq    amp
i1      0       3.5     8.00    10000
i1      .       .       7.99    .
i1      .       .       8.01    .
i1      3       4.2     7.51    .
i1      .       .       7.50    .
i1      .       .       7.49    .
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
