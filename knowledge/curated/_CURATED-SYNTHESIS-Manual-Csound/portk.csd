<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; by Stefano Cucchi 2020
0dbfs  = 1 

instr 1

kFreq randomh 400, 1300, 4, 2, 550 ; random frequency to oscillators.

khtim linseg 0.001, p3*0.3, 0.001, p3*0.7, 0.125 ; portamento-function: start with NO portamento - then portamento.
kPort portk kFreq, khtim ; pitch with portamento.

asigL oscili 0.4, kFreq, 1 ; channel left - NO portamento.
asigR oscili 0.4, kPort, 2 ; channel right - PORTAMENTO.

outch 1, asigL   ; channel left
outch 2, asigR   ; channel right

endin

</CsInstruments>
<CsScore>

f 1 0 4096 10 1 0 1 0 1 0 1 0 1
f 2 0 4096 10 1 1 0 1 0 1 0 1 0 1

i 1 0 10
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
