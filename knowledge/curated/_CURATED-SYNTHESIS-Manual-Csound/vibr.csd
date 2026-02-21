<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1

kaverageamp  init 500
kaveragefreq init 4
kvib vibr kaverageamp, kaveragefreq, 1
asig poscil .8, 220+kvib, 1		;add vibrato
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1       ;sine wave

i 1 0 10

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
