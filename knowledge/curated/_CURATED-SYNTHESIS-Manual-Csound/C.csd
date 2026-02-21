<CsoundSynthesizer>

<CsInstruments>
0dbfs = 1

instr 1
ii pcount
print ii
  a1  oscil 0.5,A4
  outs a1,a1
  endin
</CsInstruments>

<CsScore>


i1   0    .5        100
i .  +
i .  .    .         !
i

s
i1   0    .5        100
i .  +    .
C    0
i .  .    .
i .  .
i .


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
