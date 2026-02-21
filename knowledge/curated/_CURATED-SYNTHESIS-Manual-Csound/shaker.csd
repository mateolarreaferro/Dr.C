<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; by Menno Knevel

0dbfs  = 1

instr 1

knum  =   p5
kfreq	line p4, p3, 440
a1 shaker .5, kfreq, 8, 0.999, knum
outs a1, a1

endin

</CsInstruments>
<CsScore>
;       frq     #
i 1 0 1 440     3
i 1 2 1 440    300
i 1 4 1 440    3000
i 1 6 2 4000    100

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
