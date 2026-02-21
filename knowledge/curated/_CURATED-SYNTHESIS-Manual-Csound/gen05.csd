<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1 

instr 1

ifn = p4					;choose different tables for GEN05
kcps init 1/p3					;index over the length of  entire note
kndx phasor kcps
ixmode = 1					;normalize index data
kamp tablei kndx, ifn, ixmode
asig poscil kamp, 440, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>
f 1 0 8192 10 1	;sine wave
f 2 0 129 5    1   100 0.0001 29 		;short attack
f 3 0 129 5 0.00001 87    1   22 .5 20 0.0001 	;long attack


i 1 0 2 2
i 1 3 2 3

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
