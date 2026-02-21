<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

isin1     =          sin(0) 					;sine of 0 is 0
isin2     =          sin($M_PI_2) 				;sine of pi/2 (1.5707...) is 1
isin3     =          sin($M_PI) 				;sine of pi (3.1415...) is 0
isin4     =          sin($M_PI_2 * 3) 				;sine of 3/2pi (4.7123...) is -1
isin5     =          sin($M_PI * 2) 				;sine of 2pi (6.2831...) is 0
isin6     =          sin($M_PI * 4) 				;sine of 4pi is also 0
          print      isin1, isin2, isin3, isin4, isin5, isin6
endin

instr 2 ;sin used in panning, after an example from Hans Mikelson

aout      vco2       0.8, 220 					; sawtooth
kpan      linseg     p4, p3, p5 ;0 = left, 1 = right
kpan      =          kpan*$M_PI_2 				;range 0-1 becomes 0-pi/2
kpanl     =          cos(kpan)
kpanr     =          sin(kpan)
          outs       aout*kpanl, aout*kpanr
endin

</CsInstruments>
<CsScore>
i 1 0 0
i 2 0 5 0 1 ;move left to right
i 2 5 5 1 0 ;move right to left
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
