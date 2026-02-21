<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giSin ftgen 1, 0, 1024, 10, 1

instr 1

avco vco2   .5, 110			;sawtootyh wave
asin poscil .5, 220, giSin		;sine wave but octave higher
kx   linseg 0, p3*.4, 1, p3*.6, 1	;crossfade between saw and sine
asig ntrpol avco, asin, kx
     outs   asig, asig

endin
</CsInstruments>
<CsScore>

i 1 0 5
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
