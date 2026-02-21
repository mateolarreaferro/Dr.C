<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


          instr     2901
iatk      =         .2
idec      =         .1
isus      =         .8
irel      =         .2
isteady   =         1-(iatk+idec+irel)  ; LENGTH OF SUSTAIN LEVEL
alfo      oscili    0.2, p6, 3
apw       =         alfo+0.25
asaw      oscili    1, p5, 2
apulse    table     asaw-apw, 1, 1, 0.5
          kenv      linseg  0,p3*iatk,1,p3*idec,isus,isteady*p3,isus,p3*irel,0
          out       p4*apulse*kenv
          endin

</CsInstruments>
<CsScore>
f 1 0   32  7   -1  16 -1 0 1 16 1  ;TABLE FOR COMPARATOR
f 2 0   256 7   -1  256 1           ;SAWTOOTH WAVEFORM
f 3 0   1024    10  1               ;SINE WAVE FOR LFO

i 2901  0 6 6000 110  .5
i 2901  0 6 6000 165  .5 
i 2901  1 5 6000  55   1
i 2901  1 5 4000 440   1
i 2901  1 5 4000 220   1
i 2901  1 5 4000 660   1
i 2901  1 5 4000 330   1
i 2901  5 6 6000  87   3
i 2901  5 6 6000 131   3
i 2901  5 6 6000  44   3
i 2901  5 6 4000 349   3
i 2901  5 6 4000 523   3
i 2901  5 3 4000 262   3
i 2901  8 3 6000 294   6
i 2901 10 3 4000 330   6
i 2901 10 6 6000 110   2
i 2901 10 6 5000 165   2
i 2901 10 6 4000  55   2
i 2901 10 6 3000 440   2
i 2901 10 6 3000 220   2
i 2901 10 6 3000 660   2
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
