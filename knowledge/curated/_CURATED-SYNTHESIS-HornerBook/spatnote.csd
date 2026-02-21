<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; spatnote.orc (in the noteffct subdirectory on the CD-ROM)

; instr 175 - general wavetable wind instrument with spatialization (panning, reverb and echo) on each note


giseed    =       .5
giwtsin   =       1
;______________________________________________________________________________________________________
instr 175                                       ; general wavetable wind instrument with spatialization
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
; p11 initial panning position (1 is full left, 0 is full right, and .5 is center)
; p12 intermediate panning  position (1 is full left, 0 is full right, and .5 is center)
; p13 ending panning position (1 is full left, 0 is full right, and .5 is center)
; p14 percent duration of change from initial panning position to intermediate panning position
;         (e.g., .5 means make the first change over half the note's duration)
; p15 initial reverb time
; p16 intermediate reverb time
; p17 final reverb time
; p18 % of reverb relative to source signal at start of note
; p19 % of reverb relative to source signal at middle of note (intermediate position)
; p20 % of reverb relative to source signal at end of note
; p21 gain to control the final amplitude of the signal
; p22 amplitude scaler for echos (amount each echo is attenuated)
; p23 echo time (should be greater than 40ms to be heard as a discrete echo)
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
ileft1    =       p11                                       ; initial position for pan - percent left channel
ileft2    =       p12                                       ; second position for pan - percent left channel
ileft3    =       p13                                       ; ending position for pan - percent left channel
ileft1    =       (ileft1 <= 0 ? .01 : ileft1)
ileft1    =       (ileft1 >= 1 ? .99 : ileft1)
ileft2    =       (ileft2 <= 0 ? .01 : ileft2)
ileft2    =       (ileft2 >= 1 ? .99 : ileft2)
ileft3    =       (ileft3 <= 0 ? .01 : ileft3)
ileft3    =       (ileft3 >= 1 ? .99 : ileft3)
iright1   =       1 - ileft1                                ; initial position for pan - percent right channel
iright2   =       1 - ileft2                                ; second position for pan - percent right channel
iright3   =       1 - ileft3                                ; ending position for pan - percent right channel
p14       =       (p14 <= 0 ? .01 : p14)                    ; keep values between 0 and 1
p14       =       (p14 >= 1 ? .99 : p14)
itime1    =       p14 * idur                                ; time for first panning/rev segment
itime2    =       idur - itime1                             ; time for second panning/rev segment

irevtime1 =       p15                                       ; set first duration of reverb time
irevtime2 =       p16                                       ; set middle duration of reverb time
irevtime3 =       p17                                       ; set final duration of reverb time
irev1     =       p18                                       ; first percent for reverberated signal
irev2     =       p19                                       ; middle percent for reverberated signal
irev3     =       p20                                       ; last percent for reverberated signal
iattn     =       p21                                       ; attenuation
irev1     =       (irev1 <= 0 ? .01 : irev1)                ; keep values between 0 and 1
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

ifeedback =       p22                                       ; echo amplitude scale
iecho     =       p23                                       ; echo time
p3        =       p3 + iecho*log(.0001)/log(ifeedback)      ; also extend duration to avoid echo cutoff


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
;___________________________________________________________; spatialization
reverb:
apercent  linseg  irev1, itime1, irev2, itime2, irev3, 1, irev3                 ; percent reverb
aunreverb linseg  iunrev1, itime1, iunrev2, itime2, iunrev3, 1, iunrev3         ; remaining percent
krevtime  linseg  irevtime1, itime1, irevtime2, itime2, irevtime3, 1, irevtime3 ; reverb time
ac1       comb    asig, krevtime, .0297
ac2       comb    asig, krevtime, .0371
ac3       comb    asig, krevtime, .0411
ac4       comb    asig, krevtime, .0437
acomb     =       ac1 + ac2 + ac3 + ac4
ap1       alpass  acomb, .09683, .005
arev      alpass  ap1, .03292, .0017
asig      =       (aunreverb * asig) + (apercent * arev)    ; mix the signal

echo:
ainput    =       asig                                      ; set ainput to original signal
adelay    delayr  iecho
                  ; add any custom feedback modifications (e.g. lowpass filtering) to adelay here
asource   =       ainput + ifeedback*adelay
          delayw  asource 
asig      =       asig + adelay                             ; add echo signal
asig      =       asig * iattn                              ; attenuation

panning:
apanl     linseg  ileft1, itime1, ileft2, itime2, ileft3, 1, ileft3     ; amplitude envelope for left channel
apanr     linseg  iright1, itime1, iright2, itime2, iright3, 1, iright3 ; amplitude envelope for right channel
apanl     =       sqrt(apanl)
apanr     =       sqrt(apanr)
asigl     =       apanl * asig                              ; signal for left channel
asigr     =       apanr * asig                              ; signal for right channel

          outs    asigl, asigr                              ; output stereo signal
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; spatnote.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific spatialization example (with bassoon)
; Stravinsky - The Rite of Spring - opening bassoon solo

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f93 0 16384 -17 0 0 86 1 129 2 194 3 291 4 436 5                              ; bassoon wavetables
f94 0 64 -2 95 96 97 11.900 98 99 100 18.823 101 102 103 18.635 104 105 106 5.404 107 108 109 5.624 110 111 4 2.081
f95 0 4097 -9 2 1.339 0 3 1.324 0 
f96 0 4097 -9 4 1.567 0 5 1.602 0 6 1.777 0 7 1.143 0 
f97 0 4097 -9 8 0.746 0 9 1.231 0 10 1.618 0 11 0.823 0 12 0.572 0 13 0.282 0 14 0.421 0 15 0.419 0 16 0.470 0 17 0.126 0 18 0.722 0 19 0.609 0 20 0.402 0 21 0.273 0 22 0.272 0 23 0.351 0 24 0.152 0 25 0.087 0 26 0.067 0 27 0.189 0 28 0.172 0 29 0.227 0 30 0.152 0 31 0.114 0 32 0.060 0 33 0.059 0 34 0.069 0 35 0.084 0 36 0.073 0 37 0.054 0 38 0.025 0 39 0.038 0 40 0.070 0 41 0.064 0 42 0.055 0 43 0.032 0 44 0.027 0 45 0.051 0 46 0.034 0 47 0.041 0 48 0.056 0 49 0.026 0 53 0.024 0  
f98 0 4097 -9 2 1.348 0 3 2.896 0 
f99 0 4097 -9 4 4.100 0 5 6.159 0 6 3.342 0 7 0.109 0 
f100 0 4097 -9 8 1.577 0 9 0.756 0 10 0.745 0 11 0.781 0 12 1.175 0 13 1.204 0 14 0.572 0 15 1.003 0 16 0.430 0 17 0.166 0 18 0.488 0 19 0.212 0 20 0.142 0 21 0.077 0 22 0.047 0 23 0.059 0 24 0.094 0 25 0.048 0 26 0.041 0 27 0.035 0 28 0.022 0 29 0.062 0 30 0.167 0 31 0.200 0 32 0.100 0 33 0.037 0 34 0.023 0 36 0.061 0 37 0.030 0 38 0.100 0 39 0.125 0 40 0.098 0 41 0.053 0 42 0.073 0 43 0.073 0 44 0.063 0 45 0.046 0 47 0.030 0 48 0.042 0 
f101 0 4097 -9 2 6.037 0 3 6.737 0 
f102 0 4097 -9 4 6.752 0 5 1.300 0 6 0.536 0 7 0.339 0 
f103 0 4097 -9 8 1.719 0 9 1.347 0 10 0.866 0 11 0.753 0 12 0.238 0 13 0.346 0 14 0.169 0 15 0.190 0 16 0.063 0 17 0.084 0 18 0.258 0 19 0.181 0 20 0.076 0 21 0.069 0 22 0.087 0 23 0.085 0 24 0.116 0 25 0.107 0 26 0.195 0 27 0.096 0 28 0.086 0 29 0.093 0 30 0.036 0 31 0.074 0 32 0.052 0 33 0.052 0 34 0.040 0 35 0.046 0 36 0.039 0 
f104 0 4097 -9 2 3.912 0 3 1.245 0 
f105 0 4097 -9 4 0.301 0 5 0.537 0 6 0.827 0 7 0.161 0 
f106 0 4097 -9 8 0.258 0 9 0.205 0 10 0.129 0 11 0.060 0 12 0.080 0 13 0.131 0 14 0.094 0 15 0.054 0 16 0.057 0 17 0.061 0 18 0.054 0 19 0.026 0 20 0.021 0 21 0.024 0 22 0.024 0 
f107 0 4097 -9 2 4.071 0 3 1.026 0 
f108 0 4097 -9 4 0.618 0 5 0.186 0 6 0.153 0 7 0.026 0 
f109 0 4097 -9 8 0.056 0 9 0.070 0 10 0.040 0 11 0.026 0 12 0.026 0 
f110 0 4097 -9 2 0.759 0 3 0.568 0 
f111 0 4097 -9 4 0.374 0 5 0.052 0 

;p1  p2     p3    p4    p5      p6    p7    p8   p9 10 p11  p12   p13   p14   p15   p16   p17   p18   p19   p20   p21   p22   p23
;    start  dur   amp   Hertz   vibr  att   dec  br in pan1 pan2  pan3  dur1  rtim1 rtim2 rtim3 %rev1 %rev2 %rev3 attn  eamp  etime
;bar 1-----------------------------------------------------------------------------------------------------------------------------
i175  1.000 3.200 10000 523.200 1.000 0.040 0.350 9 7 0.217 0.480 0.704 0.800 0.091 0.441 0.927 0.123 0.290 0.443 0.600 0.415 0.231
i175  4.100 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.274 0.276 0.039 0.524 0.541 0.444 0.838 0.359 0.307 0.310 0.600 0.528 0.250
i175  4.200 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.425 0.679 0.140 0.064 0.960 0.708 0.243 0.284 0.280 0.853 0.600 0.485 0.186
i175  4.300 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.137 0.721 0.833 0.752 0.682 0.107 0.380 0.960 0.382 0.440 0.600 0.419 0.209
i175  4.500 0.350 10000 392.400 1.000 0.040 0.100 9 7 0.262 0.041 0.145 0.442 0.873 0.570 0.973 0.745 0.915 0.652 0.600 0.527 0.264
i175  4.750 0.400 10000 327.000 1.000 0.040 0.100 9 7 0.183 0.612 0.402 0.869 0.681 0.539 0.941 0.983 0.900 0.332 0.600 0.468 0.263
i175  5.050 0.450 10000 490.500 1.000 0.040 0.100 9 7 0.353 0.941 0.209 0.472 0.580 0.822 0.964 0.455 0.243 0.038 0.600 0.486 0.221
i175  5.400 2.250 10000 436.000 1.000 0.040 0.100 9 7 0.330 0.019 0.976 0.609 0.965 0.158 0.573 0.837 0.628 0.673 0.600 0.517 0.234
i175  7.550 0.450 10000 523.200 1.000 0.040 0.100 9 7 0.546 0.292 0.736 0.615 0.337 0.440 0.155 0.305 0.693 0.756 0.600 0.525 0.231
i175  7.900 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.832 0.513 0.807 0.019 0.417 0.489 0.937 0.452 0.459 0.413 0.600 0.420 0.188
i175  8.000 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.631 0.273 0.523 0.148 0.390 0.069 0.591 0.607 0.785 0.157 0.600 0.540 0.192
i175  8.100 0.400 10000 490.500 1.000 0.040 0.100 9 7 0.630 0.226 0.892 0.455 0.388 0.724 0.819 0.846 0.562 0.545 0.600 0.529 0.247
i175  8.400 0.450 10000 392.400 1.000 0.040 0.100 9 7 0.835 0.182 0.879 0.307 0.801 0.509 0.480 0.745 0.188 0.081 0.600 0.550 0.218
i175  8.750 0.450 10000 327.000 1.000 0.040 0.100 9 7 0.081 0.029 0.316 0.173 0.852 0.945 0.799 0.855 0.531 0.548 0.600 0.420 0.204
i175  9.100 0.500 10000 490.500 1.000 0.040 0.100 9 7 0.811 0.656 0.821 0.340 0.985 0.007 0.274 0.765 0.863 0.256 0.600 0.443 0.269
;bar 2-----------------------------------------------------------------------------------------------------------------------------
i175  9.500 0.900 10000 436.000 1.000 0.040 0.100 9 7 0.877 0.239 0.128 0.098 0.025 0.291 0.305 0.777 0.132 0.389 0.600 0.454 0.225
i175 10.300 0.500 10000 523.200 1.000 0.040 0.150 9 7 0.416 0.080 0.930 0.759 0.532 0.164 0.075 0.828 0.128 0.868 0.600 0.560 0.238
i175 10.700 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.607 0.376 0.047 0.360 0.686 0.924 0.250 0.696 0.223 0.315 0.600 0.428 0.240
i175 10.800 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.189 0.869 0.674 0.244 0.724 0.089 0.923 0.094 0.517 0.694 0.600 0.572 0.252
i175 10.900 0.600 10000 490.500 1.000 0.040 0.100 9 7 0.965 0.711 0.291 0.225 0.131 0.249 0.852 0.827 0.229 0.350 0.600 0.557 0.176
i175 11.400 0.600 10000 436.000 1.000 0.040 0.150 9 7 0.376 0.432 0.214 0.004 0.255 0.402 0.825 0.618 0.465 0.868 0.600 0.519 0.170
i175 11.900 0.550 10000 588.600 1.000 0.040 0.300 9 7 0.266 0.325 0.370 0.839 0.208 0.334 0.301 0.770 0.960 0.733 0.600 0.412 0.180
i175 12.350 0.250 10000 392.400 1.000 0.040 0.100 9 7 0.358 0.902 0.115 0.716 0.308 0.490 0.299 0.111 0.386 0.925 0.600 0.469 0.253
i175 12.500 0.700 10000 436.000 1.000 0.040 0.150 9 7 0.519 0.169 0.551 0.190 0.722 0.169 0.715 0.261 0.899 0.354 0.600 0.458 0.192
;bar 3-----------------------------------------------------------------------------------------------------------------------------
i175 13.100 0.400 10000 523.200 1.000 0.040 0.100 9 7 0.256 0.352 0.009 0.477 0.535 0.879 0.045 0.918 0.839 0.268 0.600 0.582 0.229
i175 13.400 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.716 0.256 0.687 0.826 0.730 0.623 0.318 0.621 0.344 0.180 0.600 0.477 0.258
i175 13.500 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.378 0.691 0.599 0.525 0.425 0.854 0.528 0.425 0.720 0.542 0.600 0.525 0.220
i175 13.600 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.284 0.596 0.808 0.866 0.155 0.523 0.873 0.662 0.418 0.692 0.600 0.564 0.171
i175 13.800 0.300 10000 392.400 1.000 0.040 0.100 9 7 0.091 0.137 0.484 0.320 0.277 0.213 0.611 0.055 0.577 0.765 0.600 0.515 0.189
i175 14.000 0.300 10000 327.000 1.000 0.040 0.100 9 7 0.161 0.978 0.835 0.838 0.180 0.118 0.233 0.078 0.965 0.180 0.600 0.406 0.250
i175 14.200 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.510 0.208 0.748 0.126 0.461 0.839 0.314 0.666 0.128 0.920 0.600 0.567 0.185
i175 14.400 4.400 10000 436.000 1.000 0.040 0.350 9 7 0.897 0.755 0.247 0.613 0.926 0.759 0.142 0.950 0.107 0.311 0.600 0.580 0.177
i175 18.800 2.700 10000 523.200 1.000 0.040 0.100 9 7 0.963 0.720 0.170 0.269 0.652 0.679 0.128 0.810 0.156 0.298 0.600 0.569 0.253
;bar 4-----------------------------------------------------------------------------------------------------------------------------
i175 21.400 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.680 0.914 0.733 0.460 0.573 0.695 0.732 0.432 0.215 0.303 0.600 0.541 0.251
i175 21.500 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.628 0.681 0.019 0.397 0.564 0.366 0.907 0.637 0.132 0.943 0.600 0.451 0.227
i175 21.600 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.398 0.997 0.641 0.643 0.853 0.672 0.256 0.185 0.913 0.180 0.600 0.413 0.191
i175 21.800 0.300 10000 392.400 1.000 0.040 0.100 9 7 0.597 0.797 0.045 0.238 0.578 0.672 0.018 0.559 0.570 0.914 0.600 0.526 0.261
i175 22.000 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.449 0.911 0.538 0.700 0.620 0.288 0.048 0.862 0.820 0.010 0.600 0.436 0.205
i175 22.200 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.318 0.416 0.818 0.131 0.689 0.414 0.879 0.716 0.393 0.317 0.600 0.471 0.226
i175 22.300 0.400 10000 470.080 1.000 0.040 0.100 9 7 0.929 0.757 0.774 0.707 0.349 0.222 0.269 0.296 0.353 0.941 0.600 0.519 0.221
;bar 5-----------------------------------------------------------------------------------------------------------------------------
i175 22.600 0.400 10000 436.000 1.000 0.040 0.100 9 7 0.794 0.573 0.096 0.765 0.681 0.024 0.022 0.554 0.772 0.242 0.600 0.449 0.228
i175 22.900 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.947 0.242 0.484 0.418 0.094 0.989 0.188 0.842 0.763 0.285 0.600 0.543 0.240
i175 23.000 0.300 10000 470.080 1.000 0.040 0.100 9 7 0.324 0.493 0.210 0.840 0.480 0.355 0.012 0.657 0.869 0.624 0.600 0.591 0.266
i175 23.200 0.450 10000 436.000 1.000 0.040 0.100 9 7 0.683 0.065 0.523 0.384 0.024 0.821 0.926 0.477 0.018 0.011 0.600 0.576 0.171
i175 23.550 0.650 10000 372.053 1.000 0.040 0.100 9 7 0.929 0.273 0.740 0.624 0.143 0.063 0.069 0.584 0.623 0.718 0.600 0.465 0.243
i175 24.100 0.800 10000 523.200 1.000 0.040 0.350 9 7 0.029 0.910 0.775 0.772 0.758 0.809 0.437 0.031 0.152 0.312 0.600 0.416 0.187
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
