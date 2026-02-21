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
; english.sco (in the woodwind subdirectory on the CD-ROM)
; English horn solo at the opening of
; Dvorak's New World Symphony, second movement

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f42 0 16384 -17 0 0 258 1 344 2 473 3 669 4                                   ; english horn wavetables
f43 0 64 -2 44 45 46 5.880 47 48 49 4.822 50 51 52 2.938 53 54 4 5.112 55 56 4 1.095
f44 0 4097 -9 2 1.357 0 3 0.420 0 
f45 0 4097 -9 4 1.919 0 5 1.618 0 6 0.722 0 7 0.294 0 
f46 0 4097 -9 8 0.419 0 9 0.118 0 10 0.061 0 12 0.021 0 14 0.047 0 15 0.105 0 16 0.066 0 17 0.039 0 22 0.033 0 24 0.025 0 
f47 0 4097 -9 2 0.815 0 3 1.060 0 
f48 0 4097 -9 4 2.523 0 5 0.516 0 6 0.166 0 7 0.260 0 
f49 0 4097 -9 8 0.089 0 9 0.082 0 10 0.021 0 11 0.083 0 12 0.079 0 13 0.122 0 14 0.032 0 15 0.081 0 16 0.046 0 
f50 0 4097 -9 2 1.792 0 3 0.571 0 
f51 0 4097 -9 4 0.218 0 5 0.074 0 7 0.043 0 
f52 0 4097 -9 8 0.061 0 9 0.053 0 10 0.066 0 12 0.021 0 
f53 0 4097 -9 2 3.304 0 3 1.480 0 
f54 0 4097 -9 4 0.111 0 5 0.023 0 6 0.087 0 7 0.050 0 
f55 0 4097 -9 2 0.284 0 3 0.077 0 
f56 0 4097 -9 5 0.020 0 

t0 52 8 54 16 52 20 52 28 50 
;p1   p2       p3      p4      p5        p6      p7      p8      p9  p10
;     start    dur     amp     Hertz     vibr    att     dec     br  in#
;bar 11----------------------------------------------------------------------------
i15    1.000   0.850   10000   470.080   0.450   0.100   0.100   5   4
i15    1.750   0.350   10500   558.080   0.450   0.100   0.100   5   4
i15    2.000   1.100   11000   558.080   0.450   0.100   0.100   5   4
i15    3.000   0.600   11500   523.200   0.450   0.100   0.100   5   4
i15    3.500   0.600   12000   418.560   0.450   0.100   0.100   5   4
i15    4.000   1.050   12500   470.080   0.450   0.100   0.100   5   4
;bar 12----------------------------------------------------------------------------
i15    5.000   0.600   12000   470.080   0.450   0.100   0.100   5   4
i15    5.500   0.600   11500   558.080   0.450   0.100   0.100   5   4
i15    6.000   0.600   11000   523.200   0.450   0.100   0.100   5   4
i15    6.500   0.600   10500   418.560   0.450   0.100   0.100   5   4
i15    7.000   2.000   10000   470.080   0.450   0.100   0.100   5   4
;bar 13----------------------------------------------------------------------------
i15    9.000   0.850   10500   470.080   0.450   0.100   0.100   5   4
i15    9.750   0.350   11000   558.080   0.450   0.100   0.100   5   4
i15   10.000   1.100   11500   558.080   0.450   0.100   0.100   5   4
i15   11.000   0.600   12000   523.200   0.450   0.100   0.100   5   4
i15   11.500   0.600   12500   418.560   0.450   0.100   0.100   5   4
i15   12.000   1.050   13000   470.080   0.450   0.100   0.100   5   4
;bar 14----------------------------------------------------------------------------
i15   13.000   0.600   13500   470.080   0.450   0.100   0.100   5   4
i15   13.500   0.600   12500   558.080   0.450   0.100   0.100   5   4
i15   14.000   0.600   11500   523.200   0.450   0.100   0.100   5   4
i15   14.500   0.600   10500   418.560   0.450   0.100   0.100   5   4
i15   15.000   2.000   10000   470.080   0.450   0.100   0.100   5   4
;bar 15----------------------------------------------------------------------------
i15   17.000   0.850    9000   348.800   0.450   0.100   0.100   5   4
i15   17.750   0.350    9200   418.560   0.450   0.100   0.100   5   4
i15   18.000   1.100    9400   418.560   0.450   0.100   0.100   5   4
i15   19.000   0.600    9200   348.800   0.450   0.100   0.100   5   4
i15   19.500   0.600    5600   313.920   0.450   0.100   0.100   4   4
i15   20.000   1.050    6000   279.040   0.450   0.100   0.100   4   4
;bar 16----------------------------------------------------------------------------
i15   21.000   0.850    6600   313.920   0.450   0.100   0.100   5   4
i15   21.750   0.350    9200   348.800   0.450   0.100   0.100   5   4
i15   22.000   0.850    9400   418.560   0.450   0.100   0.100   5   4
i15   22.750   0.350    9600   348.800   0.450   0.100   0.100   4   4
i15   23.000   2.000    7400   313.920   0.450   0.100   0.100   4   4
;bar 17----------------------------------------------------------------------------
i15   25.000   0.850   10000   348.800   0.450   0.100   0.100   5   4
i15   25.750   0.350    9000   418.560   0.450   0.100   0.100   5   4
i15   26.000   1.100    8800   418.560   0.450   0.100   0.100   5   4
i15   27.000   0.850    8500   558.080   0.450   0.100   0.100   5   4
i15   27.750   0.320   10000   627.840   0.450   0.100   0.100   6   4
i15   28.000   1.050   12000   697.600   0.450   0.100   0.100   6   4
;bar 18----------------------------------------------------------------------------
i15   29.000   0.850    8200   627.840   0.450   0.100   0.100   6   4
i15   29.750   0.350    8800   558.080   0.450   0.100   0.100   5   4
i15   30.000   0.600    9000   627.840   0.450   0.100   0.100   5   4
i15   30.500   0.600    9500   470.080   0.450   0.100   0.100   5   4
i15   31.000   2.000   10000   558.080   0.450   0.100   0.100   5   4

;reverb----------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.0     32     1.5       .1        1.0
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
