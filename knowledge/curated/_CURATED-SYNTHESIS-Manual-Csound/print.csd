<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

instr 1

irand = rnd(3)			;generate a random number from 0 to 3
;print irand			;print it
asig  poscil .7, 440*irand, 1
      outs asig, asig

endin
</CsInstruments>
<CsScore>
f1 0 16384 10 1	;sine wave

i 1 0 1
i 1 2 1
i 1 4 1
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
