<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          
          instr     1201      ; SIMPLE FM INSTRUMENT
isine     =         1                             ; f1 HAS SINE TABLE
iamp      =         p4                            ; PEAK AMP OF CARRIER
icarhz    =         p5                            ; CARRIER FREQUENCY
imodhz    =         p6                            ; MODULATOR FREQUENCY
index     =         p7                            ; MAX INDEX OF MODULATION
index1    =         p8                            ; MINIMUM INDEX
irise     =         p9                            ; RISE TIME
idecay    =         p10                           ; DECAY TIME
isteady   =         p3-irise-idecay               ; STEADY STATE TIME
imaxdev   =         index*imodhz             ; D = I * M
imindev   =         index1*imodhz            ; MINIMUM DEVIATION
ivardev   =         imaxdev-imindev               ; VARIABLE DEVIATION
kenv      expseg    .001, irise, 1, isteady, 1, idecay, .001     
kmodamp   =         imindev+ivardev*kenv     ; AMPLITUDE OF MODULATOR
amodsig   oscili    kmodamp, imodhz, isine   ; GATED MODULATOR
acarsig   oscili    iamp*kenv, icarhz+amodsig, isine   
          out       acarsig   
          endin          

</CsInstruments>
<CsScore>
f 1 0   2048    10  1       ;SINE
;   ST  DUR AMP CARHZ   MODHZ   NDX NDX1    RISE    DECAY
i 1201  0   .6  20000   440 440 5   0   .1  .2  ;BRASS
i 1201  1   .6  20000   900 300 2   0   .1  .2  ;WOODWIND
i 1201  2   .6  20000   500 100 1.5 0   .1  .2  ;BASSOON
i 1201  3   .6  20000   900 600 4   2   .1  .2  ;CLARINET
i 1201  4   15  20000   200 280 10  0   .001    14.99   ;BELL
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>8</height>
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
