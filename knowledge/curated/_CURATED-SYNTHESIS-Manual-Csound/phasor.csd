<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

ifn = 1			;read table 1 with our index
ixmode = 1
kndx phasor p4
kfrq table kndx, ifn, ixmode
asig poscil .6, kfrq, 2	;re-synthesize with sine
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 1025 -7 200 1024 2000 ;a line from 200 to 2,000	
f 2 0 16384 10 1;sine wave

i 1 0 1 1	;once per second
i 1 2 2 .5	;once per 2 seconds
i 1 5 1 2	;twice per second
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
