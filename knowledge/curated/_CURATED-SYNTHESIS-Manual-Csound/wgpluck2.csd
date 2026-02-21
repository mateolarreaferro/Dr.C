<CsoundSynthesizer>
<CsInstruments>

; by Menno Knevel 2021

0dbfs  = 1

instr 1

iplk = p4
kamp = .7
icps = 220
kpick = 0.75
krefl = p5

apluck wgpluck2 iplk, kamp, icps, kpick, krefl
apluck  dcblock2    apluck
outs apluck, apluck

endin

</CsInstruments>
<CsScore>
;         pluck   reflection
i 1 0 1     0       0.9
i 1 + 1     <       .
i 1 + 1     <       .
i 1 + 1     1       . 

i 1 5 5     .75     0.7 
i 1 + 5     .05     0.7 
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
