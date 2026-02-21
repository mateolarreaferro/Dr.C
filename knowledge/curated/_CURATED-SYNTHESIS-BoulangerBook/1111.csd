<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;----------------------------------------- 
        instr 1111  ; VARIABLE PARAMETER AMPLITUDE MODULATION INSTRUMENT.
                    ; THE FOLLOWING CAN BE MADE TO CHANGE IN TIME :
                    ; OVERALL AMPLITUDE, CARRIER FREQUENCY,
                    ; C/M RATIO, FRACTION OF THE CARRIER TO 
                    ; BE MODULATED. 
;-------------------------------------------------------; PARAMETER LIST
;p4  : MAX AMPLITUDE
;p5  : HIGHEST CARRIER PITCH
;p6  : MAX CARRIER TO MODULATOR RATIO (C/M)
;p7  : FUNCTION TABLE CONTROLLING AMPLITUDE
;p8  : FUNCTION TABLE CONTROLLING CARRIER PITCH
;p9  : FUNCTION TABLE CONTROLLING C/M RATIO
;p10 : FUNCTION TABLE CONTROLLING MODULATION FRACTION
;---------------------------------------------------------------------- 
ifr     =       cpspch(p5)              ; PITCH TO FREQUENCY CONVERSION
;---------------------------------------; ENVELOPES
kamp    oscil1  0,p4,p3,p7              ; AMPLITUDE
kcar    oscil1  0,ifr,p3,p8             ; CARRIER FREQ
kcmr    oscil1  0,p6,p3,p9              ; C/M
kmp     oscil1  0,1,p3,p10              ; MODULATION FRACTION
;---------------------------------------; MODULATION
acarr   oscili  1, kcar, 10             ; CARRIER
amod    oscili  1, kcar/kcmr,11         ; MODULATOR
aoutm   =       acarr*amod*kmp          ; MODULATED SIGNAL
aoutnm  =       acarr*(1-kmp)           ; UNMODULATED SIGNAL
;---------------------------------------; MIX AND OUTPUT
        out     kamp*(aoutm+aoutnm)
        endin

</CsInstruments>
<CsScore>
;1111.SCO  RING MODULATION EXAMPLES
;             (C) RAJMIL FISCHMAN, 1997
;--------------------------------------
;PERCUSSIVE SOUND FUNCTIONS
;OVERALL AMPLITUDE
f 1  0 512 7 0 32 1 64 0.3 384 0
;CARRIER FREQUENCY
f 2  0 512 7 1 512 1 
;CARRIER TO MODULATOR RATIO
f 3  0 512 7 0.6799 32 0.6799 160 1 384 0.9808
;FRACTION OF CARRIER WHICH IS MODULATED
f 4  0 512 7 1 32 0.1 414 0.11

;OVERALL AMPLITUDE FOR THE SOUND BEFORE LAST IN THIS SECTION
f 5  0 512 7 0 16 0.4 16 1 192 1 96 0.3 160 0
;CARRIER FREQUENCY
f 6  0 512 7 1 512 0.9 
;CARRIER TO MODULATOR RATIO
f 7  0 512 7 0.6799 32 0.6799 100 1 124 0.9808 300 0.707
;CARRIER AND MODULATOR FUNCTIONS
f 10 0 4096 10 1                                 ; CARRIER
f 11 0 4096 10 1 .9 .8 .7 .6 .5 .6 .7 .8         ; MODULATOR
;-------------------------------------------------------------
;               p3   p4     p5      p6    p7   p8   p9   p10
;INSTR   START  DUR  MAX    HIGHEST MAX   AMP  CARR C/M  MOD FR
;                    AMP    CARR    C/M   FUNC FUNC FUNC FUNC
;                           PITCH
;-------------------------------------------------------------
;SOUND TYPE 1 - CHANGE IN DURATION AND MODULATION INDEX
i 1111      0      0.1  10000  8.00    3     1    2    3    4
i 1111      +      0.1  >      .       3     .    .    .    .
i 1111      +      0.1  >      .       3     .    .    .    .
i 1111      +      0.2  >      .       4     .    .    .    .
i 1111      +      0.3  >      .       5     .    .    .    .
i 1111      +      0.4  >      .       6     .    .    .    .
i 1111      +      0.5  15000  .       7     .    .    .    .
i 1111      +      0.6  >      .       8     .    .    .    .
i 1111      +      0.7  >      .       9     .    .    .    .
i 1111      +      4.7  >      .       9     .    .    .    .
;SOUND TYPE 2 - ENDS WITH GRADUAL CHANGE IN MODULATION INDEX
i 1111     5.2     0.1  6000   8.11    3     1    2    3    4
i 1111     5.53    .    >      9.03    .     .    .    .    .
i 1111     5.86    .    >      10.02   .     .    .    .    .
i 1111     6.16    .    >      9.06    .     .    .    .    .
i 1111     6.42    .    10000  8.10    .     .    .    .    .
i 1111     6.66    .    >      9.09    .     .    .    .    .
i 1111     6.86    .    >      9.09    .     .    .    .    .
i 1111     5.53    .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    .     .    .    .    .
i 1111      +      .08  >      9.09    3     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  8000   9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    0.34  .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  >      9.09    >     .    .    .    .
i 1111      +      .08  10000  9.09    1.5   .    .    .    .
i 1111      +      .08  >      9.090   >     .    .    .    .
i 1111      +      .08  >      9.089   >     .    .    .    .
i 1111      +      .08  >      9.0910  >     .    .    .    .
i 1111      +      .08  >      9.0890  >     .    .    .    .
i 1111      +      .08  >      9.0915  >     .    .    .    .
i 1111      +      .08  >      9.0885  >     .    .    .    .
i 1111      +      .08  >      9.0920  >     .    .    .    .
i 1111      +      .08  14000  9.0880  >     .    .    .    .
i 1111      +      .08  >      9.0925  >     .    .    .    .
i 1111      +      .08  >      9.0875  >     .    .    .    .
i 1111      +      .08  >      9.0930  >     .    .    .    .
i 1111      +      .08  >      9.0870  >     .    .    .    .
i 1111      +      .08  >      9.0935  >     .    .    .    .
i 1111      +      .08  >      9.0865  >     .    .    .    .
i 1111      +      .08  >      9.0940  >     .    .    .    .
i 1111      +      .08  >      9.0860  >     .    .    .    .
i 1111      +      .08  >      9.0945  >     .    .    .    .
i 1111      +      .08  >      9.0855  >     .    .    .    .
i 1111      +      .08  >      9.0950  >     .    .    .    .
i 1111      +      .08  >      9.0850  >     .    .    .    .
i 1111      +      .08  >      9.0955  >     .    .    .    .
i 1111      +      .08  >      9.0845  >     .    .    .    .
i 1111      +      .08  >      9.0960  >     .    .    .    .
i 1111      +      .08  >      9.0840  >     .    .    .    .
i 1111      +      .08  >      9.0965  >     .    .    .    .
i 1111      +      .08  >      9.0835  >     .    .    .    .
i 1111      +      .08  >      9.0970  4.43  .    .    .    .
i 1111      +      .08  >      9.08    >     .    .    .    .
i 1111      +      .08  >      9.0980  >     .    .    .    .
i 1111      +      .08  >      9.0730  >     .    .    .    .
i 1111      +      .08  >      9.10    >     .    .    .    .
i 1111      +      .08  >      9.0590  >     .    .    .    .
i 1111      +      .08  >      9.1040  >     .    .    .    .
i 1111      +      .08  >      9.0310  >     .    .    .    .
i 1111      +      .08  >      9.1120  >     .    .    .    .
i 1111      +      .08  >      8.0950  >     .    .    .    .
i 1111      +      .08  >      10.0060 >     .    .    .    .
i 1111      +      .08  20000  10.0824 2.3   .    .    .    .
i 1111      12.015 2    3000   10.0899 1.001 5    6    7    .
i 1111      12.024 2.7  4000   11      9     .    .    .    .
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
