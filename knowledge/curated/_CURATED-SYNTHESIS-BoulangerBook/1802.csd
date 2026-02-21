<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gkfr      init 0                        ; INIT FREQUENCY

          instr     1802                ; CONTROLS INSTR 1803
gkfr      linseg    p5, p3*.1, p6, p3*.9, p6 
          endin          

          instr     1803 
kenv      linen     p4, .01, p3, .01    
asig      oscil     kenv, gkfr, 1  
          out       asig 
          endin     

</CsInstruments>
<CsScore>
    

f 1 0   8193    10  1

i 1802  0   0.4 0   440 440
i 1802  +   .   .   pp6 660
i 1802  +   .   .   pp6 550
                
i 1803  0   1.2 10000   
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>61</y>
 <width>396</width>
 <height>661</height>
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
