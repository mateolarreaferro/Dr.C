<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1 

instr 1

iplk  = 0.75
kamp  = .8
icps  = 110
krefl = p4
kpick = p5


axcite oscil 1, 1, 1
asig repluck iplk, kamp, icps, kpick, krefl, axcite
asig dcblock2 asig		;get rid of DC offset
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1	;sine wave.

s
i 1 0 1 0.95 0.75	;sounds heavier (=p5)
i 1 + 1  <
i 1 + 1  <
i 1 + 1  <
i 1 + 10 0.6

s
i 1 0 1 0.95 0.15	;sounds softer (=p5)
i 1 + 1  <
i 1 + 1  <
i 1 + 1  <
i 1 + 10 0.6
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
