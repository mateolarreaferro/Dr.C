<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

nchnls = 2

instr 15
  ifc     =       p4                       ; Center / Shelf
  kq      =       p5                       ; Quality factor sqrt(.5) is no resonance
  kv      =       ampdb(p6)                ; Volume Boost/Cut
  imode   =       p7                       ; Mode 0=Peaking EQ, 1=Low Shelf, 2=High Shelf
  kfc     linseg  ifc*2, p3, ifc/2
  asig    rand    5000                     ; Random number source for testing
  aout    pareq   asig, kfc, kv, kq, imode ; Parmetric equalization
          outs    aout, aout               ; Output the results
endin


</CsInstruments>
<CsScore>

; SCORE:
  ;   Sta  Dur  Fcenter  Q        Boost/Cut(dB)  Mode
  i15 0    1    10000   .2          12             1
  i15 +    .    5000    .2          12             1
  i15 .    .    1000    .707       -12             2
  i15 .    .    5000    .1         -12             0
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
