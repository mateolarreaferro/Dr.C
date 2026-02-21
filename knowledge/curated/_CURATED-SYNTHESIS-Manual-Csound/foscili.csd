<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kcps = 440
kcar = 1
kmod = p4
kndx line 0, p3, 20	;intensivy sidebands

asig foscili .5, kcps, kcar, kmod, kndx, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>
; sine
f 1 0 16384 10 1

i 1 0 10 1.414	;gong-ish
i 1 10 5 2.05	;with "beat"
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
