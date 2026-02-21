<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1 

gisine   ftgen 0, 0, 16384, 10, 1						;sine wave

instr   1

ihertz = cpspch(p4)
ipkamp = p5
iwsfn  = p6									;waveshaping function	
inmfn  = p7									;normalization function 								
agate   linen   1, .01, p3, .1            					;overall amp envelope
kctrl   linen  	.9, 2, p3, 2							;waveshaping index control
aindex  poscil  kctrl/2, ihertz, gisine						;sine wave to be distorted
asignal tablei  .5+aindex, iwsfn, 1						;waveshaping
knormal tablei  1/kctrl, inmfn , 1						;amplitude normalization
        outs    asignal*knormal*ipkamp*agate, asignal*knormal*ipkamp*agate
           
endin
</CsInstruments>
<CsScore>
f1 0 64 21 6	;Gaussian (random) distribution
f2 0 33 4 1 1	;normalizing function with midpoint bipolar offset

s
;	st	dur	pch	amp   wsfn inmfn
i1      0       4      6.00    .7      1     2
i1      4       .      7.00    .
i1      8       .      8.00    .
;-------------------------------------------------------------------------------------
f3 0 1025 13 1 1 0 5 0 5 0 10	;Chebyshev algorithm
f4 0 513 4 3 1			;normalizing function with midpoint bipolar offset
s
;	st	dur	pch	amp   wsfn inmfn
i1      0       4      6.00    .9      3     4
i1      4       .      7.00    .
i1      8       .      8.00    .
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
