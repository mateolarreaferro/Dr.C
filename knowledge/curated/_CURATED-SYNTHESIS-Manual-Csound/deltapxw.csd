<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1

a1      phasor   300
a1      =  a1 - 0.5
a_      delayr   1
adel    phasor   4
adel    =  sin(2 * 3.14159265 * adel) * 0.01 + 0.2
        deltapxw a1, adel, 32
adel    phasor   2
adel    =  sin(2 * 3.14159265 * adel) * 0.01 + 0.2
        deltapxw a1, adel, 32
adel    =  0.3
a2      deltapx  adel, 32
a1      =  0
        delayw   a1
        outs     a2*.7, a2*.7
endin
</CsInstruments>
<CsScore>

i1 0 5
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
