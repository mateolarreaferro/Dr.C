<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;______________________________________________________________________________________________________
; wind8basso.orc - general wavetable wind instrument an octave lower (in the brass subdirectory on the CD-ROM)


giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
instr 15                                                    ; general wavetable wind instrument
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
ifreq     =       p5 * .5                                   ; pitch in Hertz (lowered an octave)
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
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 194                                                   ; global reverberation instrument
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

ac1       comb    garev, irevtime, .0297
ac2       comb    garev, irevtime, .0371
ac3       comb    garev, irevtime, .0411
ac4       comb    garev, irevtime, .0437
acomb     =       ac1 + ac2 + ac3 + ac4
ap1       alpass  acomb, .09683, .005
arev      alpass  ap1, .03292, .0017
aout      =       (iacoustic * garev) + (ireverb * arev)    ; mix the signal
          out     aout * igain                              ; attenuate and output the signal
garev     =       0                                         ; set garev to 0 to prevent feedback
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; tuba.sco (in the brass subdirectory on the CD-ROM)
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
;p1   p2       p3      p4     p5        p6      p7      p8      p9  p10
;     start    dur     amp    Hertz     vibr    att     dec     br  in#
;bar 516-------------------------------------------------------------------
i15    1.000   0.900  10000    65.400   0.500   0.030   0.040   9   18
i15    2.000   0.900   6700   130.800   0.500   0.030   0.040   9   18
i15    3.000   0.900   7900   122.625   0.500   0.030   0.040   9   18
i15    4.000   0.900   8600   117.520   0.500   0.030   0.040   9   18
i15    5.000   0.900   7300   109.000   0.500   0.030   0.040   9   18
i15    6.000   0.900   8500   104.640   0.500   0.030   0.040   9   18
;bar 517-------------------------------------------------------------------
i15    7.000   6.000  11200    98.100   0.100   0.040   0.100   9   18
;bar 518-------------------------------------------------------------------
i15   13.000   0.900  11400    65.400   0.500   0.030   0.040   9   18
i15   14.000   0.900   8100   130.800   0.500   0.030   0.040   9   18
i15   15.000   0.900   9300   122.625   0.500   0.030   0.040   9   18
i15   16.000   0.900  10000   117.520   0.500   0.030   0.040   9   18
i15   17.000   0.900   8700   109.000   0.500   0.030   0.040   9   18
i15   18.000   0.900   9900   104.640   0.500   0.030   0.040   9   18
;bar 519-------------------------------------------------------------------
i15   19.000   6.000  12600    98.100   0.100   0.040   0.100   9   18
;bar 520-------------------------------------------------------------------
i15   25.000   0.900  12800    65.400   0.500   0.030   0.040   9   18
i15   26.000   0.900   9500    81.750   0.500   0.030   0.040   9   18
i15   27.000   0.900  10700    87.200   0.500   0.030   0.040   9   18
i15   28.000   0.900  11400    98.100   0.500   0.030   0.040   9   18
i15   29.000   0.900  10100   109.000   0.500   0.030   0.040   9   18
i15   30.000   0.900  11300   122.625   0.500   0.030   0.040   9   18
;bar 521-------------------------------------------------------------------
i15   31.000   0.900  14000   130.800   0.500   0.030   0.040   9   18
i15   32.000   0.900  10700    98.100   0.500   0.030   0.040   9   18
i15   33.000   0.900  11900    81.750   0.500   0.030   0.040   9   18
i15   34.000   0.900  12600    65.400   0.500   0.030   0.040   9   18
i15   35.000   0.900  11300    81.750   0.500   0.030   0.040   9   18
i15   36.000   0.900  12500    98.100   0.500   0.030   0.040   9   18
;bar 522-------------------------------------------------------------------
i15   37.000   0.900  15200   130.800   0.500   0.030   0.040   9   18
i15   38.000   0.900  11900    98.100   0.500   0.030   0.040   9   18
i15   39.000   0.900  12800    81.750   0.500   0.030   0.040   9   18
i15   40.000   0.900  13800    65.400   0.500   0.030   0.040   9   18
i15   41.000   0.900  12500    81.750   0.500   0.030   0.040   9   18
i15   42.000   0.900  13700    98.100   0.500   0.030   0.040   9   18
;bar 523-------------------------------------------------------------------
i15   43.000   0.900  16400   130.800   0.500   0.030   0.040   9   18
i15   44.000   0.900  13100    98.100   0.500   0.030   0.040   9   18
i15   45.000   0.900  14300    81.750   0.500   0.030   0.040   9   18
i15   46.000   0.900  15000    65.400   0.500   0.030   0.040   9   18
i15   47.000   0.900  13700    81.750   0.500   0.030   0.040   9   18
i15   48.000   0.900  14900    98.100   0.500   0.030   0.040   9   18
;bar 524-------------------------------------------------------------------
i15   49.000   9.000  17600   130.800   0.100   0.040   0.300   9   18

;reverb------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.0     57     1.2       .05       1.0
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
