<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gkpwr     init 0

          instr     1821
igm       =         1.618
imp       =         p4
kln       line      3, p3, 0
afm1      foscil    imp, p5, 1, p5*igm, kln, 1
asig      linen     afm1, 0.01*p3, p3, 0.6*p3
          out       asig
gkpwr     rms       asig
          endin     
                                        
          instr     1822                ; PULSED NOISE INSTRUMENT
klfo      oscil     0.5, 8, 1 
klfo1     =         klfo+0.5            ; RESCALE [0-1]
anoiz     rand 1    
apulse    =         anoiz*klfo1    
kpw       =         p4-gkpwr            ; POWER CURVE
kmp       port      kpw, 0.2            ; SMOOTH CURVE
asig      =         apulse*kmp          
          out       asig 
          endin

</CsInstruments>
<CsScore>
f 1 0   8193    10  1

i 1821  0   3   20000   125
i 1822  0   1   20000   
i 1822  +   .   20000   
i 1822  +   .   20000   
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
