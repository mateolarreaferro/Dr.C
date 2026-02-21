<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs   = 1

instr 1

kcps = 220
knh  = p4		;total no. of harmonics
klh  = p5		;lowest harmonic
kmul line 0, p3, 1	;increase amplitude of
			;higer partials
asig gbuzz .6, kcps, knh, klh, kmul, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>
; a cosine wave
f 1 0 16384 11 1

i 1 0 3 3  1 ;3 harmonics, lowest harmonic=1
i 1 + 3 30 1 ;30 harmonics, lowest harmonic=1
i 1 + 3 3  2 ;3 harmonics, lowest harmonic=3
i 1 + 3 30 2 ;30 harmonics, lowest harmonic=3
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
