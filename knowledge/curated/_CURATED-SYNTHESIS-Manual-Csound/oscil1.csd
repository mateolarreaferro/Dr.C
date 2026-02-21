<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

giPan ftgen 0, 0, 8, -2, .5, .2, .8, .1, .9, 0, 1, .5

instr     1   

istay = 2 ;how many seconds to stay on the first table value
asig   vco2 .3, 220
kpan   oscil1 istay, 1, p3-istay, giPan ;create panning 
       printk2 kpan ;print when new value
aL, aR pan2 asig, kpan ;apply panning
       outs aL, aR

endin
</CsInstruments>
<CsScore>                                                                                  
i 1  0  10
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
