<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; pannote.orc (in the noteffct subdirectory on the CD-ROM)

; instr 173 - general wavetable wind instrument with stereo panning on each note
; instr 197 - stereo global reverb


giseed    =       .5
giwtsin   =       1
garevl    init    0
garevr    init    0
;______________________________________________________________________________________________________
instr 173                                                    ; general wind instrument with stereo panning
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
ipan1     =       p14 * idur                                ; time for first panning segment
ipan2     =       idur - ipan1                              ; time for second panning segment

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
;___________________________________________________________; stereo panning
apanl     linseg  ileft1, ipan1, ileft2, ipan2, ileft3, 1, ileft3      ; amplitude envelope for left channel
apanr     linseg  iright1, ipan1, iright2, ipan2, iright3, 1, iright3  ; amplitude envelope for right channel
apanl     =       sqrt(apanl)
apanr     =       sqrt(apanr)
asigl     =       apanl * asig                              ; signal for left channel
asigr     =       apanr * asig                              ; signal for right channel
garevl    =       asigl + garevl                            ; send signals to global stereo reverb
garevr    =       asigr + garevr
;         outs    asigl, asigr                              ; DO NOT OUTPUT signals
          endin
;______________________________________________________________________________________________________
instr 197                                                   ; global stereo reverb instrument
; parameters
; p4 reverb time				
; p5 % of reverb relative to source signal
; p6 gain to control the final amplitude of the signal

idur      =       p3
irevtime  =       p4                                        ; set duration of reverb time
ireverb   =       p5                                        ; percent for reverberated signal
igain     =       p6                                        ; gain for the final signal amplitude
ireverb   =       (ireverb > .99 ? .99 : ireverb)           ; check limit
ireverb   =       (ireverb < 0 ? 0 : ireverb)               ; check limit
iacoustic =       1 - ireverb                               ; percent for acoustic signal
p3        =       p3 + irevtime + .1                        ; lengthen p3 to include reverb time	

left:
acl1      comb    garevl, irevtime, .0297                   ; reverberate the left global signal
acl2      comb    garevl, irevtime, .0371
acl3      comb    garevl, irevtime, .0411
acl4      comb    garevl, irevtime, .0437
acombl    =       acl1 + acl2 + acl3 + acl4
apl       alpass  acombl, .09683, .005
arevl     alpass  apl, 03292, .0017
asigl     =       (iacoustic * garevl) + (ireverb * arevl)  ; mix the left signal

right:
acr1      comb    garevr, irevtime, .0297                   ; reverberate the right global signal
acr2      comb    garevr, irevtime, .0371
acr3      comb    garevr, irevtime, .0411
acr4      comb    garevr, irevtime, .0437
acombr    =       acr1 + acr2 + acr3 + acr4
apr       alpass  acombr, .09683, .005
arevr     alpass  apr, 03292, .0017
asigr     =       (iacoustic * garevr) + (ireverb * arevr)  ; mix the right signal

          outs    asigl * igain, asigr * igain              ; attenuate and output the stereo signal
garevl    =       0                                         ; set garevs to 0 to prevent feedback
garevr    =       0
          endin
;______________________________________________________________________________________________________


</CsInstruments>
<CsScore>
; pannote2.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific stereo panning example (with bassoon)
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

;p1  p2     p3    p4    p5      p6    p7    p8   p9 10 p11  p12   p13   p14
;    start  dur   amp   Hertz   vibr  att   dec  br in pan1 pan2  pan3  dur1
;bar 1-----------------------------------------------------------------------
i173  1.000 3.200 10000 523.200 1.000 0.040 0.350 9 7 0.053 0.914 0.827 0.602
i173  4.100 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.631 0.785 0.230 0.511
i173  4.200 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.567 0.350 0.307 0.239
i173  4.300 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.929 0.216 0.479 0.703
i173  4.500 0.350 10000 392.400 1.000 0.040 0.100 9 7 0.699 0.090 0.440 0.626
i173  4.750 0.400 10000 327.000 1.000 0.040 0.100 9 7 0.032 0.329 0.682 0.664
i173  5.050 0.450 10000 490.500 1.000 0.040 0.100 9 7 0.615 0.961 0.273 0.575
i173  5.400 2.250 10000 436.000 1.000 0.040 0.100 9 7 0.038 0.923 0.540 0.243
i173  7.550 0.450 10000 523.200 1.000 0.040 0.100 9 7 0.837 0.368 0.746 0.669
i173  7.900 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.505 0.328 0.480 0.724
i173  8.000 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.678 0.139 0.763 0.659
i173  8.100 0.400 10000 490.500 1.000 0.040 0.100 9 7 0.707 0.242 0.663 0.459
i173  8.400 0.450 10000 392.400 1.000 0.040 0.100 9 7 0.332 0.455 0.685 0.216
i173  8.750 0.450 10000 327.000 1.000 0.040 0.100 9 7 0.136 0.720 0.832 0.751
i173  9.100 0.500 10000 490.500 1.000 0.040 0.100 9 7 0.681 0.106 0.379 0.419
;bar 2-----------------------------------------------------------------------
i173  9.500 0.900 10000 436.000 1.000 0.040 0.100 9 7 0.381 0.919 0.163 0.419
i173 10.300 0.500 10000 523.200 1.000 0.040 0.150 9 7 0.639 0.261 0.040 0.344
i173 10.700 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.941 0.872 0.569 0.172
i173 10.800 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.364 0.684 0.931 0.223
i173 10.900 0.600 10000 490.500 1.000 0.040 0.100 9 7 0.927 0.594 0.182 0.411
i173 11.400 0.600 10000 436.000 1.000 0.040 0.150 9 7 0.401 0.868 0.680 0.238
i173 11.900 0.550 10000 588.600 1.000 0.040 0.300 9 7 0.940 0.512 0.289 0.421
i173 12.350 0.250 10000 392.400 1.000 0.040 0.100 9 7 0.970 0.668 0.693 0.052
i173 12.500 0.700 10000 436.000 1.000 0.040 0.150 9 7 0.940 0.208 0.571 0.379
;bar 3-----------------------------------------------------------------------
i173 13.100 0.400 10000 523.200 1.000 0.040 0.100 9 7 0.821 0.963 0.724 0.062
i173 13.400 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.187 0.645 0.086 0.151
i173 13.500 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.329 0.018 0.975 0.608
i173 13.600 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.964 0.157 0.572 0.566
i173 13.800 0.300 10000 392.400 1.000 0.040 0.100 9 7 0.377 0.252 0.904 0.517
i173 14.000 0.300 10000 327.000 1.000 0.040 0.100 9 7 0.764 0.545 0.291 0.335
i173 14.200 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.214 0.336 0.439 0.054
i173 14.400 4.400 10000 436.000 1.000 0.040 0.350 9 7 0.544 0.362 0.085 0.517
i173 18.800 2.700 10000 523.200 1.000 0.040 0.100 9 7 0.325 0.161 0.831 0.412
;bar 4-----------------------------------------------------------------------
i173 21.400 0.200 10000 490.500 1.000 0.030 0.040 9 7 0.806 0.918 0.416 0.788
i173 21.500 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.936 0.391 0.448 0.052
i173 21.600 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.900 0.020 0.618 0.530
i173 21.800 0.300 10000 392.400 1.000 0.040 0.100 9 7 0.272 0.522 0.947 0.489
i173 22.000 0.300 10000 490.500 1.000 0.040 0.100 9 7 0.068 0.590 0.476 0.334
i173 22.200 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.926 0.267 0.140 0.422
i173 22.300 0.400 10000 470.080 1.000 0.040 0.100 9 7 0.053 0.914 0.827 0.602
;bar 5-----------------------------------------------------------------------
i173 22.600 0.400 10000 436.000 1.000 0.040 0.100 9 7 0.631 0.785 0.230 0.511
i173 22.900 0.200 10000 523.200 1.000 0.030 0.040 9 7 0.567 0.350 0.307 0.239
i173 23.000 0.300 10000 470.080 1.000 0.040 0.100 9 7 0.929 0.216 0.479 0.703
i173 23.200 0.450 10000 436.000 1.000 0.040 0.100 9 7 0.699 0.090 0.440 0.626
i173 23.550 0.650 10000 372.053 1.000 0.040 0.100 9 7 0.032 0.329 0.682 0.664
i173 24.100 0.800 10000 523.200 1.000 0.040 0.350 9 7 0.615 0.961 0.273 0.575

;stereo reverb---------------------------------------------------------------
;p1  p2    p3  p4      p5      p6
;    start dur revtime %reverb gain
i197 0.5   25  1.0     .05     1.0
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
