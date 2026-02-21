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
; pannote.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific stereo panning example (with tuba)
; Berlioz - Symphony Fantastique, ending of last movememnt 

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f311 0 16384 -17 0 0 68 1 90 2 121 3 161 4 216 5                              ; tuba wavetables
f312 0 64 -2 313 314 315 13.556 316 317 318 13.193 319 320 321 2.961 322 323 324 2.392 325 326 4 2.348 327 328 4 1.266
f313 0 4097 -9 2 2.638 0 3 1.176 0 
f314 0 4097 -9 4 3.122 0 5 1.523 0 6 2.396 0 7 1.547 0 
f315 0 4097 -9 8 1.347 0 9 1.330 0 10 0.766 0 11 0.739 0 12 0.451 0 13 0.387 0 14 0.388 0 15 0.393 0 16 0.298 0 17 0.232 0 18 0.172 0 19 0.152 0 20 0.077 0 21 0.063 0 22 0.097 0 23 0.039 0 
f316 0 4097 -9 2 3.183 0 3 3.822 0 
f317 0 4097 -9 4 2.992 0 5 2.243 0 6 1.999 0 7 1.053 0 
f318 0 4097 -9 8 0.742 0 9 0.501 0 10 0.377 0 11 0.369 0 12 0.288 0 13 0.288 0 14 0.216 0 15 0.130 0 16 0.105 0 17 0.069 0 18 0.021 0 
f319 0 4097 -9 2 0.685 0 3 0.741 0 
f320 0 4097 -9 4 0.791 0 5 0.395 0 6 0.327 0 7 0.175 0 
f321 0 4097 -9 8 0.105 0 9 0.102 0 10 0.074 0 11 0.063 0 12 0.034 0 
f322 0 4097 -9 2 0.329 0 3 0.939 0 
f323 0 4097 -9 4 0.593 0 5 0.240 0 6 0.100 0 7 0.095 0 
f324 0 4097 -9 8 0.082 0 9 0.028 0 
f325 0 4097 -9 2 1.072 0 3 0.537 0 
f326 0 4097 -9 4 0.351 0 5 0.185 0 6 0.054 0 7 0.024 0 
f327 0 4097 -9 2 0.448 0 3 0.183 0 
f328 0 4097 -9 4 0.087 0 5 0.028 0 

t0 414
;p1  p2     p3    p4    p5      p6    p7    p8   p9 10 p11   p12   p13   p14
;    start  dur   amp   Hertz   vibr  att   dec  br in pan1  pan2  pan3  dur1
;bar 516----------------------------------------------------------------------
i173  1.000 0.800 10000  65.400 0.500 0.040 0.040 9 18 0.053 0.914 0.827 0.602
i173  2.000 0.800  6700 130.800 0.500 0.040 0.040 9 18 0.631 0.785 0.230 0.511
i173  3.000 0.800  7900 122.625 0.500 0.040 0.040 9 18 0.567 0.350 0.307 0.239
i173  4.000 0.800  8600 117.520 0.500 0.040 0.040 9 18 0.929 0.216 0.479 0.703
i173  5.000 0.800  7300 109.000 0.500 0.040 0.040 9 18 0.699 0.090 0.440 0.626
i173  6.000 0.800  8500 104.640 0.500 0.040 0.040 9 18 0.032 0.329 0.682 0.664
;bar 517----------------------------------------------------------------------
i173  7.000 6.000 11200  98.100 0.100 0.040 0.100 9 18 0.615 0.961 0.273 0.575
;bar 518----------------------------------------------------------------------
i173 13.000 0.800 11400  65.400 0.500 0.040 0.040 9 18 0.038 0.923 0.540 0.243
i173 14.000 0.800  8100 130.800 0.500 0.040 0.040 9 18 0.837 0.368 0.746 0.669
i173 15.000 0.800  9300 122.625 0.500 0.040 0.040 9 18 0.505 0.328 0.480 0.724
i173 16.000 0.800 10000 117.520 0.500 0.040 0.040 9 18 0.678 0.139 0.763 0.659
i173 17.000 0.800  8700 109.000 0.500 0.040 0.040 9 18 0.707 0.242 0.663 0.459
i173 18.000 0.800  9900 104.640 0.500 0.040 0.040 9 18 0.332 0.455 0.685 0.216
;bar 519----------------------------------------------------------------------
i173 19.000 6.000 12600  98.100 0.100 0.040 0.100 9 18 0.136 0.720 0.832 0.751
;bar 520----------------------------------------------------------------------
i173 25.000 0.850 12800  65.400 0.500 0.040 0.040 9 18 0.681 0.106 0.379 0.419
i173 26.000 0.800  9500  81.750 0.500 0.040 0.040 9 18 0.381 0.919 0.163 0.419
i173 27.000 0.800 10700  87.200 0.500 0.040 0.040 9 18 0.639 0.261 0.040 0.344
i173 28.000 0.800 11400  98.100 0.500 0.040 0.040 9 18 0.941 0.872 0.569 0.172
i173 29.000 0.800 10100 109.000 0.500 0.040 0.040 9 18 0.364 0.684 0.931 0.223
i173 30.000 0.800 11300 122.625 0.500 0.040 0.040 9 18 0.927 0.594 0.182 0.411
;bar 521----------------------------------------------------------------------
i173 31.000 0.800 14000 130.800 0.500 0.040 0.040 9 18 0.401 0.868 0.680 0.238
i173 32.000 0.800 10700  98.100 0.500 0.040 0.040 9 18 0.940 0.512 0.289 0.421
i173 33.000 0.800 11900  81.750 0.500 0.040 0.040 9 18 0.970 0.668 0.693 0.052
i173 34.000 0.850 12600  65.400 0.500 0.040 0.040 9 18 0.940 0.208 0.571 0.379
i173 35.000 0.800 11300  81.750 0.500 0.040 0.040 9 18 0.821 0.963 0.724 0.062
i173 36.000 0.800 12500  98.100 0.500 0.040 0.040 9 18 0.187 0.645 0.086 0.151
;bar 522----------------------------------------------------------------------
i173 37.000 0.800 15200 130.800 0.500 0.040 0.040 9 18 0.329 0.018 0.975 0.608
i173 38.000 0.800 11900  98.100 0.500 0.040 0.040 9 18 0.964 0.157 0.572 0.566
i173 39.000 0.800 12800  81.750 0.500 0.040 0.040 9 18 0.377 0.252 0.904 0.517
i173 40.000 0.850 13800  65.400 0.500 0.040 0.040 9 18 0.764 0.545 0.291 0.335
i173 41.000 0.800 12500  81.750 0.500 0.040 0.040 9 18 0.214 0.336 0.439 0.054
i173 42.000 0.800 13700  98.100 0.500 0.040 0.040 9 18 0.544 0.362 0.085 0.517
;bar 523----------------------------------------------------------------------
i173 43.000 0.800 16400 130.800 0.500 0.040 0.040 9 18 0.325 0.161 0.831 0.412
i173 44.000 0.800 13100  98.100 0.500 0.040 0.040 9 18 0.806 0.918 0.416 0.788
i173 45.000 0.800 14300  81.750 0.500 0.040 0.040 9 18 0.936 0.391 0.448 0.052
i173 46.000 0.850 15000  65.400 0.500 0.040 0.040 9 18 0.900 0.020 0.618 0.530
i173 47.000 0.800 13700  81.750 0.500 0.040 0.040 9 18 0.272 0.522 0.947 0.489
i173 48.000 0.800 14900  98.100 0.500 0.040 0.040 9 18 0.068 0.590 0.476 0.334
;bar 524----------------------------------------------------------------------
i173 49.000 9.000 17600 130.800 0.100 0.040 0.300 9 18 0.926 0.267 0.140 0.422

;stereo reverb----------------------------------------------------------------
;p1  p2    p3  p4      p5      p6
;    start dur revtime %reverb gain
i197 0.5   59  1.5     .05     1.0
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
