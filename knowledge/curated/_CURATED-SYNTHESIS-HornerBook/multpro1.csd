<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; multpro1.orc (in the global subdirectory on the CD-ROM)

; instr 80 - general wavetable wind instrument (going to ring modulator)
; instr 180 - global ring modulator (going to filter)
; instr 181 - global lowpass, highpass, bandpass and notch filters (going to comb2)
; instr 183 - global comb filter 2 (going to spatialization)
; instr 198 - global spatialization (reverb & stereo panning)


giseed    =       .5
giwtsin   =       1
garing    init    0
gafilt    init    0
gacomb2   init    0
garev     init    0
;______________________________________________________________________________________________________
instr 80                                                    ; general wind instrument going to ring modulator
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
garing    =       garing + asig                             ; send signal to global ring modulator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 180                                                   ; global ring modulator
; parameters
; p4 initial frequency for modulated cosine
; p5 ending frequency for modulated cosine
; p6 percent duration to wait before glissando 
;        (e.g., p6=.1 means hold the initial frequency for 10% of the note duration before glissing)
; p7 percent duration of glissando
;        (e.g., p7=.5 means gliss over half the note's duration)
; p8 attenuation factor for the ring modulated signal
; p9 wavetable number for the modulated waveform
; p10 percent duration from beginning of note to intermediate position (for change in % ring modulation)
;        (e.g., .5 means half the note's duration)
; p11 % of ring modulation relative to source signal at start of note
; p12 % of ring modulation relative to source signal at "middle" of note (at p10*p3)
; p13 % of ring modulation relative to source signal at end of note

idur      =       p3    
ifreq     =       p4
ifreq2    =       p5
p6        =       (p6 <= 0? .001 : p6)                      ; check for 0 values and fix them
p7        =       (p7 <= 0? .001 : p7)                      ; check for 0 values and fix them
iwait     =       p6 * idur                                 ; duration of wait before glissando
igliss    =       p7 * idur                                 ; duration of glissando
          if (iwait + igliss < idur) goto rm1
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
rm1:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
iattn     =       p8
iwave     =       p9                                        
p10       =       (p10 <= 0? .01 : p10)                     ; check for values between 0 and 1
p10       =       (p10 >= 1? .99 : p10)                     ; check for values between 0 and 1
idur1     =       p10 * idur
idur2     =       idur - idur1            
imod1     =       p11                                       ; initial percent of ring modulated signal
imod2     =       p12                                       ; middle percent of ring modulated signal
imod3     =       p13                                       ; ending percent of ring modulated signal
imod1     =       (imod1 <= 0 ? .01 : imod1)                ; check for values between 0 and 1
imod1     =       (imod1 >= 1 ? .99 : imod1)
imod2     =       (imod2 <= 0 ? .01 : imod2)
imod2     =       (imod2 >= 1 ? .99 : imod2)
imod3     =       (imod3 <= 0 ? .01 : imod3)
imod3     =       (imod3 >= 1 ? .99 : imod3)
iunmod1   =       1 - imod1
iunmod2   =       1 - imod2
iunmod3   =       1 - imod3

kfreq     linseg  ifreq, iwait, ifreq, igliss, ifreq2, istay, ifreq2
amod      oscili  1, kfreq, iwave, .25                      ; modulator
armsig    =       garing * amod                             ; ring modulated signal 
armsig    =       iattn * armsig                            ; attenuate the ring modulated signal
apercent  linseg  imod1, idur1, imod2, idur2, imod3         ; percent ring modulation
aunmod    linseg  iunmod1, idur1, iunmod2, idur2, iunmod3   ; remaining percent
asig      =       (aunmod * garing) + (apercent * armsig)   ; mix percent of modulated signal

gafilt    =       gafilt + asig                             ; send signal to global filter
;         out     asig                                      ; DO NOT OUTPUT asig
garing    =       0
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
gacomb2   =       gacomb2 + asig                            ; send signal to global comb filter 2
;         out     asig                                      ; DO NOT OUTPUT asig
gafilt    =       0
          endin
;______________________________________________________________________________________________________
instr 183                                                   ; global comb filter 2
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 frequency of the comb filter
; p6 initial highpass filter cutoff frequency
; p7 ending highpass filter cutoff frequency
; p8 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p9 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p10 ring time for comb filter
; p11 percent duration from beginning of note to intermediate position (for change in % comb)
;        (e.g., .5 means half the note's duration)
; p12 percent of combed signal at start of note 
;        (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p13 percent of combed signal at "middle" (p13*p3) of note 
; p14 percent of combed signal at end of note

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5                                        ; frequency for comb filter
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p6                                        ; initial HP filter cutoff frequency
ifilt2    =       p7                                        ; ending filter cutoff frequency
p8        =       (p8 <= 0 ? .001 : p8)                     ; check for 0 values and fix them
p9        =       (p9 <= 0 ? .001 : p9)                     ; check for 0 values and fix them
iwait     =       p8 * idur                                 ; duration of wait before cutoff gliss
igliss    =       p9 * idur                                 ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb2a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb2a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
iring     =       p10                                       ; set ring time for comb filter
p3        =       p3 + 2*iring                              ; extend duration to avoid early cutoff
p11       =       (p11 <= 0 ? .01 : p11)                    ; keep values between 0 and 1
p11       =       (p11 >= 1 ? .99 : p11)
idur1     =       p11 * idur                                ; time for first %comb segment
idur2     =       idur - idur1                              ; time for second %comb segment
icomb1    =       p12                                       ; first percent for combed signal (vs orginal)
icomb2    =       p13                                       ; middle percent for combed signal (vs orginal)
icomb3    =       p14                                       ; last percent for combed signal (vs orginal)
icomb1    =       (icomb1 <= 0 ? .01 : icomb1)              ; check for values between 0 and 1
icomb1    =       (icomb1 >= 1 ? .99 : icomb1)
icomb2    =       (icomb2 <= 0 ? .01 : icomb2)
icomb2    =       (icomb2 >= 1 ? .99 : icomb2)
icomb3    =       (icomb3 <= 0 ? .01 : icomb3)
icomb3    =       (icomb3 >= 1 ? .99 : icomb3)
iorig1    =       1 - icomb1                                ; original signal is the rest
iorig2    =       1 - icomb2
iorig3    =       1 - icomb3

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb2,kfreq                             ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb2                            ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
apercent  linseg  icomb1, idur1, icomb2, idur2, icomb3, iring, icomb3	; percent reverb
aorig     linseg  iorig1, idur1, iorig2, idur2, iorig3, iring, iorig3	; remaining percent
asig      =       iamp * ((aorig * gacomb2) + (apercent * acomb))
garev     =       garev + asig                              ; send signal to global spatialization 
;         out     asig                                      ; DO NOT OUTPUT asig
gacomb2   =       0
          endin
;______________________________________________________________________________________________________
instr 198                                                   ; global spatialization instrument
; parameters
; p4    initial panning position (1 is full left, 0 is full right, and .5 is center)
; p5    intermediate panning  position (1 is full left, 0 is full right, and .5 is center)
; p6    ending panning position (1 is full left, 0 is full right, and .5 is center)
; p7    percent duration of change from initial panning position to intermediate panning position
;        (e.g., .5 means make the first change over half the note's duration)
; p8    initial reverb time
; p9    intermediate reverb time
; p10   final reverb time
; p11   % of reverb relative to source signal at start of note
; p12   % of reverb relative to source signal at middle of note (intermediate position)
; p13   % of reverb relative to source signal at end of note
; p14   gain to control the final amplitude of the signal

idur      =       p3                                        ; set the duration at p3
ileft1    =       p4                                        ; initial position for pan - percent left channel
ileft2    =       p5                                        ; second position for pan - percent left channel
ileft3    =       p6                                        ; ending position for pan - percent left channel
ileft1    =       (ileft1 <= 0 ? .01 : ileft1)
ileft1    =       (ileft1 >= 1 ? .99 : ileft1)
ileft2    =       (ileft2 <= 0 ? .01 : ileft2)
ileft2    =       (ileft2 >= 1 ? .99 : ileft2)
ileft3    =       (ileft3 <= 0 ? .01 : ileft3)
ileft3    =       (ileft3 >= 1 ? .99 : ileft3)
iright1   =       1 - ileft1                                ; initial position for pan - percent right channel
iright2   =       1 - ileft2                                ; second position for pan - percent right channel
iright3   =       1 - ileft3                                ; ending position for pan - percent right channel
p7        =       (p7 <= 0 ? .01 : p7)                      ; keep values between 0 and 1
p7        =       (p7 >= 1 ? .99 : p7)
ipan1     =       p7 * idur                                 ; time for first panning segment
ipan2     =       idur - ipan1                              ; time for second panning segment

irevtime1 =       p8                                        ; set first duration of reverb time
irevtime2 =       p9                                        ; set middle duration of reverb time
irevtime3 =       p10                                       ; set final duration of reverb time
irev1     =       p11                                       ; first percent for reverberated signal
irev2     =       p12                                       ; middle percent for reverberated signal
irev3     =       p13                                       ; last percent for reverberated signal
iattn     =       p14                                       ; attenuation
irev1     =       (irev1 <= 0 ? .01 : irev1)                ; check for 0 values and fix them
irev1     =       (irev1 >= 1 ? .99 : irev1)
irev2     =       (irev2 <= 0 ? .01 : irev2)
irev2     =       (irev2 >= 1 ? .99 : irev2)
irev3     =       (irev3 <= 0 ? .01 : irev3)
irev3     =       (irev3 >= 1 ? .99 : irev3)
iunrev1   =       1 - irev1
iunrev2   =       1 - irev2
iunrev3   =       1 - irev3
iring     =       (irevtime3 > irevtime2 ? irevtime3 : irevtime2)
iring     =       (irevtime1 > iring ? irevtime1 : iring)
p3        =       p3 + iring                                ; lengthen p3 by longest reverb time

reverb:
apercent  linseg  irev1, ipan1, irev2, ipan2, irev3, 1, irev3                 ; percent reverb
aunreverb linseg  iunrev1, ipan1, iunrev2, ipan2, iunrev3, 1, iunrev3         ; remaining percent
krevtime  linseg  irevtime1, ipan1, irevtime2, ipan2, irevtime3, 1, irevtime3 ; reverb time
ac1       comb    garev, krevtime, .0297                                      ; reverberate the signal
ac2       comb    garev, krevtime, .0371
ac3       comb    garev, krevtime, .0411
ac4       comb    garev, krevtime, .0437
acomb     =       ac1 + ac2 + ac3 + ac4
ap1       alpass  acomb, .09683, .005
arev      alpass  ap1, 03292, .0017
areverb   =       (aunreverb * garev) + (apercent * arev)   ; mix first percent of reverberated signal
areverb   =       areverb * iattn                           ; attenuation

leftchannel:
apanl     linseg  ileft1, ipan1, ileft2, ipan2, ileft3, 1, ileft3        ; amplitude envelope for left channel
apanl     =       sqrt(apanl)
asigl     =       apanl * areverb

rightchannel:
apanr     linseg  iright1, ipan1, iright2, ipan2, iright3, 1, iright3    ; amplitude envelope for right channel
apanr     =       sqrt(apanr)
asigr     =       apanr * areverb

          outs    asigl, asigr                              ; output reverberated stereo signal
garev     =       0                                         ; set garev to 0 to prevent feedback
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; multpro1.sco (in the global subdirectory on the CD-ROM)
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
i80    1.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i80    1.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i80    2.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i80    2.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i80    3.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i80    3.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i80    3.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i80    4.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i80    4.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
;bar 2---------------------------------------------------------------------------------
i80    5.000   0.550  10000   392.400   0.700   0.045   0.150   9   3
i80    5.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i80    5.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i80    6.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i80    6.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
i80    7.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i80    7.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i80    7.500   1.050   7200   418.560   0.700   0.045   0.150   9   3
i80    8.500   0.300   7200   392.400   0.700   0.045   0.150   9   3
i80    8.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 3 (upper)-------------------------------------------------------------------------
i80    9.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i80    9.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i80   10.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i80   10.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i80   11.000   0.550   9000   627.840   0.700   0.045   0.150   9   3
i80   11.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i80   11.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i80   12.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i80   12.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
;bar 3 (lower)--------------------------------------------------------------------------
i80    9.000   0.300  10000   313.920   0.700   0.045   0.150   9   3
i80    9.250   0.300   6500   523.200   0.700   0.045   0.150   9   3
i80    9.500   0.300   7200   490.500   0.700   0.045   0.150   9   3
i80    9.750   0.300   6500   436.000   0.700   0.045   0.150   9   3
i80   10.000   0.300   8100   392.400   0.700   0.045   0.150   9   3
i80   10.250   0.300   6500   348.800   0.700   0.045   0.150   9   3
i80   10.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i80   10.750   0.300   6500   294.300   0.700   0.045   0.150   9   3
i80   11.000   0.550   9000   261.600   0.700   0.045   0.150   9   3
i80   11.500   0.550   7200   627.840   0.700   0.045   0.150   9   3
i80   12.000   0.550   8100   588.600   0.700   0.045   0.150   9   3
i80   12.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
;bar 4 (upper)-------------------------------------------------------------------------
i80   13.000   0.550  10000   588.600   0.700   0.045   0.150   9   3
i80   13.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i80   13.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i80   14.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i80   14.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
i80   15.000   0.300   9000   523.200   0.700   0.045   0.150   9   3
i80   15.250   0.300   6500   588.600   0.700   0.045   0.150   9   3
i80   15.500   1.050   8100   627.840   0.700   0.045   0.150   9   3
i80   16.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i80   16.750   0.300   6500   523.200   0.700   0.045   0.150   9   3
;bar 4 (lower)-------------------------------------------------------------------------
i80   13.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i80   13.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
i80   14.000   0.550   8100   470.080   0.700   0.045   0.150   9   3
i80   14.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i80   15.000   0.550   9000   372.053   0.700   0.045   0.150   9   3
i80   15.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i80   16.000   0.550   8100   436.000   0.700   0.045   0.150   9   3
i80   16.500   0.550   7200   372.053   0.700   0.045   0.150   9   3
;bar 5 (upper)-------------------------------------------------------------------------
i80   17.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i80   17.500   0.300   7200   627.840   0.700   0.045   0.150   9   3
i80   17.750   0.300   6500   588.600   0.700   0.045   0.150   9   3
i80   18.000   0.550   8100   627.840   0.700   0.045   0.150   9   3
i80   18.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i80   19.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i80   19.500   0.300   7200   697.600   0.700   0.045   0.150   9   3
i80   19.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i80   20.000   0.550   8100   697.600   0.700   0.045   0.150   9   3
i80   20.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
;bar 5 (lower)-------------------------------------------------------------------------
i80   17.000   1.050  10000   392.400   0.700   0.045   0.150   9   3
i80   18.250   0.300   6500   261.600   0.700   0.045   0.150   9   3
i80   18.500   0.300   7200   294.300   0.700   0.045   0.150   9   3
i80   18.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i80   19.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i80   19.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i80   19.500   0.800   7200   418.560   0.700   0.045   0.150   9   3
i80   20.250   0.300   6500   294.300   0.700   0.045   0.150   9   3
i80   20.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i80   20.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 6 (upper)-------------------------------------------------------------------------
i80   21.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i80   21.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i80   21.750   0.300   6500   697.600   0.700   0.045   0.150   9   3
i80   22.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i80   22.500   0.550   7200   490.500   0.700   0.045   0.150   9   3
i80   23.000   0.550   9000   523.200   0.700   0.045   0.150   9   3
i80   23.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i80   23.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i80   24.000   2.050   8100   697.600   0.700   0.045   0.150   9   3
;bar 6 (lower)-------------------------------------------------------------------------
i80   21.000   0.300  10000   392.400   0.700   0.045   0.150   9   3
i80   21.250   0.300   6500   436.000   0.700   0.045   0.150   9   3
i80   21.500   0.800   7200   470.080   0.700   0.045   0.150   9   3
i80   22.250   0.300   6500   313.920   0.700   0.045   0.150   9   3
i80   22.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i80   22.750   0.300   6500   392.400   0.700   0.045   0.150   9   3
i80   23.000   0.300   9000   418.560   0.700   0.045   0.150   9   3
i80   23.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i80   23.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i80   23.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i80   24.000   0.550   8100   294.300   0.700   0.045   0.150   9   3
i80   24.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i80   24.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
;bar 7 (lower)-------------------------------------------------------------------------
i80   25.000   1.050  10000   523.200   0.700   0.045   0.150   9   3

;ring modulator------------------------------------------------------------------------
;p1     p2    p3     p4    p5    p6   p7    p8    p9    p10   p11   p12   p13
;       start dur    freq1 freq2 wait gliss attn  wave  dur1  %mod1 %mod2 %mod3   
i180    1.5   24.6   1     200   .2   .7    .5    1     .5    .5    1     .01

;filter--------------------------------------------------------------------------------
;p1     p2    p3     p4    p5      p6     p7    p8   p9    p10  p11
;       start dur    filt1 filt2   bw1    bw2   wait gliss attn switch
i181    1.5   24.6    55   1760      0      0   .1   .4    1    0   ; no filter
;i181   1.5   24.6    55   1760      0      0   .1   .4    1    1   ; lowpass filter
;i181   1.5   24.6   220   7040      1    100   .1   .4    1    2   ; bandpass filter
;i181   1.5   24.6    55    220      1   1000   .2   .5    1    3   ; notch filter
;i181   1.5   24.6   220   7040      0      0   .2   .4    1    4   ; highpass filter

;comb filter 2-------------------------------------------------------------------------
;p1   p2    p3    p4   p5     p6    p7    p8   p9    p10   p11   p12    p13    p14
;     start dur   amp  combfr filt1 filt2 wait gliss ring  dur1  %comb1 %comb2 %comb3
i183  1.5   24.6  .25  880    220   7040  .1   .4    .3    .5    .5     1      .01

;spatial (stereo and reverb)-----------------------------------------------------------
;p1   p2    p3    p4   p5   p6   p7   p8       p9       p10      p11   p12   p13   p14
;     start dur   pan1 pan2 pan3 dur1 revtime1 revtime2 revtime3 %rev1 %rev2 %rev3 gain
i198  1.5   24.6  1    0    1    .5   .05      1.5     .5        .01   .5    .01   .9
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
