<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;  By Stefano Cucchi 2020

0dbfs = 1

instr 1
; Generate a random number from 0 to 5
irand1 = rnd(5)
; Generate a random number from 0 to 13
irand2 = rnd(13)

print irand1
print irand2

a1, a2 crossfm 200, 250, irand1, irand2, 1, 1, 1
kdeclick linseg 0, 0.2, 0.5, p3-0.4, 0.5, 0.2, 0

outch 1, a1*kdeclick
outch 2, a2*kdeclick

endin

</CsInstruments>
<CsScore>

f 1 0 4096 10 1 0 1 0 0.5 0 0.2

i 1 0 1  
i 1 + 1  
i 1 + 1 
i 1 + 1 


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
