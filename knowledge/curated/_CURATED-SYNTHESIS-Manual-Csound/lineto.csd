<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giSine ftgen 0, 0, 2^10, 10, 1

instr 1

kfreq     randh     1000, 20, 2, 1, 2000 ;generates ten random number between 100 and 300 per second
kpan      randh     .5, 1, 2, 1, .5   ;panning between 0 and 1
kp        lineto    kpan, .5          ;smoothing pan transition
aout      poscil    .4, kfreq, giSine
aL, aR    pan2      aout, kp
          outs      aL, aR

endin
</CsInstruments>
<CsScore>

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
