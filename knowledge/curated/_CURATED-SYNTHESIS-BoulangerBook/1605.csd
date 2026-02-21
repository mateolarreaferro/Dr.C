<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1605                
ax        init 1                        ; DUFFINGS SYSTEM OR...            
ay        init 0                        ; ... CUBIC OSCILLATOR             
ke        init p6                       ; ax = y            
ka        init p7                       ; ay = ex^3-Ax           
kh        init p5                  
kampenv   linseg    0, .01, p4, p3-.02, p4, .01, 0                    
axnew     =         ay                  
ay        =         ay+kh*(ke*ax*ax*ax-ka*ax)                    
ax        =         axnew                    
          outs      kampenv*ax, kampenv*ay                  
          endin


</CsInstruments>
<CsScore>
t   0   40          
                        
i 1605  0   60  30000   .01     .1          100
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>392</width>
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
