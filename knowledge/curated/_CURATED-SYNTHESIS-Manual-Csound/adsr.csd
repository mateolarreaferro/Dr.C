<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1

iatt  = p5
idec  = p6  
islev = p7
irel  = p8

kenv	adsr iatt, idec, islev, irel
kcps =  cpspch(p4) 	  ;frequency

asig	vco2  kenv * 0.8, kcps
	outs  asig, asig

endin

</CsInstruments>
<CsScore>

i 1  0  2  7.00  .0001  1  .5  .001 ; short attack
i 1  3  2  7.02  1  .5  .5  .001    ; long attack
i 1  6  2  6.09  .0001  1 .5  .7     ; long release

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
