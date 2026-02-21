<CsoundSynthesizer>
<CsInstruments>
0dbfs = 1

instr 1 
kIndex phasor 1/p3
kIndex = kIndex * 16

if kIndex >= 15.99 then 
tableshuffle 1; shuffle table 1
endif

kFreq table kIndex, 1, 0
asound oscili 0.3, kFreq
outch 1, asound
outch 2, asound

endin

</CsInstruments>
<CsScore>

f 1 0	16	-2	200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950

i1 0 4
i1 5 4
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
