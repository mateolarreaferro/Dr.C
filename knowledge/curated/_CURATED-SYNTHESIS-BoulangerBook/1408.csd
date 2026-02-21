<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   1408
acar    line    400, p3, 800
index   =       2.0
imodfr  =       400
idev    =       index*imodfr
amodsig oscil   idev, imodfr, 1
a1      fof     5000, 5, acar+amodsig, 0, 1, .003, .5, .1, 3, 1, 2, p3, 0, 1
        out     a1
        endin

</CsInstruments>
<CsScore>
f 1 0   4096    10  1
f 2 0   1024    19  .5 .5 270 .5
                
i 1408   0   10
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>16</width>
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
