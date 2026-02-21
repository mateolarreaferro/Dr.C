<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
        instr   511
k1      linen   p4, p3*.01, p3, p3*.1
a1      oscil   k1,cpspch(p5),2
        out     a1
        endin
        
        instr   512
k1      linen   p4, p3*.01, p3, p3*.1
k2      expon   13, p3, 1
a1      foscil  k1,cpspch(p5),1,1,k2,1
        out     a1
        endin


</CsInstruments>
<CsScore>
f1 0 4096 10 1
f2 0 4096 10 10 0 5 0 1

i 511   0   .5  10000   8.00
i 511   +   .   9000    8.02 
i 511   +   .   8000    8.04
i 511   +   .   7000    8.00
i 512   2   .5  6000    8.07
i 512   +   .   7000    8.09
i 512   +   .   8000    8.07
i 512   +   .   9000    8.05
b   1.05            
i 511   0   .5  10000   8.00
i 511   +   .   9000    8.02 
i 511   +   .   8000    8.04
i 511   +   .   7000    8.00
i 512   2   .5  6000    8.07
i 512   +   .   7000    8.09
i 512   +   .   8000    8.07
i 512   +   .   9000    8.05
s
i 511   0   .5  10000   8.00
i 511   +   .   9000    8.02 
i 511   +   .   8000    8.04
i 511   +   .   7000    8.00
i 512   2   .5  6000    8.07
i 512   +   .   7000    8.09
i 512   +   .   8000    8.07
i 512   +   .   9000    8.05
b   1.25            
i 511   0   .5  10000   8.00
i 511   +   .   9000    8.02 
i 511   +   .   8000    8.04
i 511   +   .   7000    8.00
i 512   2   .5  6000    8.07
i 512   +   .   7000    8.09
i 512   +   .   8000    8.07
i 512   +   .   9000    8.05
b   1.5         
i 511   0   .5  10000   8.00
i 511   +   .   9000    8.02 
i 511   +   .   8000    8.04
i 511   +   .   7000    8.00
i 512   2   .5  6000    8.07
i 512   +   .   7000    8.09
i 512   +   .   8000    8.07
i 512   +   .   9000    8.05
b   1.75            
i 511   0   .5  10000   8.00
i 511   +   .   9000    8.02 
i 511   +   .   8000    8.04
i 511   +   .   7000    8.00
i 512   2   .5  6000    8.07
i 512   +   .   7000    8.09
i 512   +   .   8000    8.07
i 512   +   .   9000    8.05
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
