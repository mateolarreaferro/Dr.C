<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1

instr 1
  aenv linsegr 0, 0.1, 1, 0.1, 0
  asig =  oscili(0.1, 1000)
  asig += oscili(0.1, 1012)
  asig *= aenv
  if lastcycle() == 1 then
    schedulek p1, 0, p3
  endif
  outs asig, asig
endin
  
</CsInstruments>

<CsScore>

i 1 0 0.5
f 0 3600 

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
