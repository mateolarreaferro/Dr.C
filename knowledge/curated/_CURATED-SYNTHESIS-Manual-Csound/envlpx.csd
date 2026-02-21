<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

0dbfs = 1


instr 1

irise = 0.2
idec  = 0.5
idur  = p3 - idec

ifn = 1
iatss = p5
iatdec = 0.01

kenv envlpx .6, irise, idur, idec, ifn, iatss, iatdec
kcps = cpspch(p4)
asig vco2 kenv, kcps
;apply envlpx to the filter cut-off frequency
asig moogvcf asig, kcps + (kenv * 8 * kcps) , .5 ;the higher the pitch, the higher the filter cut-off frequency
     outs asig, asig

endin
</CsInstruments>
<CsScore>
; a linear rising envelope
f 1 0 129 -7 0 128 1

i 1 0 2 7.00 .1
i 1 + 2 7.02  1
i 1 + 2 7.03  2
i 1 + 2 7.05  3
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
