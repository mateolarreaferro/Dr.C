<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
=
        instr   505
kenv    linen   p4, .1, p3, .1
asig    oscil   kenv, p5, 1
        out     asig
        endin

        instr   506
kenv    linen   p4, .4, p3, .1
asig    oscil   kenv, p5, 2
        out     asig
        endin

</CsInstruments>
<CsScore>
f1 0 4096 10 1
f2 0 4096 10 16 0 14 0 12 0 10 0 8 0 6 0 4 0 2 0

#define Flute    # i 505 #
#define Clarinet # i 506 #

$Flute.     0   5   10000  440
$Clarinet.  2   3   11000  220
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
