<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1

kfreq = 330
kstiff = -0.3
iatt = 0.1
idetk = 0.1
kngain init p4		;vary breath
kvibf = 5.735
kvamp = 0.1

asig wgclar .9, kfreq, kstiff, iatt, idetk, kngain, kvibf, kvamp, 1
     outs asig, asig
      
endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1	;sine wave

i 1 0 2 0.2
i 1 + 2 0.5		;more breath
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
