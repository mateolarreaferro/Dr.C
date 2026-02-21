<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   502
kenv    linen   p4, .2, p3, .1
asig1   oscil   kenv, cpspch(p5), 1
asig2   oscil   kenv, cpspch(p5)*p6, 2
asig3   oscil   kenv, cpspch(p5)*p7, 3
amix    =       asig1 + asig2 + asig3
aflt    butterbp amix, 8000, p8
aflt    balance aflt, amix
        out     aflt
        endin

</CsInstruments>
<CsScore>
f1 0 4096 10 1 0 1 0 1 0 1 0 1 0 1
f2 0 4096 10 1 0 .1 0 .2 0 .3
f3 0 4096 10 1 0 .3 .6 .3 0 1

#define ARGSA   #1.01 1.99 138#
#define ARGSB   #2.02 3.99 838#
                    
i502    0   1   4000    6.01    $ARGSA.
i502    1   1   5000    6.02    $ARGSB.
i502    2   1   6000    6.03    $ARGSA.
i502    3   1   7000    6.04    $ARGSB.
</CsScore>
</CsoundSynthesizer>
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
