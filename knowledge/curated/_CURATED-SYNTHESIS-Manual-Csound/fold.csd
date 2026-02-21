<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

asig  poscil3 .8, 400, 1 ;very clean sine
kincr line p4, p3, p5
asig  fold asig, kincr
      outs asig, asig

endin
</CsInstruments>
<CsScore>
;sine wave.
f 1 0 16384 10 1

i 1 0 4 1 100	; Vary the fold-over amount from 1 to 100

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
