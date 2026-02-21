<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; THICK.O

; THIS INSTRUMENT PRODUCES "THICKENED" SINE TONES BY ADDING TOGETHER
; FIVE CLOSELY-TUNED SINE TONES.
; TO CREATE A BEATING EFFECT BETWEEN THE FREQUENCIES OF THE COMPONENT
; OSCILLATORS, ADD OR SUBTRACT A SMALL FREQUENCY DEPENDANT NUMBER TO P4.



instr          1,2,3

                                             ; P4 = FREQUENCY IN OCTAVE.DECIMAL NOTATION
                                             ; P5 = AMPLITUDE

i1             =         cpsoct(p4)          ; CONVERTS FREQ FROM OCTAVE.DECIMAL TO HZ

                                             ; CREATE TWO FREQUENCY COMPONENTS ABOVE THE NOTE
                                             ; INDICATED BY MULTIPLYING THE OCTAVE.DECIMAL
                                             ; SPECIFICATION OF THE NOTE BY SMALL CONSTANTS
                                             ; AND ADDING THE RESULT TO THE HZ VALUE OF I1.

i2             =         i1+(p4*.13)
i3             =         i1+(p4*.23)

                                             ; CREATE TWO BEATING COMPONENTS BELOW THE NOTE
                                             ; IN THE SAME WAY
i4             =         i1-(p4*.19)
i5             =         i1-(p4*.11)

a1             oscili    p5,i1,1                       ; F1 IS A SINE FUNCTION
a2             oscili    p5,i2,1
a3             oscili    p5,i3,1
a4             oscili    p5,i4,1
a5             oscili    p5,i5,1

aout           =         a1+a2+a3+a4+a5

aenv           linseg    0,p3/2,1,p3/2,0,.01,0         ; THE "TEEPEE" ENVELOPE FOR THE TONE

out            aenv*aout
               endin

</CsInstruments>
<CsScore>
; Thick.s

f1 0 1024 9 1 1 0

;       start   dur     freq    amp
i1      1       3       6.1     2500
i.      +       .       7.2
i.      +       .       8.3
i.      +       .       9.4
s
i1      1       4       6.3     1500
i2      1       4       2.1     1500
i3      1       4       9.9     1500
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
