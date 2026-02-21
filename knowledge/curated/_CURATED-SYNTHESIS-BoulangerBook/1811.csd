<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

garing    init 0         
gasine    init 0         
                    
          instr     1823                
aosc      oscil     1, p5, 1       
gasine    =         aosc                     ; SEND    
aring     =         garing                   ; RETURN  
asig      linen     aring, 0.1, p3, 0.2      
          out       asig*p4        
          endin               
                    
          instr     1824      
aosc      oscil     1, p5, 1       
aring     =         aosc*gasine         
garing    =         aring          
          endin

</CsInstruments>
<CsScore>
            
                
f 1 0   8193    10  1
                
i 1823  0   4       20000 200   
i 1823  +   4       20000 300   
i 1824  0   2   0   50
i 1824  +   .   .   75
i 1824  +   .   .   150
i 1824  +   .   .   800
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
