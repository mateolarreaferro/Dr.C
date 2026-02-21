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
; flute.sco (in the woodwind subdirectory on the CD-ROM)
; Debussy - Prelude a l'Apres-midi d'un Faune
; opening flute solo

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f22 0 16384 -17 0 0 611 1 1050 2                                              ; flute wavetables
f23 0 64 -2 24 25 4 1.026 26 27 4 0.953 28 4 4 0.992
f24 0 4097 -9 2 0.260 0 3 0.118 0 
f25 0 4097 -9 4 0.085 0 5 0.017 0 6 0.014 0 
f26 0 4097 -9 2 0.090 0 3 0.078 0 
f27 0 4097 -9 4 0.010 0 5 0.013 0 
f28 0 4097 -9 2 0.029 0 3 0.011 0 

t 0 84
;p1   p2       p3      p4     p5        p6      p7      p8      p9  p10
;     start    dur     amp    Hertz     vibr    att     dec     br  in#
;bar 1----------------------------------------------------------------------------------
i15    1.000   4.700   7000   558.080   1.000   0.230   0.100   5   2
i15    5.500   0.700   5000   490.500   1.000   0.080   0.100   5   2
i15    6.000   0.480   5500   470.080   1.000   0.080   0.080   5   2
i15    6.280   0.530   6000   436.000   1.000   0.080   0.080   5   2
i15    6.610   0.590   6500   418.560   1.000   0.080   0.080   5   2
i15    7.000   1.700   7000   392.400   1.000   0.120   0.100   5   2
i15    8.500   0.660   6500   436.000   1.000   0.080   0.100   5   2
i15    8.960   0.700   6000   490.500   1.000   0.080   0.100   5   2
i15    9.460   0.740   5500   523.200   1.000   0.080   0.100   5   2
;bar 2----------------------------------------------------------------------------------
i15   10.000   4.700   6000   558.080   1.000   0.160   0.100   5   2
i15   14.500   0.700   5500   490.500   1.000   0.080   0.100   5   2
i15   15.000   0.490   6000   470.080   1.000   0.080   0.080   5   2
i15   15.290   0.530   6500   436.000   1.000   0.080   0.080   5   2
i15   15.620   0.580   7000   418.560   1.000   0.080   0.080   5   2
i15   16.000   1.700   7500   392.400   1.000   0.120   0.100   5   2
i15   17.500   0.670   7000   436.000   1.000   0.080   0.100   5   2
i15   17.970   0.700   6500   490.500   1.000   0.080   0.100   5   2
i15   18.470   0.730   6000   523.200   0.500   0.080   0.100   5   2
;bar 3----------------------------------------------------------------------------------
i15   19.000   1.160   6500   558.080   0.500   0.120   0.100   5   2
i15   19.960   1.200   7000   627.840   0.500   0.120   0.100   6   2
i15   20.960   1.240   7500   837.120   0.500   0.120   0.100   7   2
i15   22.000   2.150   8000   654.000   0.500   0.140   0.100   6   2
i15   24.000   1.200   5000   418.560   1.000   0.120   0.100   5   2
i15   25.000   4.200   7500   490.500   1.000   0.160   0.100   5   2
;bar 4----------------------------------------------------------------------------------
i15   29.000   1.150   6500   490.500   1.000   0.120   0.100   5   2
i15   29.950   1.250   5500   558.080   1.000   0.120   0.100   5   2
i15   31.000   2.500   4500   470.080   1.000   0.140   0.100   5   2

;reverb---------------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1       32.5   1.5       .08       1.0
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
