<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;______________________________________________________________________________________________________
; trumpstraight.orc - straight-muted trumpet instrument (in the brass subdirectory on the CD-ROM)


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
afilt     atone   asig, 1800                                ; insert a high-pass filter to
asig      balance afilt, .5*asig                            ; simulate trumpet straight mute
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
; trumphar.sco  (in the brass subdirectory on the CD-ROM)
; Bach - Brandenburg Concerto #2, opening of last movement

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f191 0 16384 -17 0 0 254 1 340 2 457 3 615 4 828 5 1000 6                     ; harmon-muted trumpet wavetables
f192 0 64 -2 193 194 195 2.193 196 197 198 2.663 199 200 201 6.645 202 203 204 7.124 205 206 207 12.170 208 209 210 16.937 208 209 4 8.823
f193 0 4097 -9 2 0.290 0 3 0.189 0 
f194 0 4097 -9 4 0.080 0 5 0.035 0 6 0.044 0 7 0.312 0 
f195 0 4097 -9 8 0.117 0 9 0.062 0 10 0.070 0 11 0.024 0 12 0.061 0 13 0.062 0 14 0.086 0 15 0.093 0 16 0.113 0 17 0.092 0 18 0.090 0 19 0.052 0 21 0.026 0 22 0.077 0 23 0.342 0 24 0.150 0 25 0.023 0 28 0.043 0 29 0.066 0 30 0.096 0 31 0.024 0 32 0.081 0 33 0.104 0 34 0.124 0 35 0.117 0 36 0.058 0 37 0.049 0 38 0.054 0 39 0.031 0 41 0.040 0 42 0.063 0 43 0.022 0  
f196 0 4097 -9 2 0.304 0 3 0.049 0 
f197 0 4097 -9 4 0.033 0 5 0.469 0 6 0.203 0 7 0.049 0 
f198 0 4097 -9 8 0.034 0 9 0.112 0 10 0.098 0 11 0.122 0 12 0.147 0 13 0.130 0 14 0.066 0 15 0.027 0 16 0.058 0 17 0.292 0 18 0.260 0 19 0.051 0 21 0.068 0 22 0.105 0 23 0.128 0 24 0.072 0 25 0.205 0 26 0.206 0 27 0.124 0 28 0.029 0 29 0.170 0 30 0.132 0 31 0.104 0 32 0.135 0 
f199 0 4097 -9 2 0.312 0 3 0.082 0 
f200 0 4097 -9 4 0.738 0 5 0.299 0 6 0.093 0 7 0.205 0 
f201 0 4097 -9 8 0.375 0 9 0.613 0 10 0.225 0 11 0.074 0 12 0.292 0 13 1.594 0 14 0.163 0 15 0.139 0 16 0.399 0 17 0.344 0 18 0.510 0 19 0.627 0 20 0.272 0 21 0.374 0 22 0.275 0 23 0.218 0 24 0.167 0  
f202 0 4097 -9 2 0.273 0 3 1.231 0 
f203 0 4097 -9 4 0.438 0 5 0.267 0 6 0.492 0 7 1.018 0 
f204 0 4097 -9 8 0.279 0 9 0.386 0 10 1.270 0 11 0.069 0 12 0.522 0 13 0.187 0 14 0.869 0 15 0.683 0 16 0.625 0 17 0.513 0   
f205 0 4097 -9 2 1.470 0 3 0.719 0 
f206 0 4097 -9 4 0.231 0 5 1.530 0 6 0.538 0 7 2.281 0 
f207 0 4097 -9 8 0.099 0 9 2.003 0 10 1.393 0 11 2.173 0 12 0.546 0 13 1.356 0
f208 0 4097 -9 2 1.389 0 3 0.637 0 
f209 0 4097 -9 4 1.740 0 5 1.039 0 6 0.614 0 7 3.915 0 
f210 0 4097 -9 8 2.935 0 9 2.954 0 10 2.487 0 11 0.828 0 

t0 120
;p1   p2       p3      p4     p5          p6      p7      p8      p9  p10
;     start    dur     amp    Hertz       vibr    att     dec     br  in#
;bar 1-------------------------------------------------------------------
i15    1.000   0.500  10000    697.600    0.500   0.030   0.080   9   12
i15    1.500   0.500   8000   1046.400    0.500   0.030   0.080   9   12
i15    2.000   0.237   9000   1046.400    0.500   0.030   0.030   9   12
i15    2.167   0.236   6500   1177.200    0.500   0.030   0.030   9   12
i15    2.333   0.237   6500   1046.400    0.500   0.030   0.030   9   12
i15    2.500   0.250   8000    941.760    0.500   0.030   0.030   9   12
i15    2.750   0.250   7200   1046.400    0.500   0.030   0.030   9   12
;bar 2-------------------------------------------------------------------
i15    3.000   0.500  10000   1177.200    0.500   0.030   0.080   9   12
i15    3.500   0.250   8000   1046.400    0.500   0.030   0.030   9   12
i15    3.750   0.250   7200    941.760    0.500   0.030   0.030   9   12
i15    4.000   0.500   9000   1046.400    0.500   0.030   0.080   9   12
i15    4.500   0.500   8000   1395.200    0.500   0.030   0.080   9   12
;bar 3-------------------------------------------------------------------
i15    5.000   0.237  10000   1046.400    0.500   0.030   0.030   9   12
i15    5.167   0.236   6500   1177.200    0.500   0.030   0.030   9   12
i15    5.333   0.237   6500   1046.400    0.500   0.030   0.030   9   12
i15    5.500   0.250   8000    872.000    0.500   0.030   0.030   9   12
i15    5.750   0.250   7200    941.760    0.500   0.030   0.030   9   12
i15    6.000   0.237   9000   1046.400    0.500   0.030   0.030   9   12
i15    6.167   0.236   6500   1177.200    0.500   0.030   0.030   9   12
i15    6.333   0.237   6500   1046.400    0.500   0.030   0.030   9   12
i15    6.500   0.250   8000    941.760    0.500   0.030   0.030   9   12
i15    6.750   0.250   7200   1046.400    0.500   0.030   0.030   9   12
;bar 4-------------------------------------------------------------------
i15    7.000   0.500  10000   1177.200    0.500   0.030   0.080   9   12
i15    7.500   0.250   8000   1046.400    0.500   0.030   0.030   9   12
i15    7.750   0.250   7200    941.760    0.500   0.030   0.030   9   12
i15    8.000   0.250   9000   1046.400    0.500   0.030   0.030   9   12
i15    8.250   0.250   7200    941.760    0.500   0.030   0.030   9   12
i15    8.500   0.250   8000    872.000    0.500   0.030   0.030   9   12
i15    8.750   0.250   7200   1046.400    0.500   0.030   0.030   9   12
;bar 5-------------------------------------------------------------------
i15    9.000   0.250  10000    941.760    0.500   0.030   0.030   9   12
i15    9.250   0.250   7200    872.000    0.500   0.030   0.030   9   12
i15    9.500   0.250   8000    784.800    0.500   0.030   0.030   9   12
i15    9.750   0.250   7200    941.760    0.500   0.030   0.030   9   12
i15   10.000   0.250   9000    872.000    0.500   0.030   0.030   9   12
i15   10.250   0.250   7200    784.800    0.500   0.030   0.030   9   12
i15   10.500   0.250   8000    697.600    0.500   0.030   0.030   9   12
i15   10.750   0.250   7200    872.000    0.500   0.030   0.030   9   12
;bar 6-------------------------------------------------------------------
i15   11.000   0.250  10000    784.800    0.500   0.030   0.030   9   12
i15   11.250   0.250   7200    697.600    0.500   0.030   0.030   9   12
i15   11.500   0.250   8000    784.800    0.500   0.030   0.030   9   12
i15   11.750   0.250   7200    872.000    0.500   0.030   0.030   9   12
i15   12.000   0.250   9000    941.760    0.500   0.030   0.030   9   12
i15   12.250   0.250   7200    872.000    0.500   0.030   0.030   9   12
i15   12.500   0.250   8000    784.800    0.500   0.030   0.030   9   12
i15   12.750   0.250   7200    697.600    0.500   0.030   0.030   9   12
;bar 7-------------------------------------------------------------------
i15   13.000   0.500  10000    784.800    0.500   0.030   0.030   9   12
i15   13.500   0.500   8000    523.200    0.500   0.030   0.030   9   12

;reverb------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.0     13     1.5       .1        1.0
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
