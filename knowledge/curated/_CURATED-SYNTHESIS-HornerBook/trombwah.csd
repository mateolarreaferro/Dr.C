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
; trombwah.sco (in the brass subdirectory on the CD-ROM)
; Brahms - Symphony #2, ending

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f258 0 16384 -17 0 0 130 1 194 2 291 3 407 4                                  ; wah-wah-muted trombone wavetables
f259 0 64 -2 260 261 262 29.932 263 264 265 38.313 266 267 268 18.641 269 270 271 34.391 272 273 274 3.578
f260 0 4097 -9 2 0.395 0 3 0.979 0 
f261 0 4097 -9 4 0.897 0 5 0.720 0 6 0.657 0 7 2.624 0 
f262 0 4097 -10 0 0 0 0 0 0 0 2.916 4.811 4.063 4.477 4.998 2.497 0.391 0.525 1.062 1.310 1.780 0.885 0.489 0.969 2.350 0.324 0.281 0.213 0.223 0.310 0.398 0.611 0.895 0.844 0.160 0.599 1.237 0.221 0.170 0.441 0.300 0.367 0.377 0.153 0.288 0.455 0.213 0.232 0.259 0.365 0.571 0.484 0.067 0.353 0.232 0.485 0.463 0.247 0.352 0.204 0.194 0.081 0.259 0.293 0.211 0.286 0.370 0.321 
f263 0 4097 -9 2 1.478 0 3 3.574 0 
f264 0 4097 -9 4 2.002 0 5 8.026 0 6 6.279 0 7 7.338 0 
f265 0 4097 -10 0 0 0 0 0 0 0 8.934 1.487 0.749 0.757 1.957 1.643 3.021 1.733 0.277 0.610 0.773 0.714 0.515 1.026 1.106 1.929 0.948 0.884 0.730 0.418 0.262 0.511 0.597 0.417 0.326 0.144 
f266 0 4097 -9 2 3.827 0 3 8.142 0 
f267 0 4097 -9 4 2.766 0 5 5.199 0 6 0.342 0 7 0.199 0 
f268 0 4097 -10 0 0 0 0 0 0 0 0.987 0.654 0.398 0.241 0.449 0.230 1.624 0.587 1.412 0.289 0.075 0.375 0.215 0.092 0.163 0.298 0.191 0.193 0.277 0.127 0.307 0.411 0.511 0.761 0.536 0.332 0.354 0.421 0.503 0.364 
f269 0 4097 -9 2 4.266 0 3 19.463 0 
f270 0 4097 -9 4 4.572 0 5 3.827 0 6 2.501 0 7 0.269 0 
f271 0 4097 -10 0 0 0 0 0 0 0 1.628 4.291 2.569 2.179 1.067 2.121 3.039 1.117 1.872 1.067 1.218 0.513 0.490 0.736 1.061 1.074 0.594 0.743 0.643 0.897 
f272 0 4097 -9 2 2.843 0 3 0.213 0 
f273 0 4097 -9 4 0.219 0 5 0.125 0 6 0.156 0 7 0.124 0 
f274 0 4097 -10 0 0 0 0 0 0 0 0.185 0.080 0.178 0.034 0.188 0.032 0.258 0.038 0.158 0.073 

t0 276
;p1   p2       p3      p4      p5        p6      p7      p8      p9  p10
;     start    dur     amp     Hertz     vibr    att     dec     br  in#
;bar 1-------------------------------------------------------------------
i15    1.000   8.000    7500   220.000   0.000   0.050   0.050   9   15
i15    1.015   8.000    7500   277.200   0.000   0.050   0.050   9   15
;bar 2-------------------------------------------------------------------
i15    1.000   0.950   15000   370.000   0.000   0.050   0.050   9   15
i15    2.000   0.950   12000   329.600   0.000   0.050   0.050   9   15
i15    3.000   0.950   13500   293.700   0.000   0.050   0.050   9   15
i15    4.000   0.950   12000   277.200   0.000   0.050   0.050   9   15
;bar 3-------------------------------------------------------------------
i15    5.000   0.950   15000   246.900   0.000   0.050   0.050   9   15
i15    6.000   0.950   12000   220.000   0.000   0.050   0.050   9   15
i15    7.000   0.950   13500   207.600   0.000   0.050   0.050   9   15
i15    8.000   0.950   12000   185.000   0.000   0.050   0.050   9   15
;bar 4-------------------------------------------------------------------
i15    9.012   8.000    7500   174.600   0.000   0.050   0.050   9   15
i15    9.023   8.000    7500   293.700   0.000   0.050   0.050   9   15
;bar 5-------------------------------------------------------------------
i15    9.000   0.950   15000   415.300   0.000   0.050   0.050   9   15
i15   10.000   0.950   12000   392.000   0.000   0.050   0.050   9   15
i15   11.000   0.950   13500   349.200   0.000   0.050   0.050   9   15
i15   12.000   0.950   12000   329.600   0.000   0.050   0.050   9   15
;bar 6-------------------------------------------------------------------
i15   13.000   0.950   15000   293.700   0.000   0.050   0.050   9   15
i15   14.000   0.950   12000   261.600   0.000   0.050   0.050   9   15
i15   15.000   0.950   13500   246.900   0.000   0.050   0.050   9   15
i15   16.000   0.950   12000   220.000   0.000   0.050   0.050   9   15
;bar 7-------------------------------------------------------------------
i15   17.028   8.000    7500   164.800   0.000   0.050   0.050   9   15
i15   17.019   8.000    7500   415.300   0.000   0.050   0.050   9   15
;bar 8-------------------------------------------------------------------
i15   17.000   0.950   22000   587.300   0.000   0.050   0.050   9   15
i15   18.000   0.950   17000   554.400   0.000   0.050   0.050   9   15
i15   19.000   0.950   19500   493.900   0.000   0.050   0.050   9   15
i15   20.000   0.950   17000   440.000   0.000   0.050   0.050   9   15
;bar 9-------------------------------------------------------------------
i15   21.000   0.950   15000   415.300   0.000   0.050   0.050   9   15
i15   22.000   0.950   12000   370.000   0.000   0.050   0.050   9   15
i15   23.000   0.950   13500   329.600   0.000   0.050   0.050   9   15
i15   24.000   0.950   12000   293.700   0.000   0.050   0.050   9   15
;bar 10-------------------------------------------------------------------
i15   25.000   6.000   10500   110.000   0.000   0.050   0.050   9   15
i15   25.013   6.000   10500   164.800   0.000   0.050   0.050   9   15
i15   25.024   6.000   10500   196.000   0.000   0.050   0.050   9   15
i15   25.029   6.000   10500   277.200   0.000   0.050   0.050   9   15
;bar 11-------------------------------------------------------------------
i15   31.000   2.000    9000   110.000   0.000   0.050   0.100   9   15
i15   31.027   2.000    9000   164.800   0.000   0.050   0.100   9   15
i15   31.021   2.000    9000   196.000   0.000   0.050   0.100   9   15
i15   31.014   2.000    9000   277.200   0.000   0.050   0.100   9   15
;bar 12-------------------------------------------------------------------
i15   33.000   1.300   12500    73.420   0.000   0.050   0.100   9   15
i15   33.028   1.300   12500   146.800   0.000   0.050   0.100   9   15
i15   33.017   1.300   12500   185.000   0.000   0.050   0.100   9   15
i15   33.019   1.300   12500   293.700   0.000   0.050   0.100   9   15

;reverb------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.0     33.4   1.1       .05       1.0
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
