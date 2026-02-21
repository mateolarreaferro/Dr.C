<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

gafb      init      0        ; INITIAL VALUE

          instr     1825    
kline     line      0, p3, 1     
aosc      oscil     1, p5*(1+kline*gafb), 1 
asig      linen     aosc, 0.07, p3, 0.075    
          out       asig*p4 
gafb      =         asig    
          endin

</CsInstruments>
<CsScore>
        

f 1 0   8193    10  1

i 1825  0   3   20000   400
i 1825  +   .   .       75
i 1825  +   .   .       135
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
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
