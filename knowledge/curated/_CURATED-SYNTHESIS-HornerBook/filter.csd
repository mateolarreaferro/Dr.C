<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; filter.orc (in the global subdirectory on the CD-ROM)

; instr 81 - general wavetable wind instrument going to filter
; instr 181 - global lowpass, highpass, bandpass and notch filters

giseed    =       .5
giwtsin   =       1
gafilt    init    0
;______________________________________________________________________________________________________
instr 81                                                    ; general wind instrument going to filter
; parameters
; p4 overall amplitude scaling factor
; p5 pitch in Hertz
; p6 percent vibrato depth, recommended values in range [0, 1]
;         0 = no vibrato, 1 = 1% vibrato depth
; p7 attack time in seconds, recommended values in range [.03, .1]
; p8 decay time in seconds, recommended values in range [.04, .2]
; p9 overall brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p10 wind instrument number (1 = piccolo, 2 = flute, etc.)
;___________________________________________________________; initial variables 
idur      =       p3                                        ; duration
iamp      =       p4                                        ; overall amplitude scaling factor
ifreq     =       p5                                        ; pitch in Hertz
ivibd     =       abs(p6*ifreq/100.0)                       ; vibrato depth relative to fund. freq
iatt      =       p7                                        ; attack time
idec      =       p8                                        ; decay time
ibrite    tablei  p9, 2                                     ; lowpass filter cutoff frequency
itablno   table   p10, 3                                    ; select first wavetable number for this
                                                            ; instrument (in table 3)
isus      =       idur - iatt - idec - .005                 ; sustain time
ivibr1    =       2.5 + giseed
giseed    =       frac(giseed*105.947)
ivibr2    =       4.5 + giseed
giseed    =       frac(giseed*105.947)
iphase    =       giseed                                    ; use same phase for all wavetables
giseed    =       frac(giseed*105.947)
;___________________________________________________________; range-specific variables
irange    table   ifreq, itablno                            ; frequency range of current note
itabl2    =       itablno + 1
iwt1      =       1                                         ; wavetable numbers
iwt2      table   (irange*4), itabl2
iwt3      table   (irange*4)+1, itabl2
iwt4      table   (irange*4)+2, itabl2
inorm     table   (irange*4)+3, itabl2                      ; normalization factor
;___________________________________________________________; vibrato block
kvibd     linseg  .1, .8*idur, 1, .2*idur, .7               ; vibrato
kvibd     =       kvibd * ivibd                             ; vibrato depth
kvibrat   linseg  ivibr1, idur, ivibr2                      ; time-varying vibrato rate
kvib      oscil   kvibd, kvibrat, 1
kfreq     =       ifreq + kvib
;___________________________________________________________; amplitude envelopes
amp1      linseg  0,.001,0,.5*iatt,.5,.5*iatt,.9,.5*isus,1,.5*isus,.9,.5*idec,.3,.5*idec,0,1,0
amp2      =       amp1 * amp1    
amp3      =       amp2 * amp1
amp4      =       amp3 * amp1
;___________________________________________________________; wavetable lookup
awt1      oscili  amp1, kfreq, iwt1, iphase        
awt2      oscili  amp2, kfreq, iwt2, iphase
awt3      oscili  amp3, kfreq, iwt3, iphase
awt4      oscili  amp4, kfreq, iwt4, iphase
asig      =       (awt1+awt2+awt3+awt4)*iamp/inorm
afilt     tone    asig, ibrite                              ; lowpass filter for brightness control
asig      balance afilt, asig
gafilt    =       gafilt + asig                             ; send signal to global filter
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 181                                                   ; global filter: LP, HP, BP, Notch
; parameters
; p4 initial filter frequency
; p5 ending filter frequency
; p6 initial bandwidth for reson and areson filters
; p7 ending bandwidth for reson and areson filters
; p8 percent duration to wait before frequency change
;        (e.g., .1 means use the initial frequency for 10% of the note duration before beginning freq. change)
; p9 percent duration for frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p10 attenuation factor for filtered signal
; p11 filter switch (0=no filter, 1=LP filter, 2=BP filter, 3=notch filter, 4=HP filter)

idur      =       p3    
ifilt1    =       p4                                        ; first filter frequency
ifilt2    =       p5                                        ; last filter frequency
ibw1      =       p6                                        ; first bandwidth for reson and areson filters
ibw2      =       p7                                        ; last bandwidth for reson and areson filters
p8        =       (p8 <= 0 ? .001 : p8)                     ; check for 0 values and fix them
p9        =       (p9 <= 0 ? .001 : p9)                     ; check for 0 values and fix them
iwait     =       p8 * idur                                 ; duration of wait before glissando
igliss    =       p9 * idur                                 ; duration of glissando
          if (iwait + igliss < idur) goto filt1
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
filt1:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
iattn     =       p10                                       ; set attenuation for output signal
iswitch   =       p11                                       ; switch chooses filter 
                                                            ;   (1=lowpass, 2=bandpass, 3=notch, 4=highpass)
asig      =       gafilt
          if iswitch = 0 goto filtend
kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
kbw       linseg  ibw1, iwait, ibw1, igliss, ibw2, istay, ibw2
          if iswitch = 1 goto lowpass
          if iswitch = 2 goto bandpass
          if iswitch = 3 goto notch
          if iswitch = 4 goto highpass

lowpass:
afilt     tone    asig,kfreq
afilt2    tone    afilt,kfreq               ; filter out high freqs: kfreq = half amplitude point
          goto    filtbal

bandpass:
afilt     reson   asig,kfreq,kbw,0
afilt2    reson   afilt,kfreq,kbw,0         ; bandpass: kfreq = center frequency of passband
          goto    filtbal

notch:
afilt     areson  asig,kfreq,kbw,1
afilt2    areson  afilt,kfreq,kbw,1         ; notch: kfreq = center frequency of notch
          goto    filtbal

highpass:
afilt     atone   asig,kfreq
afilt2    atone   afilt,kfreq               ; filter out low freqs: kfreq = half amplitude point

filtbal:
asig      balance afilt2,gafilt*iattn       ; balance and attenuate amplitude

filtend:
          out     asig                      ; output signal
gafilt    =       0
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; filter.sco (in the global subdirectory on the CD-ROM)
; Bach's Fugue #2 in C Minor for oboe duet

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f29 0 16384 -17 0 0 355 1 503 2 888 3                                         ; oboe wavetables
f30 0 64 -2 31 32 33 4.683 34 35 36 6.794 37 38 39 3.331 40 41 4 1.369
f31 0 4097 -9 2 0.929 0 3 0.953 0 
f32 0 4097 -9 4 0.881 0 5 1.443 0 6 0.676 0 7 0.257 0 
f33 0 4097 -9 8 0.198 0 9 0.100 0 10 0.081 0 11 0.113 0 12 0.049 0 13 0.092 0 14 0.071 0 15 0.038 0 
f34 0 4097 -9 2 1.460 0 3 2.713 0 
f35 0 4097 -9 4 1.360 0 5 1.192 0 6 0.615 0 7 0.256 0 
f36 0 4097 -9 8 0.228 0 9 0.320 0 10 0.158 0 11 0.063 0 12 0.039 0 13 0.062 0 14 0.047 
f37 0 4097 -9 2 1.386 0 3 1.370 0 
f38 0 4097 -9 4 0.360 0 5 0.116 0 6 0.106 0 7 0.201 0 
f39 0 4097 -9 8 0.037 0 9 0.019 0 
f40 0 4097 -9 2 0.646 0 3 0.034 0 
f41 0 4097 -9 4 0.136 0 5 0.026 0 

t 0 80
;p1   p2       p3      p4     p5        p6      p7      p8      p9  p10
;     start    dur     amp    Hertz     vibr    att     dec     br  in#
;bar 1---------------------------------------------------------------------------------
i81    1.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i81    1.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i81    2.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i81    2.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i81    3.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i81    3.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i81    3.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i81    4.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i81    4.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
;bar 2---------------------------------------------------------------------------------
i81    5.000   0.550  10000   392.400   0.700   0.045   0.150   9   3
i81    5.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i81    5.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i81    6.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i81    6.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
i81    7.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i81    7.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i81    7.500   1.050   7200   418.560   0.700   0.045   0.150   9   3
i81    8.500   0.300   7200   392.400   0.700   0.045   0.150   9   3
i81    8.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 3 (upper)-------------------------------------------------------------------------
i81    9.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i81    9.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i81   10.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i81   10.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i81   11.000   0.550   9000   627.840   0.700   0.045   0.150   9   3
i81   11.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i81   11.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i81   12.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i81   12.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
;bar 3 (lower)--------------------------------------------------------------------------
i81    9.000   0.300  10000   313.920   0.700   0.045   0.150   9   3
i81    9.250   0.300   6500   523.200   0.700   0.045   0.150   9   3
i81    9.500   0.300   7200   490.500   0.700   0.045   0.150   9   3
i81    9.750   0.300   6500   436.000   0.700   0.045   0.150   9   3
i81   10.000   0.300   8100   392.400   0.700   0.045   0.150   9   3
i81   10.250   0.300   6500   348.800   0.700   0.045   0.150   9   3
i81   10.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i81   10.750   0.300   6500   294.300   0.700   0.045   0.150   9   3
i81   11.000   0.550   9000   261.600   0.700   0.045   0.150   9   3
i81   11.500   0.550   7200   627.840   0.700   0.045   0.150   9   3
i81   12.000   0.550   8100   588.600   0.700   0.045   0.150   9   3
i81   12.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
;bar 4 (upper)-------------------------------------------------------------------------
i81   13.000   0.550  10000   588.600   0.700   0.045   0.150   9   3
i81   13.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i81   13.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i81   14.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i81   14.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
i81   15.000   0.300   9000   523.200   0.700   0.045   0.150   9   3
i81   15.250   0.300   6500   588.600   0.700   0.045   0.150   9   3
i81   15.500   1.050   8100   627.840   0.700   0.045   0.150   9   3
i81   16.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i81   16.750   0.300   6500   523.200   0.700   0.045   0.150   9   3
;bar 4 (lower)-------------------------------------------------------------------------
i81   13.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i81   13.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
i81   14.000   0.550   8100   470.080   0.700   0.045   0.150   9   3
i81   14.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i81   15.000   0.550   9000   372.053   0.700   0.045   0.150   9   3
i81   15.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i81   16.000   0.550   8100   436.000   0.700   0.045   0.150   9   3
i81   16.500   0.550   7200   372.053   0.700   0.045   0.150   9   3
;bar 5 (upper)-------------------------------------------------------------------------
i81   17.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i81   17.500   0.300   7200   627.840   0.700   0.045   0.150   9   3
i81   17.750   0.300   6500   588.600   0.700   0.045   0.150   9   3
i81   18.000   0.550   8100   627.840   0.700   0.045   0.150   9   3
i81   18.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i81   19.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i81   19.500   0.300   7200   697.600   0.700   0.045   0.150   9   3
i81   19.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i81   20.000   0.550   8100   697.600   0.700   0.045   0.150   9   3
i81   20.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
;bar 5 (lower)-------------------------------------------------------------------------
i81   17.000   1.050  10000   392.400   0.700   0.045   0.150   9   3
i81   18.250   0.300   6500   261.600   0.700   0.045   0.150   9   3
i81   18.500   0.300   7200   294.300   0.700   0.045   0.150   9   3
i81   18.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i81   19.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i81   19.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i81   19.500   0.800   7200   418.560   0.700   0.045   0.150   9   3
i81   20.250   0.300   6500   294.300   0.700   0.045   0.150   9   3
i81   20.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i81   20.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 6 (upper)-------------------------------------------------------------------------
i81   21.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i81   21.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i81   21.750   0.300   6500   697.600   0.700   0.045   0.150   9   3
i81   22.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i81   22.500   0.550   7200   490.500   0.700   0.045   0.150   9   3
i81   23.000   0.550   9000   523.200   0.700   0.045   0.150   9   3
i81   23.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i81   23.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i81   24.000   2.050   8100   697.600   0.700   0.045   0.150   9   3
;bar 6 (lower)-------------------------------------------------------------------------
i81   21.000   0.300  10000   392.400   0.700   0.045   0.150   9   3
i81   21.250   0.300   6500   436.000   0.700   0.045   0.150   9   3
i81   21.500   0.800   7200   470.080   0.700   0.045   0.150   9   3
i81   22.250   0.300   6500   313.920   0.700   0.045   0.150   9   3
i81   22.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i81   22.750   0.300   6500   392.400   0.700   0.045   0.150   9   3
i81   23.000   0.300   9000   418.560   0.700   0.045   0.150   9   3
i81   23.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i81   23.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i81   23.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i81   24.000   0.550   8100   294.300   0.700   0.045   0.150   9   3
i81   24.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i81   24.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
;bar 7 (lower)-------------------------------------------------------------------------
i81   25.000   1.050  10000   523.200   0.700   0.045   0.150   9   3

;filter------------------------------------------------------------------
;p1     p2    p3     p4      p5     p6    p7    p8   p9    p10   p11
;       start dur    filt1   filt2  bw1   bw2   wait gliss attn  switch
;i181   1.5   24.6      0       0      0     0  0    0     0     0   ; no filter
;i181   1.5   24.6   5000      10      0     0  .1   .8    1     1   ; lowpass filter
;i181   1.5   24.6   5000      10    100   100  .1   .8    1     2   ; bandpass: moving fc (fixed bw) 
;i181   1.5   24.6    500     500   5000     1  .1   .8    1     2   ; bandpass: moving bw (fixed fc) 
 i181   1.5   24.6    220    7040      1   100  .1   .8    1     2   ; bandpass: bw and fc moving
;i181   1.5   24.6   5000      10    500   500  .1   .8    1     3   ; notch: moving fc (fixed bw)
;i181   1.5   24.6    500     500   1000     1  .1   .8    1     3   ; notch: moving bw (fixed fc)
;i181   1.5   24.6   4000      20      1  1000  .1   .8    1     3   ; notch: bw and fc moving
;i181   1.5   24.6     10    5000      0     0  .1   .8    1     4   ; highpass filter
end
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
