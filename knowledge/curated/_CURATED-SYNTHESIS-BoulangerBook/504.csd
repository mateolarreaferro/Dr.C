<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr      =      	44100
kr    	=     	4410
ksmps  	=     	10
nchnls	=		1

        instr   504
kenv1   linen   p4, .3, p3, .3
kenv2   linseg  0, p3*.9, p4, p3*.1, 0
asig1   oscil   kenv1, cpspch(p5), 1
asig2   oscil   kenv1, cpspch(p5)*p7, 2
asig3   oscil   kenv2, cpspch(p5)*p6, 3
amix    =       asig1 + asig2 + asig3
aflt    butterlp amix, p8*p9
        out     aflt
        endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1
f 2 0 4096 10 16 0 14 0 12 0 10 0 8 0 6 0 4 0 
f 3 0 4096 10 16 0 0 13 0 0 10 0 0 7 0 0 4 0 0 1

#define ARG(A)  #6.345 1.03 $A. 234.9#
                    
i 504   0   1   23000   8.00     $ARG(2.0)
i 504   +   4   24000   8.04     $ARG(5.0)
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1289</x>
 <y>61</y>
 <width>396</width>
 <height>645</height>
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
