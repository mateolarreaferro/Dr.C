<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


          instr     1816
imean     =         250                 ; THE MEAN FREQUENCY
idev      =         50                  ; THE STANDARD DEVIATION
itwopi    =         6.283185
krnd1     rand      0.5,.05463
krnd2     rand      0.5,.34567
kgs1      =         sqrt(-2.0*log(0.501+krnd1))
kgs2      =         kgs1*cos(itwopi*(0.5+krnd2))
kgauss    =         kgs2*idev+imean
gkgauss   =         kgauss
          endin

          instr     1817
kgt       oscil     1,p5,2
kfr       samphold  gkgauss,kgt 
aosc      oscil     1,kfr,1
asig      =         aosc*p4
          out       asig
          endin

</CsInstruments>
<CsScore>
f 1 0 8193 10 1
f 2 0 513  2  1

i 1816 0 20

i 1817 0 20  2000 1.14
i 1817 0 20  2000 0.75
i 1817 0 20  2000 2.14
i 1817 0 20  2000 3.47
i 1817 0 20  2000 3.25
i 1817 0 20  2000 6.17
i 1817 0 20  2000 5.84
i 1817 0 20  2000 4.67
i 1817 0 20  2000 3.34
i 1817 0 20  2000 2.85
i 1817 0 20  2000 1.06
i 1817 0 20  2000 0.95


</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
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
