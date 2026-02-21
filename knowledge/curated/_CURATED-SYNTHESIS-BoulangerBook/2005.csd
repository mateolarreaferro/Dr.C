<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     2005
a1        linseg    0, 0.01, 20000, p3-0.01, 20000, 0.01, 0, 1, 0
a2        expon     20, p3, 176400
a3        oscil     a1, a2, p4
          out       a3
          endin       

</CsInstruments>
<CsScore>


; SINE
f 1 0   8192    10  1
; SQUARE
f 2 0   8192    10  1000 0 333 0 200 0 143 0 111 0 91 0 77 0 67 0 59 0 53 0
; SAWTOOTH
f 3 0   8192    10  1000 500 333 250 200 167 143 125 111 100 91 83 77 71 67 63 59 56 53 50
; IMPULSE-LIKE
f 4 0   8192    10  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

i 2005  0   20  1
i 2005  21  20  2
i 2005  42  20  3
i 2005  63  20  4
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
