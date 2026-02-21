<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

asig vco2 .01, 110	; sawtooth waveform at low volume
;filter a channel
kcut1 line 60, p3, 300	; Vary cutoff frequency
kresonance1 = 3
inumlayer1 = 3
asig1 lowresx asig, kcut1, kresonance1, inumlayer1
;filter the other channel
kcut2 line 300, p3, 60	; Vary cutoff frequency
kresonance2 = 3
inumlayer2 = 3
asig2 lowresx asig, kcut2, kresonance2, inumlayer2

      outs asig1, asig2	; output both channels 1 & 2

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
