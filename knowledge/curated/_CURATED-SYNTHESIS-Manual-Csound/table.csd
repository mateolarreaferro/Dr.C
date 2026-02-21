<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1
  
kndx line 0, p3, 1                  ; Vary our index linearly from 0 to 1.

ifn = 1                             ; Read Table #1 with our index.
ixmode = 1
kfreq table kndx, ifn, ixmode
a1 oscil .5, kfreq, 2; Generate a sine waveform, use our table values to vary its frequency.
outs a1, a1
endin

</CsInstruments>
<CsScore>
f 1 0 1025 -7 200 1024 2000 ; Table #1, a line from 200 to 2,000.
f 2 0 16384 10 1            ; Table #2, a sine wave.

i 1 0 2
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
