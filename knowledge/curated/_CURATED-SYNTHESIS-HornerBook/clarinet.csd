<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;______________________________________________________________________________________________________
; hornstraight.orc - straight-muted horn instrument (in the brass subdirectory on the CD-ROM)

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
afilt     atone   asig, 1200                                ; insert a high-pass filter to
asig      balance afilt, .5*asig                            ; simulate horn straight mute
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
; clarinet.sco  (in the woodwind subdirectory on the CD-ROM)
; Mahler - Symphony #4, last movement 
; opening clarinet solo plus accompaniment

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f57 0 16384 -17 0 0 181 1 259 2 363 3 501 4 685 5                             ; clarinet wavetables
f58 0 64 -2 59 60 61 1.933 62 63 64 1.546 65 66 67 2.965 68 69 70 3.096 71 72 73 1.019 74 75 4 1.221
f59 0 4097 -9 3 0.389 0 
f60 0 4097 -9 4 0.029 0 5 0.226 0 6 0.034 0 7 0.449 0 
f61 0 4097 -9 8 0.168 0 9 0.480 0 10 0.089 0 11 0.099 0 12 0.040 0 13 0.061 0 14 0.031 0 15 0.079 0 16 0.040 0 17 0.062 0 18 0.063 0 20 0.026 0 21 0.022 0 22 0.044 0 24 0.034 0 26 0.020 0 
f62 0 4097 -9 3 0.560 0 
f63 0 4097 -9 4 0.035 0 5 0.304 0 6 0.122 0 7 0.397 0 
f64 0 4097 -9 8 0.055 0 9 0.141 0 10 0.038 0 11 0.052 0 12 0.022 0 13 0.027 0 14 0.026 0 16 0.038 0 17 0.076 0 18 0.046 0 19 0.029 0 
f65 0 4097 -9 2 0.061 0 3 0.628 0 
f66 0 4097 -9 4 0.231 0 5 1.161 0 6 0.201 0 7 0.328 0 
f67 0 4097 -9 8 0.154 0 9 0.072 0 10 0.186 0 11 0.133 0 12 0.309 0 13 0.071 0 14 0.098 0 15 0.114 0 16 0.027 0 17 0.057 0 18 0.022 0 19 0.042 0 20 0.023 0 
f68 0 4097 -9 2 0.045 0 3 1.408 0 
f69 0 4097 -9 4 0.842 0 5 0.574 0 6 0.124 0 7 0.158 0 
f70 0 4097 -9 8 0.079 0 9 0.185 0 10 0.076 0 11 0.047 0 12 0.059 0 13 0.039 0 14 0.033 0 
f71 0 4097 -9 2 0.206 0 3 0.302 0 
f72 0 4097 -9 4 0.052 0 5 0.069 0 6 0.072 0 7 0.032 0 
f73 0 4097 -9 8 0.031 0 
f74 0 4097 -9 2 0.155 0 3 0.305 0 
f75 0 4097 -9 4 0.322 0 5 0.048 0 6 0.061 0 7 0.025 0 

f275 0 2048 -17 0 0 85 1 114 2 153 3 204 4 272 5 364 6 486 7                  ; horn wavetables
f276 0 64 -2 277 278 279 52.476 280 281 282 18.006 283 284 285 11.274 286 287 288 6.955 289 290 291 2.260 292 293 4 1.171 294 295 4 1.106 296 4 4 1.019 
f277 0 4097 -9 2 6.236 0 3 12.827 0 
f278 0 4097 -9 4 21.591 0 5 11.401 0 6 3.570 0 7 2.833 0 
f279 0 4097 -9 8 3.070 0 9 1.053 0 10 0.773 0 11 1.349 0 12 0.819 0 13 0.369 0 14 0.362 0 15 0.165 0 16 0.124 0 18 0.026 0 19 0.042 0 
f280 0 4097 -9 2 3.236 0 3 6.827 0 
f281 0 4097 -9 4 5.591 0 5 2.401 0 6 1.870 0 7 0.733 0 
f282 0 4097 -9 8 0.970 0 9 0.553 0 10 0.373 0 11 0.549 0 12 0.319 0 13 0.119 0 14 0.092 0 15 0.045 0 16 0.034 0 
f283 0 4097 -9 2 5.019 0 3 4.281 0 
f284 0 4097 -9 4 2.091 0 5 1.001 0 6 0.670 0 7 0.233 0 
f285 0 4097 -9 8 0.200 0 9 0.103 0 10 0.073 0 11 0.089 0 12 0.059 0 13 0.029 0 
f286 0 4097 -9 2 4.712 0 3 1.847 0 
f287 0 4097 -9 4 0.591 0 5 0.401 0 6 0.270 0 7 0.113 0 
f288 0 4097 -9 8 0.060 0 9 0.053 0 10 0.023 0  
f289 0 4097 -9 2 1.512 0 3 0.247 0 
f290 0 4097 -9 4 0.121 0 5 0.101 0 6 0.030 0 7 0.053 0 
f291 0 4097 -9 8 0.030 0  
f292 0 4097 -9 2 0.412 0 3 0.087 0 
f293 0 4097 -9 4 0.071 0 5 0.021 0  
f294 0 4097 -9 2 0.309 0 3 0.067 0
f295 0 4097 -9 4 0.031 0   
f296 0 4097 -9 2 0.161 0 3 0.047 0


t 0 118
;p1   p2       p3      p4     p5        p6      p7      p8      p9  p10
;     start    dur     amp    Hertz     vibr    att     dec     br  in#
;pickup to bar 1---------------------------------------------------------
i15    1.500   0.650   6000   294.300   0.000   0.050   0.100   7   5
i15    1.950   0.700   6500   490.500   0.000   0.050   0.100   7   5
i15    2.450   0.750   7000   392.400   0.000   0.050   0.100   7   5
;drone accompaniment (horns)---------------------------------------------
i15    3.100  10.000   4000   294.300   0.000   0.060   0.250   9   16
i15    3.000  10.000   4000   196.200   0.000   0.060   0.250   9   16
i15   13.100   8.100   4000   294.300   0.000   0.060   0.250   9   16
i15   13.000   8.100   4000   196.200   0.000   0.060   0.250   9   16
;bar 1-------------------------------------------------------------------
i15    3.100   2.150   7500   588.600   0.000   0.050   0.100   7   5
i15    5.150   0.200   7000   654.000   0.000   0.030   0.030   7   5
i15    5.250   1.850   8500   588.600   0.000   0.050   0.100   7   5
;bar 2-------------------------------------------------------------------
i15    7.000   0.200   7000   654.000   0.000   0.030   0.030   7   5
i15    7.100   2.000  10000   588.600   0.000   0.050   0.100   7   5
i15    9.000   0.200   7000   523.200   0.000   0.030   0.030   7   5
i15    9.100   0.800  10000   490.500   0.000   0.050   0.100   7   5
i15    9.800   0.330   8000   436.000   0.000   0.030   0.050   7   5
i15   10.040   0.870  10000   392.400   0.000   0.050   0.100   7   5
i15   10.810   0.290   8000   436.000   0.000   0.030   0.050   7   5
;bar 3-------------------------------------------------------------------
i15   11.000   2.000  10000   294.300   0.000   0.050   0.100   7   5
i15   13.000   0.850   8500   436.000   0.000   0.050   0.100   7   5
i15   13.750   0.350   7500   490.500   0.000   0.030   0.050   7   5
i15   14.000   0.870   9000   523.200   0.000   0.050   0.100   7   5
i15   14.770   0.330   7500   436.000   0.000   0.030   0.050   7   5
;bar 4-------------------------------------------------------------------
i15   15.000   0.900   9500   588.600   0.000   0.050   0.100   7   5
i15   15.800   0.300   8000   654.000   0.000   0.030   0.050   7   5
i15   16.000   1.920  10000   588.600   0.000   0.050   0.100   7   5
i15   17.820   0.280   8000   654.000   0.000   0.030   0.050   7   5
i15   18.000   0.940  11000   588.600   0.000   0.050   0.100   7   5
i15   18.840   0.260   8000   654.000   0.000   0.030   0.050   7   5
;bar 4 lower part--------------------------------------------------------
i15   15.000   0.910   7000   245.250   0.000   0.050   0.100   7   5
i15   15.810   0.290   6500   147.150   0.000   0.030   0.050   7   5
i15   16.000   1.100   7000   196.200   0.000   0.050   0.100   7   5
i15   17.000   0.930   7000   261.600   0.000   0.050   0.100   7   5
i15   17.830   0.270   6500   147.150   0.000   0.030   0.050   7   5
i15   18.000   1.100   7000   218.000   0.000   0.050   0.100   7   5
;bar 5-------------------------------------------------------------------
i15   19.000   2.000  10000   588.600   0.000   0.050   0.100   7   5
;bar 5 lower part--------------------------------------------------------
i15   19.000   0.900   8000   294.300   0.000   0.050   0.100   7   5
i15   19.800   0.300   6500   147.150   0.000   0.030   0.050   7   5
i15   20.000   1.000   7500   245.250   0.000   0.050   0.100   7   5

;reverb------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.5     19.1   1.5       .05       1.0
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
