<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1 

instr 1

ifn  = p4
asig oscil .8, 220, ifn
     outs asig,asig
    
endin
</CsInstruments>
<CsScore>
f 1 0 16384 11 1 1	;number of harmonics = 1
f 2 0 16384 11 10 1 .7	;number of harmonics = 10
f 3 0 16384 11 10 5 2	;number of harmonics = 10, 5th harmonic is amplified 2 times


i 1 0 2 1
i 1 + 2 2
i 1 + 2 3
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
