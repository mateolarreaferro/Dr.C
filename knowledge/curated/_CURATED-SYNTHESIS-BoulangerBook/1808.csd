<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gkgauss   init  0

          instr     1818
imean     =         250
idev      =         50
krand     rand      0.5, 0.213
ksig      table     0.5+krand, 3, 1, 0, 0
gkgauss   =         ksig*idev+imean
          endin      

          instr     1819
kgt       oscil     1, p5, 2
kfr       samphold  gkgauss, kgt 
aosc      oscil     1, kfr, 1
          out       aosc*p4
          endin

</CsInstruments>
<CsScore>
f 1  0    8193 10   1    
f 2  0    513  2    1    
f 3  0    1024 21   6    ;NORMAL CURVE

i 1818    0    20
i 1819 0 20  2000 1.14
i 1819 0 20  2000 0.75
i 1819 0 20  2000 2.14
i 1819 0 20  2000 3.47
i 1819 0 20  2000 3.25
i 1819 0 20  2000 6.17
i 1819 0 20  2000 5.84
i 1819 0 20  2000 4.67
i 1819 0 20  2000 3.34
i 1819 0 20  2000 2.85
i 1819 0 20  2000 1.06
i 1819 0 20  2000 0.95
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
