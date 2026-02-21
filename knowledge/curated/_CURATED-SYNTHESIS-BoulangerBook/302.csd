<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

            
            instr       303
iamp        =           p4
ifrq        =           cpspch(p5)
ivibfrq     =           p6
ivibamt     =           p7
istiff      =           p8
kv          linseg      0, 0.5, 0, 1, 1, p3-0.5, 1
a1          wgclar      iamp, ifrq, istiff, 0.1, 0.1, 0.2, ivibfrq, kv*ivibamt, 1, 50
            out         a1
            endin       

</CsInstruments>
<CsScore>
f 1      0       8192    10      1

i 303 0 2       15000  7.00     4   0.3     1                    
i 303 2 1       20000  7.04     5   0.4     2                  
i 303 3 1       25000  7.07     6   0.5     3
s
i 303 0 4       30000  8.00     7   0.6     4
s
i 303 0 2       15000  8.00     4   0.3     1                    
i 303 2 1       20000  7.07     5   0.4     2                  
i 303 3 1       25000  7.04     6   0.5     3
s
i 303 0 4       30000  7.00     7   0.6     4
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
