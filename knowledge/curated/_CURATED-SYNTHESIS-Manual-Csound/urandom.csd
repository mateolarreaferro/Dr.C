<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1     ; Create random numbers at a-rate in the range -2 to 2
  
aur     urandom  -2, 2
afreq1  =   aur * 500 + 100         ; Use the random numbers to choose a frequency.
afreq2  =   aur * 500 + 200
a1 oscil .3, afreq1
a2 oscil .3, afreq2
outs a1, a2
endin

</CsInstruments>
<CsScore>
i 1 0 3
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
