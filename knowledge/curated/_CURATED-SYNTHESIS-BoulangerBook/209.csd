<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr 209       
idur    =       p3  
iamp    =       p4          
irow    =       12/idur             ; 12 NOTES PER NOTE DURATION
irowrep =       p5*irow             ; NUMBER OF TIMES TO REPEAT THE ROW
iseed   =       p6                  ; SEED 0-1, SAME SEED = SAME RANDOM SEQ
kenv    oscil   iamp, irowrep, 10   ; f10 = ENVELOPE FUNCTION
kcnt1   phasor  1/idur              ; COUNTS 0-1 OVER NOTE DURATION
kcnt2   =       kcnt1*12            ; COUNTS 0-12 OVER NOTE DURATION
kpc     table   kcnt2, 38           ; f38 = ROW
krn     randh   6, irowrep, iseed   ; DETERMINES RANDOM VALUE
koct    =       (abs(int(krn)))+5   ; CONVERTS TO RANDOM OCTAVE
kpch    =       koct+(kpc*.01)      ; FORMATS PC + RANDOM OCT TO PCH
kcps    =       cpspch(kpch)        ; CONVERTS PCH TO CPS
asig    oscil   kenv, kcps, 4       ; f4 = SQUARE WAVE
        out asig    
        endin       

</CsInstruments>
<CsScore>

; SQUARE WAVE:
f 4 0 513 10 1 0 .333 0 .2 0 .143 0 .111 0 .0909 0 .077 0 .0666

; ENVELOPE FUNCTION:
f 10 0 1024 -19 1 .5 270 .5

; ROW:   
f 38 0 16 -2 2 1 9 10 5 3 4 0 8 7 6 11


i 209 0 4  20000 1  .1
s
f0 1
s ; NOTE SAME SEED = SAME PSUEDO-RANDOM SEQUENCE
i 209 0 4  20000 1  .1
s
f0 1
s
i 209 0 4  20000 1  .2
s
f0 1
s
i 209 0 4  10000  2 .3
s
f0 1
s
i 209 0 4  10000  2 .4
s
f0 1
s
i 209 0 4 25000 4   .5
s
f0 1
s
i 209 0 4 25000 4   .6

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>380</width>
 <height>120</height>
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
