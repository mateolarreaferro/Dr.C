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

;1st    Verse           
i511    0   .3  15000   8.00
i511    +   .   9000    8.02 
i511    +   .   12000   8.04
i511    +   .   9000    8.00
s               
m   Chorus          
i512    0   .3  20000   8.07
i512    +   .   12000   8.09
i512    +   .   18000   8.07
i512    +   .   11000   8.05
s               
;2nd    Verse           
i511    0   .3  15000   8.04
i511    +   .   9000    8.00
i511    +   .   12000   8.02
i511    +   .   9000    8.00
s               
n   Chorus          
s               
;3rd    Verse           
i511    0   .3  15000   8.04
i511    +   .   9000    8.00
i511    +   .   12000   8.04
i511    +   .   9000    8.05
s               
n   Chorus          
s
;4th    Verse           
i511    0   .3  15000   8.04
i511    +   .   9000    8.04
i511    +   .   12000   8.02
i511    +   .   9000    8.02
s               
i511    0   4   15000   8.00
i512    .05 4   10000   7.001
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
