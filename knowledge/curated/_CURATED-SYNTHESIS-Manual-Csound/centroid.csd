<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 16384, 10, 1

instr 1

ktrig init 1				;calculate centroid
a1   oscil3 0.5, p4, giSine		;of the sine wave
k1   centroid a1, ktrig, 16384
asig oscil3 0.5, k1, giSine
     printk2 k1				;print & compare:
     outs a1, asig			;left = original, right = centroid signal

endin
</CsInstruments>
<CsScore>

i1 0 2 20
i1 + 2 200
i1 + 2 2000
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
