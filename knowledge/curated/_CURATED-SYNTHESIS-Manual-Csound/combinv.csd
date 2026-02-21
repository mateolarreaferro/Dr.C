<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1 

kcps    expon p5, p3, p4
asig	oscil3 0.3, kcps
krvt =  3.5
ilpt =  0.1
aleft	combinv asig, krvt, ilpt
	outs   aleft, asig

endin

</CsInstruments>
<CsScore>
i 1 0 3 20 2000
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
