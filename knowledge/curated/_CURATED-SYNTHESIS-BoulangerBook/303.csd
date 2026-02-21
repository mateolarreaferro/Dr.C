<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr 304
iamp    =       p4
ifrq    =       cpspch(p5)
ivibfrq =       p6
ivibamt =       p7
kv      linseg  0, 0.5, 0, 1, 1, p3-0.5, 1
a1      fmbell  iamp, ifrq, 1, 1.2, kv*ivibamt, ivibfrq, 1,1,1,1,1
        out     a1
        endin       
            
        instr 305
iamp    =       p4
ifrq    =       cpspch(p5)
ivibfrq =       p6
ivibamt =       p7
kv      linseg  0, 0.5, 0, 1, 1, p3-0.5, 1
a1      fmrhode iamp, ifrq, 1, 1.2, kv*ivibamt, ivibfrq, 1,1,1,1,1
        out     a1
        endin       

</CsInstruments>
<CsScore>
f1      0       8192    10      1

t 0 120
i304    0   9       15000  7.00     5   0.5                    
i304    1   7       13000  7.04     4   0.6                  
i304    2   6       12000  7.07     6   0.7
i304    3   5       11000  8.00     7   0.8

i305    .5  5       15000  9.00     5   0.8                    
i305    1.5 6       13000  8.07     4   0.7                   
i305    2.5 7       12000  8.04     6   0.6
i305    3.5 9       11000  8.00     7   0.9
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>384</width>
 <height>180</height>
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
