<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr   503
kenv    linen   p4, .3, p3, .3
asig    oscil   kenv, cpspch(p5), 1
        out     asig
        endin

</CsInstruments>
<CsScore>
f 1 0 4096 10 1 0 1

#define C   #8.00#
#define Csharp  #8.01#
#define Dflat   #8.01#
#define D   #8.02#
#define Dsharp  #8.03#
#define Eflat   #8.03#
#define E   #8.04#
#define F   #8.05#

i 503   0   1   14000    $C.
i 503   1   1   15000    $D. 
i 503   2   1   16000    $E.
i 503   3   1   17000    $F.

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
