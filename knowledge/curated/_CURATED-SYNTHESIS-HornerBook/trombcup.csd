<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;______________________________________________________________________________________________________
; trombstraight.orc - straight-muted trombone instrument (in the brass subdirectory on the CD-ROM)


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
afilt     atone   asig, 900                                 ; insert a high-pass filter to
asig      balance afilt, .5*asig                            ; simulate trombone straight mute
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
; trombcup.sco
; Brahms - Symphony #2, ending

f1 0 4097 -9 1 1.0 0
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311
f4 0 5 -9 1 0.0 0

f239 0 16384 -17 0 0 114 1 153 2 204 3 272 4 363 5  ; cup-muted trombone wavetables
;f240 0 64 -2 241 242 243 6.882 244 245 246 34.473 247 248 249 29.848 250 251 252 8.260 253 254 255 5.019 256 257 10 1.151
f240 0 64 -2 241 242 243 6.882 244 245 246 34.473 247 248 249 29.848 250 251 252 8.260 253 254 255 5.019 256 257 4 1.151
f241 0 4097 -9 2 0.842 0 3 0.715 0 
f242 0 4097 -9 4 1.454 0 5 1.938 0 6 1.129 0 7 1.207 0 
f243 0 4097 -10 0 0 0 0 0 0 0 0.346 0.247 0.138 0.340 0.217 0.156 0.477 0.143 0.169 0.056 0 0 0.058 0.042 0.049 0.085 0.076 0.079 0.066 0.060 0.043 0.047 0.042 0.032 0.021 0 0 0.038 0.025 
f244 0 4097 -9 2 4.452 0 3 6.225 0 
f245 0 4097 -9 4 13.456 0 5 8.114 0 6 5.154 0 7 0.722 0 
f246 0 4097 -10 0 0 0 0 0 0 0 2.575 0.892 1.249 1.009 1.135 0.313 0.113 0.369 0.057 0.650 0.603 0.781 0.554 0.527 0.397 0.244 0.056 0.066 0.195 0.045 0.030 0 0 0 0 0.033 0.030 0.059 0.044 0.023 0.024 
f247 0 4097 -9 2 5.252 0 3 16.187 0 
f248 0 4097 -9 4 8.092 0 5 2.320 0 6 2.514 0 7 2.044 0 
f249 0 4097 -10 0 0 0 0 0 0 0 1.673 1.007 0.262 0.474 0.799 0.784 1.019 0.944 0.796 0.491 0.292 0.532 0.326 0.151 0.105 0.097 0.062 0.108 0.129 0.076 0.038 
f250 0 4097 -9 2 3.598 0 3 3.973 0 
f251 0 4097 -9 4 1.075 0 5 0.428 0 6 0.863 0 7 0.438 0 
f252 0 4097 -10 0 0 0 0 0 0 0 0.159 0.265 0.633 0.593 0.484 0.261 0.082 0.079 0.034 
f253 0 4097 -9 2 3.931 0 3 0.781 0 
f254 0 4097 -9 4 0.448 0 5 0.573 0 6 0.079 0 7 0.230 0 
f255 0 4097 -10 0 0 0 0 0 0 0 0.169 0.100 0.025 
f256 0 4097 -9 2 0.343 0 3 0.127 0 
f257 0 4097 -9 4 0.038 0 6 0.041 0 7 0.025 0 

t0 276
;p1   p2       p3      p4      p5        p6      p7      p8      p9  p10
;     start    dur     amp     Hertz     vibr    att     dec     br  in#
;bar 1-------------------------------------------------------------------
i15    1.000   8.000    7500   220.000   0.000   0.050   0.050   9   14
i15    1.015   8.000    7500   277.200   0.000   0.050   0.050   9   14
;bar 2-------------------------------------------------------------------
i15    1.000   0.950   15000   370.000   0.000   0.050   0.050   9   14
i15    2.000   0.950   12000   329.600   0.000   0.050   0.050   9   14
i15    3.000   0.950   13500   293.700   0.000   0.050   0.050   9   14
i15    4.000   0.950   12000   277.200   0.000   0.050   0.050   9   14
;bar 3-------------------------------------------------------------------
i15    5.000   0.950   15000   246.900   0.000   0.050   0.050   9   14
i15    6.000   0.950   12000   220.000   0.000   0.050   0.050   9   14
i15    7.000   0.950   13500   207.600   0.000   0.050   0.050   9   14
i15    8.000   0.950   12000   185.000   0.000   0.050   0.050   9   14
;bar 4-------------------------------------------------------------------
i15    9.012   8.000    7500   174.600   0.000   0.050   0.050   9   14
i15    9.023   8.000    7500   293.700   0.000   0.050   0.050   9   14
;bar 5-------------------------------------------------------------------
i15    9.000   0.950   15000   415.300   0.000   0.050   0.050   9   14
i15   10.000   0.950   12000   392.000   0.000   0.050   0.050   9   14
i15   11.000   0.950   13500   349.200   0.000   0.050   0.050   9   14
i15   12.000   0.950   12000   329.600   0.000   0.050   0.050   9   14
;bar 6-------------------------------------------------------------------
i15   13.000   0.950   15000   293.700   0.000   0.050   0.050   9   14
i15   14.000   0.950   12000   261.600   0.000   0.050   0.050   9   14
i15   15.000   0.950   13500   246.900   0.000   0.050   0.050   9   14
i15   16.000   0.950   12000   220.000   0.000   0.050   0.050   9   14
;bar 7-------------------------------------------------------------------
i15   17.028   8.000    7500   164.800   0.000   0.050   0.050   9   14
i15   17.019   8.000    7500   415.300   0.000   0.050   0.050   9   14
;bar 8-------------------------------------------------------------------
i15   17.000   0.950   22000   587.300   0.000   0.050   0.050   9   14
i15   18.000   0.950   17000   554.400   0.000   0.050   0.050   9   14
i15   19.000   0.950   19500   493.900   0.000   0.050   0.050   9   14
i15   20.000   0.950   17000   440.000   0.000   0.050   0.050   9   14
;bar 9-------------------------------------------------------------------
i15   21.000   0.950   13000   415.300   0.000   0.050   0.050   9   14
i15   22.000   0.950   12000   370.000   0.000   0.050   0.050   9   14
i15   23.000   0.950   13500   329.600   0.000   0.050   0.050   9   14
i15   24.000   0.950   12000   293.700   0.000   0.050   0.050   9   14
;bar 10-------------------------------------------------------------------
i15   25.000   6.000   10500   110.000   0.000   0.050   0.050   9   14
i15   25.013   6.000   10500   164.800   0.000   0.050   0.050   9   14
i15   25.024   6.000   10500   196.000   0.000   0.050   0.050   9   14
i15   25.029   6.000   10500   277.200   0.000   0.050   0.050   9   14
;bar 11-------------------------------------------------------------------
i15   31.000   2.000    9000   110.000   0.000   0.050   0.100   9   14
i15   31.027   2.000    9000   164.800   0.000   0.050   0.100   9   14
i15   31.021   2.000    9000   196.000   0.000   0.050   0.100   9   14
i15   31.014   2.000    9000   277.200   0.000   0.050   0.100   9   14
;bar 12-------------------------------------------------------------------
i15   33.000   1.300   10000    73.420   0.000   0.050   0.100   9   14
i15   33.028   1.300   10000   146.800   0.000   0.050   0.100   9   14
i15   33.017   1.300   10000   185.000   0.000   0.050   0.100   9   14
i15   33.019   1.300   10000   293.700   0.000   0.050   0.100   9   14

;reverb------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.0     33.5   1.2       .1        1.0
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
