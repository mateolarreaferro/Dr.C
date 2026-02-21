<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
        instr    604        
index   =       p4                  ; LOOKUP INDEX FOR F-TABLE
ift     table   index, 99           ; ift HOLDS F-TABLE 99 FOR AMP
kenv    linen   ampdb(p4), p3*.1,p3, p3*.1 
asig    oscil   kenv, cpspch(p5), ift ; OSCIL USES INDEXED VALUE...
        out     asig                ; ... TO SELECT F-TABLE 1-10
        endin       

</CsInstruments>
<CsScore>
f 1     0   512 10  1 .5 .25                                          ;3 PARTIALS
f 2     0   512 10  1 .5 .25 .125                                     ;4 PARTIALS
f 3     0   512 10  1 .6 .3 .15 .075                                  ;5 PARTIALS
f 4     0   512 10  1 .7 .35 .165 .0825 .04125                   ;6 PARTIALS
f 5     0   512 10  1 .8 .5 .3 .2 .1 .05                         ;7 PARTIALS
f 6     0   512 10  1 .8 .6 .4 .3 .2 .1 .05 .025                 ;9 PARTIALS
f 7     0   512 10  1 .8 .8 .6 .6 .4 .4 .2 .2 .1 .1              ;11 PARTIALS
f 8     0   512 10  1 .9 1 .9 .7 .6 .5 .4 .3 .2 .1 .05           ;12 PARTIALS
f 9     0   512 10  1 .9 1 .9 1 .9 .8 .7 .6 .7 .6 .5 .4          ;13 PARTIALS
f 10    0   512 10  1 1 1 .9 1 1 .8 1 .6 .7 .6 .5 .4 .3          ;14 PARTIALS
f 99    0   128 -17 0 1 45 2 60 3 70 4 75 5 80 6 83 7 86 8 89 9 91 10 

;INS    ST  DUR AMP PCH
i 604   0   1   50  8.00
i 604   +   .   55  .
i 604   +   .   65  .
i 604   +   .   72  .
i 604   +   .   77  .
i 604   +   .   81  .
i 604   +   .   84  .
i 604   +   .   88  .
i 604   +   .   90  .
i 604   +   .   89  .
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>180</height>
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
