<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kfreq = 110
kvowel = p4	; p4 = vowel (0 - 64)
ktilt  = p5
kvibamt = 0.005
kvibrate = 6

asig fmvoice .5, kfreq, kvowel, ktilt, kvibamt, kvibrate
outs asig, asig

endin
</CsInstruments>
<CsScore>
;  sine wave.
f 1 0 16384 10 1

i 1 0 1 1  90	; tilt=90
i 1 1 1 >  .
i 1 2 1 >  .
i 1 3 1 >  .
i 1 4 1 >  .
i 1 5 1 >  .
i 1 6 1 >  .
i 1 7 1 12 .

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
