<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kcps = 100
kcar = 1
kmod = p4

kndx oscil 30, .25/p3, 1
kndx ceil kndx

asig foscili .5, kcps, kcar, kmod, kndx, 1
     outs asig, asig

endin
</CsInstruments>
<CsScore>

f 1 0 16384 10 1

i 1 0 10 1.5	
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
