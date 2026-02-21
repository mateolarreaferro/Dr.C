<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

asig vco2 .05, 100	; sawtooth waveform at low volume

kcut line 100, p3, 30	; Vary cutoff frequency
kresonance = .7
inumlayer = 3
asig lowresx asig, kcut, kresonance, inumlayer

klfo lfo 4, .5, 4	
klfo = klfo+1		; offset of 1
printks "signal is sent to channel %d\\n", .1, klfo
      outch klfo,asig

endin
</CsInstruments>
<CsScore>

i 1 0 30
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
