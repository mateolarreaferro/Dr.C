<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

asig vco2 .01, 110	; sawtooth waveform at low volume
kcut line 300, p3, 60	; Vary cutoff frequency
kresonance = 3
inumlayer = 3
asig lowresx asig, kcut, kresonance, inumlayer
     outs2 asig		; output stereo channel 2 only

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
