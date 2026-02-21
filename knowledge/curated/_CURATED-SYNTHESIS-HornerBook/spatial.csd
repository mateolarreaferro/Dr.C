<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; spatial.orc (in the global subdirectory on the CD-ROM)

; instr 98 - general wavetable wind instrument going to spatialization
; instr 198 - global spatialization (reverb & stereo panning)


giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
instr 98                                                    ; general wind instrument going to spatialization
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
garev     =       garev + asig                              ; send signal to global spatialization
;         out     asig                                      ; DO NOT OUTPUT asig
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
; spatial.sco (in the global subdirectory on the CD-ROM)
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
i98    1.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i98    1.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i98    2.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i98    2.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i98    3.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i98    3.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i98    3.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i98    4.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i98    4.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
;bar 2---------------------------------------------------------------------------------
i98    5.000   0.550  10000   392.400   0.700   0.045   0.150   9   3
i98    5.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i98    5.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i98    6.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i98    6.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
i98    7.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i98    7.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i98    7.500   1.050   7200   418.560   0.700   0.045   0.150   9   3
i98    8.500   0.300   7200   392.400   0.700   0.045   0.150   9   3
i98    8.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 3 (upper)-------------------------------------------------------------------------
i98    9.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i98    9.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i98   10.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i98   10.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i98   11.000   0.550   9000   627.840   0.700   0.045   0.150   9   3
i98   11.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i98   11.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i98   12.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i98   12.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
;bar 3 (lower)--------------------------------------------------------------------------
i98    9.000   0.300  10000   313.920   0.700   0.045   0.150   9   3
i98    9.250   0.300   6500   523.200   0.700   0.045   0.150   9   3
i98    9.500   0.300   7200   490.500   0.700   0.045   0.150   9   3
i98    9.750   0.300   6500   436.000   0.700   0.045   0.150   9   3
i98   10.000   0.300   8100   392.400   0.700   0.045   0.150   9   3
i98   10.250   0.300   6500   348.800   0.700   0.045   0.150   9   3
i98   10.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i98   10.750   0.300   6500   294.300   0.700   0.045   0.150   9   3
i98   11.000   0.550   9000   261.600   0.700   0.045   0.150   9   3
i98   11.500   0.550   7200   627.840   0.700   0.045   0.150   9   3
i98   12.000   0.550   8100   588.600   0.700   0.045   0.150   9   3
i98   12.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
;bar 4 (upper)-------------------------------------------------------------------------
i98   13.000   0.550  10000   588.600   0.700   0.045   0.150   9   3
i98   13.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i98   13.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i98   14.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i98   14.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
i98   15.000   0.300   9000   523.200   0.700   0.045   0.150   9   3
i98   15.250   0.300   6500   588.600   0.700   0.045   0.150   9   3
i98   15.500   1.050   8100   627.840   0.700   0.045   0.150   9   3
i98   16.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i98   16.750   0.300   6500   523.200   0.700   0.045   0.150   9   3
;bar 4 (lower)-------------------------------------------------------------------------
i98   13.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i98   13.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
i98   14.000   0.550   8100   470.080   0.700   0.045   0.150   9   3
i98   14.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i98   15.000   0.550   9000   372.053   0.700   0.045   0.150   9   3
i98   15.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i98   16.000   0.550   8100   436.000   0.700   0.045   0.150   9   3
i98   16.500   0.550   7200   372.053   0.700   0.045   0.150   9   3
;bar 5 (upper)-------------------------------------------------------------------------
i98   17.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i98   17.500   0.300   7200   627.840   0.700   0.045   0.150   9   3
i98   17.750   0.300   6500   588.600   0.700   0.045   0.150   9   3
i98   18.000   0.550   8100   627.840   0.700   0.045   0.150   9   3
i98   18.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i98   19.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i98   19.500   0.300   7200   697.600   0.700   0.045   0.150   9   3
i98   19.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i98   20.000   0.550   8100   697.600   0.700   0.045   0.150   9   3
i98   20.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
;bar 5 (lower)-------------------------------------------------------------------------
i98   17.000   1.050  10000   392.400   0.700   0.045   0.150   9   3
i98   18.250   0.300   6500   261.600   0.700   0.045   0.150   9   3
i98   18.500   0.300   7200   294.300   0.700   0.045   0.150   9   3
i98   18.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i98   19.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i98   19.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i98   19.500   0.800   7200   418.560   0.700   0.045   0.150   9   3
i98   20.250   0.300   6500   294.300   0.700   0.045   0.150   9   3
i98   20.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i98   20.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 6 (upper)-------------------------------------------------------------------------
i98   21.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i98   21.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i98   21.750   0.300   6500   697.600   0.700   0.045   0.150   9   3
i98   22.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i98   22.500   0.550   7200   490.500   0.700   0.045   0.150   9   3
i98   23.000   0.550   9000   523.200   0.700   0.045   0.150   9   3
i98   23.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i98   23.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i98   24.000   2.050   8100   697.600   0.700   0.045   0.150   9   3
;bar 6 (lower)-------------------------------------------------------------------------
i98   21.000   0.300  10000   392.400   0.700   0.045   0.150   9   3
i98   21.250   0.300   6500   436.000   0.700   0.045   0.150   9   3
i98   21.500   0.800   7200   470.080   0.700   0.045   0.150   9   3
i98   22.250   0.300   6500   313.920   0.700   0.045   0.150   9   3
i98   22.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i98   22.750   0.300   6500   392.400   0.700   0.045   0.150   9   3
i98   23.000   0.300   9000   418.560   0.700   0.045   0.150   9   3
i98   23.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i98   23.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i98   23.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i98   24.000   0.550   8100   294.300   0.700   0.045   0.150   9   3
i98   24.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i98   24.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
;bar 7 (lower)-------------------------------------------------------------------------
i98   25.000   1.050  10000   523.200   0.700   0.045   0.150   9   3

;spatial (stereo and reverb)-----------------------------------------------------------
;p1   p2    p3    p4   p5   p6   p7   p8       p9       p10      p11   p12   p13   p14
;     start dur   pan1 pan2 pan3 dur1 revtime1 revtime2 revtime3 %rev1 %rev2 %rev3 gain
i198  1.5   24.6  1    0    1    .5   .05      1.5      .5       .01   .5    .01   .5
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
