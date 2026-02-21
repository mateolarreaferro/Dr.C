<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

asaw vco2 .3, 110	;sawtooth
kcf  line 1760, p3, 220	;vary cut-off frequency from 220 to 1280 Hz
kres = p4		;vary resonance too
ares rezzy asaw, kcf, kres
asig balance ares, asaw
     outs asig, asig

endin
</CsInstruments>
<CsScore>

i 1 0 4 10
i 1 + 4 30
i 1 + 4 120	;lots of resonance
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
