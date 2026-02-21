<CsoundSynthesizer>
<CsInstruments>
; By Stefano Cucchi 2020

0dbfs = 1

instr 1

a1 oscili 0.1, p4
a2 oscili 0.1, p5
ashape taninv2 a1, a2
kdeclick linseg 0, 0.3, 0.2, p3-0.6, 0.2, 0.3, 0
outs ashape*kdeclick, ashape*kdeclick
endin

instr 2

a1 diskin  p4, 1
a2 = a1
ashape taninv2 a1, a2
kdeclick linseg 0, 0.3, 0.2, p3-0.6, 0.2, 0.3, 0
outs ashape*kdeclick*.5, ashape*kdeclick*.5
endin

</CsInstruments>
<CsScore>

i 1 0 3 440 300
i 1 3 3 200 210
i 1 6 3 50 40
i 1 9 3 50 3000
i 2 12 3 "fox.wav"

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
