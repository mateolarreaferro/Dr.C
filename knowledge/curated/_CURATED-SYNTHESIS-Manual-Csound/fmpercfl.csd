<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kfreq = 220
kc1 = 5
kvdepth = .01
kvrate = 6

kc2  line 5, p3, p4
asig fmpercfl .5, kfreq, kc1, kc2, kvdepth, kvrate
     outs asig, asig
endin


</CsInstruments>
<CsScore>
; sine wave.
f 1 0 32768 10 1

i 1 0 4 5
i 1 5 8 .1

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
