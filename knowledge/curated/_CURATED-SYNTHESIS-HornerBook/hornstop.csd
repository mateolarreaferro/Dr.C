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
; hornstop.sco (in the brass subdirectory on the CD-ROM)
; R. Strauss - Til Eulenspiegel's Merry Pranks
; opening horn solo - a trick to do on stopped horn!

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f297 0 16384 -17 0 0 272 1 363 2 484 3                                        ; stopped horn wavetables
f298 0 64 -2 299 300 301 3.172 302 303 304 1.947 305 306 307 2.221 308 309 310 2.811
f299 0 4097 -9 2 0.961 0 3 0.052 0 
f300 0 4097 -9 4 0.079 0 5 0.137 0 6 0.185 0 7 0.109 0 
f301 0 4097 -9 8 0.226 0 9 0.107 0 10 0.155 0 11 0.140 0 12 0.428 0 13 0.180 0 14 0.070 0 15 0.112 0 16 0.335 0 17 0.183 0 18 0.073 0 19 0.172 0 20 0.117 0 21 0.089 0 22 0.193 0 23 0.119 0 24 0.080 0 25 0.036 0 26 0.143 0 27 0.036 0 28 0.044 0 29 0.040 0 30 0.052 0 31 0.086 0 32 0.067 0 33 0.097 0 34 0.046 0 36 0.030 0 37 0.025 0 38 0.048 0 39 0.021 0 40 0.025
f302 0 4097 -9 2 0.162 0 3 0.068 0 
f303 0 4097 -9 4 0.116 0 5 0.138 0 6 0.050 0 7 0.089 0 
f304 0 4097 -9 8 0.156 0 9 0.381 0 10 0.191 0 11 0.126 0 12 0.162 0 13 0.073 0 15 0.157 0 16 0.074 0 17 0.087 0 18 0.151 0 19 0.093 0 20 0.031 0 21 0.030 0 22 0.051 0 23 0.058 0 24 0.051 0 25 0.077 0 26 0.033 0 27 0.021 0 28 0.039 0  
f305 0 4097 -9 2 0.164 0 3 0.164 0 
f306 0 4097 -9 4 0.401 0 5 0.141 0 6 0.293 0 7 0.203 0 
f307 0 4097 -9 8 0.170 0 9 0.306 0 10 0.170 0 11 0.103 0 12 0.131 0 13 0.134 0 14 0.047 0 15 0.182 0 16 0.049 0 17 0.088 0 18 0.088 0 19 0.064 0 20 0.024 0 21 0.064 0 22 0.022 
f308 0 4097 -9 2 0.193 0 3 0.542 0 
f309 0 4097 -9 4 0.125 0 5 0.958 0 6 0.154 0 7 0.364 0 
f310 0 4097 -9 8 0.444 0 9 0.170 0 10 0.090 0 11 0.077 0 12 0.026 0 13 0.073 0 

t 0 324
;p1   p2       p3      p4     p5        p6      p7      p8      p9  p10
;     start    dur     amp    Hertz     vibr    att     dec     br  in#
;bar 1-------------------------------------------------------------------
i15    2.000   0.700   6500   261.600   0.500   0.040   0.040   9   17
i15    3.000   0.700   8000   348.800   0.500   0.040   0.040   9   17
i15    4.000   0.700   7200   392.400   0.500   0.040   0.040   9   17
i15    5.000   3.100   6500   418.560   0.500   0.040   0.040   9   17
;bar 2-------------------------------------------------------------------
i15    8.000   0.650   8000   436.000   0.500   0.040   0.040   9   17
i15    9.000   0.700   6000   261.600   0.500   0.040   0.040   9   17
i15   10.000   0.700   7200   348.800   0.500   0.040   0.040   9   17
i15   11.000   0.700   8000   392.400   0.500   0.040   0.040   9   17
i15   12.000   3.100   7500   418.560   0.500   0.040   0.040   9   17
;bar 3-------------------------------------------------------------------
i15   15.000   0.650   9000   436.000   0.500   0.040   0.040   9   17
i15   16.000   0.700   5500   261.600   0.500   0.040   0.040   9   17
i15   17.000   0.700   6500   348.800   0.500   0.040   0.040   9   17
i15   18.000   0.700   7500   392.400   0.500   0.040   0.040   9   17
;bar 4-------------------------------------------------------------------
i15   19.000   1.700  10000   418.560   0.500   0.060   0.100   9   17
i15   21.000   1.700  10000   436.000   0.500   0.060   0.100   9   17
i15   23.000   0.700   6500   470.080   0.500   0.040   0.040   9   17
i15   24.000   0.700   7500   490.500   0.500   0.040   0.040   9   17
;bar 5-------------------------------------------------------------------
i15   25.000   0.700  10000   588.600   0.500   0.040   0.040   9   17
i15   26.000   0.700   6500   523.200   0.500   0.040   0.040   9   17
i15   27.000   0.700   7500   436.000   0.500   0.040   0.040   9   17
i15   28.000   0.700   8000   348.800   0.500   0.040   0.040   9   17
i15   29.000   0.700   6500   261.600   0.500   0.040   0.040   9   17
i15   30.000   0.700   7500   218.000   0.500   0.040   0.040   9   17
;bar 6-------------------------------------------------------------------
;i15  31.000   3.000  10000   174.400   0.000   0.060   0.250   9   17
;i15  34.000   3.000   5000   130.800   0.000   0.040   0.250   9   17
;bar 7-------------------------------------------------------------------
;i15  37.000   3.100   2000    87.200   0.000   0.040   0.250   9   17

;reverb------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   2.0     28.7   1.2       .1        1.0
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
