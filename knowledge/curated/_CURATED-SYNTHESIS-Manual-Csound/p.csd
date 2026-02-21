<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

; by Menno Knevel - 2022

instr 1

ipr	= p(4)
prints  "\nrandom number is now %f\n", ipr               ; find out the values of p4
aenv    linen   1, 0, p3, .2
asig    poscil  .5, p4
outs    asig * aenv, asig * aenv

endin

</CsInstruments>
<CsScore>
          
i1  0   1   [~ * 200]    ; random between 0-200    
i1  +   1   [~ * 200]
i1  +   2   [~ * 200]  

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
