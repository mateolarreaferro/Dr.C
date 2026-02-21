<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

k1   oscili 1, 10.0, 1			;combine 3 sinusses
k2   oscili 1, 1.0, 1			;at different rates
k3   oscili 1, 3.0, 1
kmin min   k1, k2, k3
kmin = kmin*250				;scale kmin
;printk2 kmin				;check the values

aout vco2 .5, 220, 6			;sawtooth
asig moogvcf2 aout, 600+kmin, .5 	;change filter around 600 Hz		
     outs asig, asig

endin

</CsInstruments>
<CsScore>

f1 0 32768 10 1

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
