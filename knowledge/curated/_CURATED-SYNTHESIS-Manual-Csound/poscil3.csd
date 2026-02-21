<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 2^10, 10, 1

instr 1

krnd  randomh 40, 440, 1	; produce random values
ain   poscil3 .6, krnd, giSine
kline line    1, p3, 0    	; straight line
aL,aR pan2    ain, kline	; sent across image
      outs    aL, aR

endin
</CsInstruments>
<CsScore>
i1 0 10
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
