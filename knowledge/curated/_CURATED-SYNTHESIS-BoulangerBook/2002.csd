<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   2002
aprd    oscil   32767, 440, p4
        out     aprd
        endin

</CsInstruments>
<CsScore>


; ONE PERIOD OF A SINE WAVE
f 1 0   8192    10  1
; ONE PERIOD OF AN APPROXIMATE SAWTOOTH WAVE
f 2 0   8192    10  1 0.5 0.333 0.25 0.2 0.1667 0.1429 0.125 0.111 0.1
; ONE PERIOD OF AN APPROXIMATE SQUARE WAVE
f 3 0   8192    10  1 0 0.333 0 0.2 0 0.1429 0 0.111 0
; ONE PERIOD OF AN APPROXIMATE TRIANGLE WAVE
f 4 0   8192    10  1 0 -0.111 0 0.04 0 -0.0204 0 0.0123 0 -0.0083 0 0.0059

i 2002  0   5   1
i 2002  6   5   2
i 2002  12  5   3
i 2002  18  5   4
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>8</height>
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
