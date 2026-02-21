<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

garvb   init    0

        instr   301 
kenv    expon  8000, p3, .01
asig    oscil   kenv, cpspch(p4), 1
        outs1   asig
garvb   =       garvb+(asig*.45)    
        endin


        instr 302   
ifrq    =       cpspch(p4)
k1      gauss   ifrq*2
kenv    linen   1, p3*.8, p3, p3*.1
a1      oscil   8000, ifrq, 2
a2      oscil   5000, ifrq+k1, 2
asig    =       (a1+a2)*kenv
        outs2   asig    
garvb   =       garvb+(asig*.2) 
        endin
    
    
        instr 399
irvbtime = 1.6*p4
asig    nreverb garvb, irvbtime, .4
        outs    asig, asig
garvb   =       0
        endin

</CsInstruments>
<CsScore>
f 1 0   8192    10 1 0 1 0 1 0 1 0 1 0 1    
f 2 0   8192    10 1 1 0 0 1  
i 399   0   42  1

i 301   0.0 0.5 8.05    ;F
i 301   0.5 1.5 8.07    ;G
i 301   2.0 1.0 8.07    ;G
i 301   3.0 0.5 8.07    ;G
i 301   3.5 0.5 8.09    ;A
i 301   4.0 0.5 8.11    ;B
i 301   4.5 1.5 9.00    ;C

i 301   18.0    1.0 8.06    ;F#
i 301   18.0    1.0 8.09    ;A
i 301   19.0    1.0 8.07    ;G
i 301   19.0    1.0 8.04    ;E
i 301   20.0    1.0 8.05    ;F

i 302   1.0 0.5 7.00    ;C
i 302   1.5 0.5 7.02    ;D
i 302   2.0 0.5 7.04    ;E
i 302   2.5 0.5 7.05    ;F
i 302   3.0 2.0 7.05    ;F
i 302   5.0 0.5 7.05    ;F
i 302   5.5 0.5 7.07    ;G

i 302   18.0    1.0 8.00    ;C
i 302   18.0    1.0 8.04    ;E
i 302   19.0    1.0 7.11    ;B
i 302   20.0    1.0 8.00    ;C
i 302   20.0    1.0 7.08    ;G#

t 0 120 10  100 20  120


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
