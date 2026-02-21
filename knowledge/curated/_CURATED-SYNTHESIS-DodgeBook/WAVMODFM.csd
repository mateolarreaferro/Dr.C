<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; waveshape mod from music 11 primer
; 9/13/89


          
          instr 1
k1        expseg    .01,.2,1,p3-.4,.9,.2,02
k2        oscil     1,2/p3,3
a1        foscili   k1*p4,p5,5,1.0005,k1*1.5,1
a2        oscili    k1*p4,p5,6
          out       a1*k2 + a2*(1-k2)
          endin

</CsInstruments>
<CsScore>
f 1 0 512 10 1
f 2 0 513 7 0 256 1 256 .75
f 3 0 512 7 1 256 0 256 1
f 4 0 512 7 0 256 1 0 -1 256 0
f 5 0 512 7 1 512 -1
f 6 0 512 10 0 1.5 .25 .1 .1 .4

i1 0  10  7500 100
i1 .2 10  3750 141.4
i1 .4 10  2500 199.8
s
i1 0       .2  5000  146.8
i1  .2      .   .    196
i1  .4      .   .    277.2
i1  .6      .   .    207.6
i1  .8      .   .    246.9
i1  1      1    .    130.8
i1  1.95   .1  7500  207.6
i1  1.95   .1  7500  246.9
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
