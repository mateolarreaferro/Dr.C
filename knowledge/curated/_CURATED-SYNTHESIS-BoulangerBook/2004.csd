<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     2004
iharm     =         int(44100/(p4>p5 ? p4:p5)/2)-1     ; MAX HARM W/O ALIAS
a1        linseg    0, 0.05, 30000, p3-0.1, 30000, 0.05, 0, 1, 0
afreq     expon     p4, p3, p5
a2        buzz      1, afreq, iharm, 1, -1
          out       a1*a2
          endin

</CsInstruments>
<CsScore>
f 1 0   16384   10  1

i 2004  0   6   10  20
i 2004  6   6   20  40
i 2004  12  6   40  80
i 2004  18  6   80  160
i 2004  24  6   160 320
i 2004  30  6   320 640
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
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
