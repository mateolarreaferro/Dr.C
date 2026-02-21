<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; multpro2.orc (in the global subdirectory on the CD-ROM)

; instr 99 - general wavetable wind instrument going to multi-effect processor 2
; instr 199 - globabal multi-effect processor 2 (with ring modulation, filter, comb filter, spatialization)


giseed    =       .5
giwtsin   =       1
gasig     init    0
;______________________________________________________________________________________________________
instr 99                                                    ; general wind instrument going to multi-effect 2
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
gasig     =       gasig + asig                              ; send signal to global multi-effect 2
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 199                                                   ; global multi-effect processor 2
                                                            ; ring mod, filt, comb filt, spatialization
; parameters
; p4 initial frequency for modulated cosine
; p5 ending frequency for modulated cosine
; p6 ring modulation switch:
;        0=output original signal only (without ring modulation)
;        1=output both original and ring modulated signals

; p7 frequency of the comb filter
; p8 initial filter cutoff/center frequency
; p9 ending filter cutoff/center frequency
; p10 initial bandwidth for reson and areson filters
; p11 ending bandwidth for reson and areson filters
; p12 percent duration to wait before glissando 
;        (e.g., p6=.1 means hold the initial frequency for 10% of the note duration before glissing)
; p13 percent duration of glissando
;        (e.g., p7=.5 means gliss over half the note's duration)
; p14 attenuation factor for the input signal
; p15 ring time for comb filter
; p16 filter switch (0=no filter, 1=LP filter, 2=BP filter, 3=notch filter, 4=HP filter, 5=comb filter)
; p17 second comb filter switch (0=no second comb filter, 5=second comb filter)
; p18    initial panning position (1 is full left, 0 is full right, and .5 is center)
; p19    intermediate panning  position (1 is full left, 0 is full right, and .5 is center)
; p20    ending panning position (1 is full left, 0 is full right, and .5 is center)
; p21    percent duration of change from initial panning position to intermediate panning position
;         (e.g., .5 means make the first change over half the note's duration)
; p22    initial reverb time
; p23    intermediate reverb time
; p24   final reverb time
; p25   % of reverb relative to source signal at start of note
; p26   % of reverb relative to source signal at middle of note (intermediate position)
; p27   % of reverb relative to source signal at end of note

idur      =       p3                                        ; set the duration at p3

                                                            ; initial variables for ring modulator:
imodfreq  =       p4                                        ; 1st frequency for ring mod (larger number gives more modulation)
imodfreq2 =       p5                                        ; last frequency for ring modulator
imodfreq  =       (imodfreq <= 0 ? .01 : imodfreq)          ; check for 0 values and fix them
imodfreq2 =       (imodfreq2 <= 0 ? .01 : imodfreq2)        ; check for 0 values and fix them
iswitch1  =       p6                                        ; switch chooses ring modulator (1 = modulator)
iwave     =       1                                         ; sine wave (can try with other wavetables)

                                                            ; initial variables for filter:
ifreq     =       p7                                        ; frequency for comb filter
ifilt1    =       p8                                        ; first filter frequency
ifilt2    =       p9                                        ; last filter frequency
ibw1      =       p10                                       ; first bandwidth for reson and areson filters
ibw2      =       p11                                       ; last bandwidth for reson and areson filters
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for 0 values and fix them
p13       =       (p13 <= 0 ? .001 : p13)                   ; check for 0 values and fix them
iwait     =       p12 * idur                                ; duration of wait before glissando
igliss    =       p13 * idur                                ; duration of glissando
          if (iwait + igliss < idur) goto rm1
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
rm1:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
iattn     =       p14                                       ; set attenuation for input signal
iring     =       p15                                       ; ring time for comb filter
iswitch2  =       p16                                       ; filter switch (0=none, 1=LP, 2=BP, 3=notch, 4=HP, 5=comb)
iswitch3  =       p17                                       ; switch for 2nd comb (0=no second comb, 5=second comb)
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)

                                                            ; initial variables for stereo panning:
ileft1    =       p18                                       ; initial position for pan - percent left channel
ileft2    =       p19                                       ; second position for pan - percent left channel
ileft3    =       p20                                       ; end position for pan - percent left channel
ileft1    =       (ileft1 <= 0 ? .01 : ileft1)              ; keep values between 0 and 1
ileft1    =       (ileft1 >= 1 ? .99 : ileft1)
ileft2    =       (ileft2 <= 0 ? .01 : ileft2)
ileft2    =       (ileft2 >= 1 ? .99 : ileft2)
ileft3    =       (ileft3 <= 0 ? .01 : ileft3)
ileft3    =       (ileft3 >= 1 ? .99 : ileft3)
iright1   =       1 - ileft1                                ; initial position for pan - percent right channel
iright2   =       1 - ileft2                                ; second position for pan - percent right channel
iright3   =       1 - ileft3                                ; end position for pan - percent right channel
p21       =       (p21 <= 0 ? .01 : p21)                    ; keep values between 0 and 1
p21       =       (p21 >= 1 ? .99 : p21)
ipan1     =       p21 * idur                                ; time for first panning segment
ipan2     =       idur - ipan1                              ; time for second panning segment

                                                            ; initial variables for reverb:
irevtime1 =       p22                                       ; set first duration of reverb time
irevtime2 =       p23                                       ; set middle duration of reverb time
irevtime3 =       p24                                       ; set final duration of reverb time
irev1     =       p25                                       ; first percent for reverberated signal
irev2     =       p26                                       ; middle percent for reverberated signal
irev3     =       p27                                       ; last percent for reverberated signal
irev1     =       (irev1 <= 0 ? .01 : irev1)                ; keep values between 0 and 1
irev1     =       (irev1 >= 1 ? .99 : irev1)
irev2     =       (irev2 <= 0 ? .01 : irev2)
irev2     =       (irev2 >= 1 ? .99 : irev2)
irev3     =       (irev3 <= 0 ? .01 : irev3)
irev3     =       (irev3 >= 1 ? .99 : irev3)
iunrev1   =       1 - irev1
iunrev2   =       1 - irev2
iunrev3   =       1 - irev3
iring2    =       (irevtime3 > irevtime2 ? irevtime3 : irevtime2)
iring2    =       (irevtime1 > iring2 ? irevtime1 : iring2)
iextend   =       (iring2 > 2*iring ? iring2 : 2*iring )
p3        =       p3 + iextend                              ; lengthen p3 by reverb time or comb time


asig      =       gasig * iattn                             ; set and attenuate the input signal

ringmod:
          if iswitch1 = 0 goto filters
kmodfr    linseg  imodfreq, iwait, imodfreq, igliss, imodfreq2, istay, imodfreq2
amod      oscili  1, kmodfr, iwave                          ; modulator
asig      =       asig * amod                               ; ring modulated signal 

filters:
kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
kbw       linseg  ibw1, iwait, ibw1, igliss, ibw2, istay, ibw2

          if iswitch2 = 1 goto lowpass
          if iswitch2 = 2 goto bandpass
          if iswitch2 = 3 goto notch
          if iswitch2 = 4 goto highpass
          if iswitch2 = 5 goto comb
          goto    comb2

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
          goto    filtbal

filtbal:
asig      balance afilt2, asig              ; balance 
          goto    comb2

comb:
acomb     comb    asig,iring,iloop          ; args:  sig, ring time, loop time
asig      =       acomb
          goto    comb2

comb2:
          if iswitch3 = 0 goto reverb
acomb     comb    asig,iring,iloop          ; args:  sig, ring time, loop time
asig      =       acomb

reverb:
apercent  linseg  irev1, ipan1, irev2, ipan2, irev3, 1, irev3                 ; percent reverb
aunreverb linseg  iunrev1, ipan1, iunrev2, ipan2, iunrev3, 1, iunrev3         ; remaining percent
krevtime  linseg  irevtime1, ipan1, irevtime2, ipan2, irevtime3, 1, irevtime3 ; reverb time
ac1       comb    asig, krevtime, .0297                                       ; reverberate the signal
ac2       comb    asig, krevtime, .0371
ac3       comb    asig, krevtime, .0411
ac4       comb    asig, krevtime, .0437
acomb     =       ac1 + ac2 + ac3 + ac4
ap1       alpass  acomb, .09683, .005
arev      alpass  ap1, 03292, .0017
areverb   =       (aunreverb * asig) + (apercent * arev)   ; mix first percent of reverberated signal

leftchannel:
apanl     linseg  ileft1, ipan1, ileft2, ipan2, ileft3, 1, ileft3            ; amplitude envelope for left channel
apanl     =       sqrt(apanl)
asigl     =       apanl * areverb

rightchannel:
apanr     linseg  iright1, ipan1, iright2, ipan2, iright3, 1, iright3        ; amplitude envelope for right channel
apanr     =       sqrt(apanr)
asigr     =       apanr * areverb

          outs    asigl, asigr                              ; output reverberated stereo signal
gasig     =       0                                         ; set gasig to 0 to prevent feedback
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; multpro2.sco  (in the global subdirectory on the CD-ROM)
; bass clarinet with ring modulation, filter, comb filter and spatialization

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f76 0 16384 -17 0 0 70 1 99 2 140 3 198 4                                     ; bassclar wavetables
f77 0 64 -2 78 79 80 5.293 81 82 83 3.726 84 85 86 4.229 87 88 89 1.620 90 91 92 1.347
f78 0 4097 -9 3 1.148 0 
f79 0 4097 -9 4 0.027 0 5 1.620 0 6 0.023 0 7 0.545 0 
f80 0 4097 -9 8 0.056 0 9 1.113 0 10 0.033 0 11 0.866 0 12 0.038 0 13 0.324 0 14 0.086 0 15 0.219 0 16 0.127 0 17 0.057 0 18 0.026 0 19 0.029 0 20 0.081 0 21 0.133 0 22 0.123 0 23 0.157 0 24 0.232 0 25 0.077 0 26 0.064 0 27 0.241 0 28 0.187 0 29 0.244 0 30 0.202 0 31 0.116 0 32 0.023 0 34 0.081 0 35 0.157 0 36 0.106 0 37 0.158 0 38 0.036 0 39 0.095 0 41 0.117 0 43 0.048 0 44 0.025 0 
f81 0 4097 -9 2 0.024 0 3 0.985 0 
f82 0 4097 -9 4 0.039 0 5 0.740 0 7 0.178 0 
f83 0 4097 -9 9 0.093 0 10 0.050 0 11 0.285 0 12 0.083 0 13 0.317 0 14 0.137 0 15 0.400 0 16 0.047 0 17 0.476 0 18 0.128 0 19 0.370 0 20 0.054 0 21 0.093 0 22 0.083 0 23 0.110 0 24 0.030 0 25 0.061 0 26 0.056 0 27 0.113 0 28 0.225 0 29 0.050 0 30 0.091 0 31 0.022 0 32 0.034 0 34 0.055 0 35 0.039 0 
f84 0 4097 -9 3 0.492 0 
f85 0 4097 -9 5 0.730 0 6 0.061 0 7 0.678 0 
f86 0 4097 -9 8 0.217 0 9 1.125 0 10 0.131 0 11 0.383 0 12 0.092 0 13 0.314 0 14 0.104 0 15 0.139 0 16 0.135 0 17 0.218 0 18 0.044 0 19 0.135 0 20 0.283 0 21 0.046 0 22 0.150 0 24 0.059 0 25 0.029 0 26 0.047 0 29 0.029 0 30 0.044 0 31 0.050 0 32 0.041 0  
f87 0 4097 -9 3 0.084 0 
f88 0 4097 -9 4 0.025 0 5 0.359 0 6 0.072 0 7 0.440 0 
f89 0 4097 -9 9 0.271 0 10 0.087 0 11 0.095 0 12 0.079 0 13 0.061 0 14 0.093 0 15 0.058 0 16 0.045 0 18 0.026 0 19 0.027 0 22 0.023 0 
f90 0 4097 -9 2 0.040 0 3 0.354 0 
f91 0 4097 -9 5 0.178 0 6 0.058 0 7 0.294 0 
f92 0 4097 -9 8 0.081 0 9 0.073 0 10 0.230 0 11 0.048 0 12 0.052 0 13 0.067 0 16 0.028 0 

t 0 66
;p1   p2      p3      p4      p5        p6      p7      p8      p9  p10
;     start   dur     amp     Hertz     vibr    att     dec     br  in#
;pickup at score marking 6-----------------------------------------------
i99   1.340   0.150   25000    81.750   0.000   0.040   0.050   9   6
i99   1.440   0.230   25000    93.013   0.000   0.040   0.070   9   6
i99   1.670   0.330   25000    93.013   0.000   0.040   0.080   9   6
;bar 1 of solo-----------------------------------------------------------
i99   2.000   0.150   25000    81.750   0.000   0.040   0.050   9   6
i99   2.100   0.150   25000    93.013   0.000   0.040   0.050   9   6
i99   2.200   0.200   25000    93.013   0.000   0.040   0.050   9   6
i99   2.400   0.200   25000    93.013   0.000   0.040   0.050   9   6
i99   2.600   0.200   25000    93.013   0.000   0.040   0.050   9   6
i99   2.800   0.200   25000    93.013   0.000   0.040   0.050   9   6
i99   3.000   0.220   25000    93.013   0.000   0.040   0.050   9   6
i99   3.125   0.220   25000   109.000   0.000   0.040   0.050   9   6
i99   3.250   0.220   25000   163.500   0.000   0.040   0.050   9   6
i99   3.375   0.220   25000   209.280   0.000   0.040   0.050   9   6
i99   3.500   0.220   25000   186.027   0.000   0.040   0.050   9   6
i99   3.625   0.220   25000   261.600   0.000   0.040   0.050   9   6
i99   3.750   0.220   25000   163.500   0.000   0.040   0.050   9   6
i99   3.875   0.220   25000   109.000   0.000   0.040   0.050   9   6
;bar 2 of solo-----------------------------------------------------------
i99   4.000   0.500   25000    93.013   0.000   0.040   0.100   9   6
i99   4.500   0.170   25000    81.750   0.000   0.040   0.050   9   6
i99   4.600   0.625   25000    93.013   0.000   0.050   0.100   9   6
i99   5.125   0.220   25000   109.000   0.000   0.040   0.050   9   6
i99   5.250   0.220   25000   163.500   0.000   0.040   0.050   9   6
i99   5.375   0.220   25000   209.280   0.000   0.040   0.050   9   6
i99   5.500   0.220   23000   186.027   0.000   0.040   0.050   9   6
i99   5.625   0.220   25000   261.600   0.000   0.040   0.050   9   6
i99   5.750   0.220   25000   163.500   0.000   0.040   0.050   9   6
i99   5.875   0.220   25000   109.000   0.000   0.040   0.050   9   6
;bar 3 of solo-----------------------------------------------------------
i99   6.000   0.220   25000    93.013   0.000   0.040   0.050   9   6
i99   6.125   0.220   25000   109.000   0.000   0.040   0.050   9   6
i99   6.250   0.220   25000   163.500   0.000   0.040   0.050   9   6
i99   6.375   0.220   25000   209.280   0.000   0.040   0.050   9   6
i99   6.500   0.220   25000   186.027   0.000   0.040   0.050   9   6
i99   6.625   0.220   25000   261.600   0.000   0.040   0.050   9   6
i99   6.750   0.220   25000   163.500   0.000   0.040   0.050   9   6
i99   6.875   0.220   25000   109.000   0.000   0.040   0.050   9   6
i99   7.000   0.300   25000    93.013   0.000   0.040   0.070   9   6
i99   7.250   0.150   25000    81.750   0.000   0.040   0.050   9   6
i99   7.350   0.150   25000    93.013   0.000   0.040   0.050   9   6
i99   7.500   0.250   25000    93.013   0.000   0.040   0.070   9   6
i99   7.750   0.250   25000    93.013   0.000   0.040   0.070   9   6

;multiprocessor 2:  use only ONE line (each line gives a different timbre for the preceding score)---------------------------------------------------------
;p1    p2 p3  p4    p5     p6  p7    p8    p9    p10  p11    p12  p13   p14  p15  p16 p17 p18  p19  p20  p21  p22   p23   p24   p25   p26   p27
;             ringmod......... filters................................................... stereo............. reverb.............................   
;      st dur mfr1  mfr2   sw1 cmbfr filt1 filt2 bw1  bw2    wait gliss attn ring sw2 sw3 pan1 pan2 pan3 dur1 rtim1 rtim2 rtim3 %rev1 %rev2 %rev3
;i199  0  9   0       0    0   220    55   1760   0      0   .1   .8    .5   0    0   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; no filt
;i199  0  9   0       0    0   220    55   1760   0      0   .1   .8    .5   0    1   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; LP
;i199  0  9   0       0    0   880    55   1760   1    100   .1   .8    .5   0    2   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; BP
;i199  0  9   0       0    0   220    55   1760   1   1000   .1   .8    .5   0    3   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; notch
;i199  0  9   0       0    0   880    55   1760   0      0   .1   .8    .5   0    4   0   1    0    1    .5   .1    1.1   .5    .05   .3    .05   ; HP
;i199  0  9   0       0    0   880    55   1760   0      0   .1   .8    .5   .3   5   0   1    0    1    .5   .1    1.1   .5    .05   .3    .05   ; comb

;i199  0  9   0       0    0   220    55   1760   0      0   .1   .8    .3   .3   1   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; LP
;i199  0  9   0       0    0   880    55   1760   1    100   .1   .8    .2   .3   2   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; BP
 i199  0  9   0       0    0   220    55   1760   1   1000   .1   .8    .3   .3   3   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; notch
;i199  0  9   0       0    0   880    55   1760   0      0   .1   .8    .2   .3   4   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; HP
;i199  0  9   0       0    0   880    55   1760   0      0   .1   .8    .02  .3   5   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; comb

;i199  0  9   1     200    1   220    55   1760   0      0   .1   .8    .5   0    0   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; no filt
;i199  0  9   1     200    1   220    55   1760   0      0   .1   .8    .5   0    1   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; LP
;i199  0  9   1     200    1   880    55   1760   1    100   .1   .8    .5   0    2   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; BP
;i199  0  9   1     200    1   220    55   1760   1   1000   .1   .8    .5   0    3   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; notch
;i199  0  9   1     200    1   880    55   1760   0      0   .1   .8    .5   0    4   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; HP
;i199  0  9   1     200    1   880    55   1760   0      0   .1   .8    .04  .3   5   0   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; comb

;i199  0  9   1     200    1   220    55   1760   0      0   .1   .8    .1   .3   1   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; LP
;i199  0  9   1     200    1   880    55   1760   1    100   .1   .8    .2   .3   2   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; BP
;i199  0  9   1     200    1   220    55   1760   1   1000   .1   .8    .2   .3   3   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; notch
;i199  0  9   1     200    1   880    55   1760   0      0   .1   .8    .1   .3   4   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; HP
;i199  0  9   1     200    1   880    55   1760   0      0   .1   .8    .001 .3   5   5   1    0    1    .5   .1    1.1   .5    .05   .5    .05   ; comb
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
