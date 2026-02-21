<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gklfo     init      0                    
gkpch     init      0                    
gkad      init      0                    
                            
          instr     1807    ; LFO               
gklfo     oscil      p4, p5, 1                   
          endin                          
                            
          instr     1808    ; ADSR              
gkad      linseg    0, p3*p4, 1, p3*p5, p6, p3*p7, 0                     
gkpch     =         cpspch(p8)                   
          endin                          
                            
          instr     1809    ;VCO                 
iamp      =         p4*0.333                     
kpch      =         gkpch*(1+0.04*gklfo)                     
avco1     oscil     iamp, kpch*(1-p5), 2         ; p4=%DETUNE                
avco2     oscil     iamp, kpch, 2                    
avco3     oscil     iamp, kpch*(1+p5), 2                     
avcos     =         avco1+avco2+avco3                    
asig      =         gkad*avcos                   
          out       asig                
          endin

</CsInstruments>
<CsScore>
f 1 0   8193    10  1           
f 2 0   2   2   1   -1      
                            
i 1807  0   1.8 0.26    4.30            
i 1808  0   0.6 0.05    0.12    0.43    0.32    8.00
i 1808  +   0.6 0.08    0.12    0.30    0.45    8.02
i 1808  +   0.6 0.08    0.12    0.30    0.45    8.05
i 1809  0   1.8 20000       0.02        
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
