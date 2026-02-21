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
; piccolo.sco (in the woodwind subdirectory on the CD-ROM)
; Stravinsky - Rite of Spring 
; piccolo solo in opening after marking 32

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f11 0 16384 -17 0 0 843 1 1202 2 1696 3 2400 4                                ; piccolo wavetables 
f12 0 64 -2 13 14 15 .990 16 17 4 .89 18 19 4 .941 20 4 4 .99 21 4 4 .996
f13 0 8193 -9 2 0.151 0 3 0.234 0 
f14 0 8193 -9 4 0.145 0 5 0.039 0 6 0.022 0 7 0.014 0 
f15 0 8193 -9 8 0.012 0 9 0.022 0 
f16 0 8193 -9 2 0.078 0 3 0.159 0 
f17 0 8193 -9 4 0.039 0 5 0.028 0 
f18 0 8193 -9 2 0.040 0 3 0.079 0 
f19 0 8193 -9 4 0.020 0 5 0.012 0 
f20 0 8193 -9 2 0.030 0 3 0.015 0 
f21 0 8193 -9 2 0.019 0 3 0.009 0 

t 0 100
;p1   p2      p3    p4      p5         p6      p7      p8      p9  p10
;     start   dur   amp     Hertz      vibr    att     dec     br  in# ; note
;bar 1---------------------------------------------------------------------------------
i15   1.000   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   1.100   .12   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   1.200   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   1.300   .12   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   1.400   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   1.500   .12   10000   2354.400   1.000   0.020   0.020   9   1   ; D7
i15   1.600   .17   10000   2092.800   1.000   0.020   0.020   9   1   ; C7
i15   1.750   .27   10000   1569.600   1.000   0.030   0.070   9   1   ; G6
i15   2.000   .52   10000   1744.000   1.000   0.030   0.100   9   1   ; A6
i15   2.500   .52   10000   2354.400   1.000   0.030   0.100   9   1   ; D7
;bar 2---------------------------------------------------------------------------------
i15   3.000   .12   10000   2092.800   1.000   0.020   0.020   9   1   ; C7
i15   3.100   .12   10000   2354.400   1.000   0.020   0.020   9   1   ; D7
i15   3.200   .12   10000   2092.800   1.000   0.020   0.020   9   1   ; C7
i15   3.300   .12   10000   2354.400   1.000   0.020   0.020   9   1   ; D7
i15   3.400   .12   10000   2092.800   1.000   0.020   0.020   9   1   ; C7
i15   3.500   .27   10000   1962.000   1.000   0.030   0.070   9   1   ; B6
i15   3.750   .27   10000   1744.000   1.000   0.030   0.070   9   1   ; A6
i15   4.000   .52   10000   1962.000   1.000   0.030   0.100   9   1   ; B6
i15   4.500   .50   10000   1569.600   1.000   0.030   0.100   9   1   ; G6
;bar 3---------------------------------------------------------------------------------
i15   5.000   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   5.100   .12   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   5.200   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   5.300   .12   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   5.400   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   5.500   .12   10000   2354.400   1.000   0.020   0.020   9   1   ; D7
i15   5.600   .17   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   5.750   .27   10000   1569.600   1.000   0.030   0.070   9   1   ; G6
i15   6.000   .52   10000   1744.000   1.000   0.030   0.100   9   1   ; A6
i15   6.500   .12   10000   2354.400   1.000   0.020   0.020   9   1   ; D7
i15   6.600   .42   10000   1962.000   1.000   0.030   0.100   9   1   ; B6
;bar 4---------------------------------------------------------------------------------
i15   7.000   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   7.100   .12   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   7.200   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   7.300   .12   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   7.400   .12   10000   1744.000   1.000   0.020   0.020   9   1   ; A6
i15   7.500   .52   10000   2354.400   1.000   0.030   0.100   9   1   ; D7
i15   8.000   .52   10000   2092.800   1.000   0.030   0.100   9   1   ; C7
i15   8.500   .12   10000   2354.400   1.000   0.020   0.020   9   1   ; D7
i15   8.600   .17   10000   1962.000   1.000   0.020   0.020   9   1   ; B6
i15   8.750   .25   10000   1569.600   1.000   0.020   0.020   9   1   ; G6

;reverb--------------------------------------------------------------------------------
;p1    p2      p3    p4        p5        p6
;      start   dur   revtime   %reverb   gain
i194   1       8     1.0       .04       1.0
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
