<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; phasnote.orc (in the noteffct subdirectory on the CD-ROM)

; instr 155 - general wavetable wind instrument with phasing
; instr 194 - global reverb


giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
instr 155                                                   ; general wind instrument with phasing
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
; p11 offset from the original frequency for phased signals 
;         should be near zero (e.g., in the range of .01 - .08)
; p12 phasing switch: 0=output original signal only (without phasing), 1=output phased signal
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
ioff1     =       p11
ioff2     =       2 * ioff1
ioff3     =       3 * ioff1
ioff4     =       4 * ioff1
iswitch   =       p12                                       ; switch between normal tone and phasing

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
;___________________________________________________________; wavetable lookup with phasing
          if iswitch > 0 goto dophasing
awt1      oscili  amp1, kfreq, iwt1, iphase        
awt2      oscili  amp2, kfreq, iwt2, iphase
awt3      oscili  amp3, kfreq, iwt3, iphase
awt4      oscili  amp4, kfreq, iwt4, iphase
          goto    finish

dophasing:
awt1a     oscili  amp1, kfreq, iwt1, iphase
awt1b     oscili  amp1, kfreq+ioff1, iwt1, iphase
awt1c     oscili  amp1, kfreq+ioff2, iwt1, iphase
awt1d     oscili  amp1, kfreq+ioff3, iwt1, iphase
awt1e     oscili  amp1, kfreq+ioff4, iwt1, iphase
awt1f     oscili  amp1, kfreq-ioff1, iwt1, iphase
awt1g     oscili  amp1, kfreq-ioff2, iwt1, iphase
awt1h     oscili  amp1, kfreq-ioff3, iwt1, iphase
awt1i     oscili  amp1, kfreq-ioff4, iwt1, iphase
awt1      =       (awt1a+awt1b+awt1c+awt1d+awt1e+awt1f+awt1g+awt1h+awt1i)/9

awt2a     oscili  amp2, kfreq, iwt2, iphase
awt2b     oscili  amp2, kfreq+ioff1, iwt2, iphase
awt2c     oscili  amp2, kfreq+ioff2, iwt2, iphase
awt2d     oscili  amp2, kfreq+ioff3, iwt2, iphase
awt2e     oscili  amp2, kfreq+ioff4, iwt2, iphase
awt2f     oscili  amp2, kfreq-ioff1, iwt2, iphase
awt2g     oscili  amp2, kfreq-ioff2, iwt2, iphase
awt2h     oscili  amp2, kfreq-ioff3, iwt2, iphase
awt2i     oscili  amp2, kfreq-ioff4, iwt2, iphase
awt2      =       (awt2a+awt2b+awt2c+awt2d+awt2e+awt2f+awt2g+awt2h+awt2i)/9

awt3a     oscili  amp3, kfreq, iwt3, iphase
awt3b     oscili  amp3, kfreq+ioff1, iwt3, iphase
awt3c     oscili  amp3, kfreq+ioff2, iwt3, iphase
awt3d     oscili  amp3, kfreq+ioff3, iwt3, iphase
awt3e     oscili  amp3, kfreq+ioff4, iwt3, iphase
awt3f     oscili  amp3, kfreq-ioff1, iwt3, iphase
awt3g     oscili  amp3, kfreq-ioff2, iwt3, iphase
awt3h     oscili  amp3, kfreq-ioff3, iwt3, iphase
awt3i     oscili  amp3, kfreq-ioff4, iwt3, iphase
awt3      =       (awt3a+awt3b+awt3c+awt3d+awt3e+awt3f+awt3g+awt3h+awt3i)/9

awt4a     oscili  amp4, kfreq, iwt4, iphase
awt4b     oscili  amp4, kfreq+ioff1, iwt4, iphase
awt4c     oscili  amp4, kfreq+ioff2, iwt4, iphase
awt4d     oscili  amp4, kfreq+ioff3, iwt4, iphase
awt4e     oscili  amp4, kfreq+ioff4, iwt4, iphase
awt4f     oscili  amp4, kfreq-ioff1, iwt4, iphase
awt4g     oscili  amp4, kfreq-ioff2, iwt4, iphase
awt4h     oscili  amp4, kfreq-ioff3, iwt4, iphase
awt4i     oscili  amp4, kfreq-ioff4, iwt4, iphase
awt4      =       (awt4a+awt4b+awt4c+awt4d+awt4e+awt4f+awt4g+awt4h+awt4i)/9

finish:
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
; phasnote.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific phasing example (with flute and oboe)

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

f29 0 16384 -17 0 0 355 1 503 2 888 3                                         ; oboe wavetables
f30 0 64 -2 31 32 33 4.683 34 35 36 6.794 37 38 39 3.331 40 41 4 1.369
f31 0 4097 -9 2 0.929 0 3 0.953 0 
f32 0 4097 -9 4 0.881 0 5 1.443 0 6 0.676 0 7 0.257 0 
f33 0 4097 -9 8 0.198 0 9 0.100 0 10 0.081 0 11 0.113 0 12 0.049 0 13 0.092 0 14 0.071 0 15 0.038 0 
f34 0 4097 -9 2 1.460 0 3 2.713 0 
f35 0 4097 -9 4 1.360 0 5 1.192 0 6 0.615 0 7 0.256 0 
f36 0 4097 -9 8 0.228 0 9 0.320 0 10 0.158 0 11 0.063 0 12 0.039 0 13 0.062 0 14 0.047 
f37 0 4097 -9 2 1.386 0 3 1.370 0 
f38 0 4097 -9 4 0.360 0 5 0.116 0 6 0.106 0 7 0.201 0 
f39 0 4097 -9 8 0.037 0 9 0.019 0 
f40 0 4097 -9 2 0.646 0 3 0.034 0 
f41 0 4097 -9 4 0.136 0 5 0.026 0 

t0 100
; flute timbre
;p1  p2     p3  p4   p5      p6    p7    p8   p9 10 p11    12
;    start  dur amp  Hertz   vibr  att   dec  br in offset sw
i155  1.000 35  4000 558.080 1.000 0.230 0.100 5 2  .05    1
i155  5.000 20  5000 279.040 1.000 0.230 0.100 5 2  .04    1
i155 20.000 15  5000 837.120 1.000 0.230 0.100 5 2  .07    1
i155 26.000 26  5000 697.600 1.000 0.230 0.100 5 2  .025   1
i155 26.100 23  5000 976.640 1.000 0.230 0.100 5 2  .03    1
;reverb--------------------------------------------------------
;p1  p2    p3  p4      p5     p6
;    start dur revtime %revrb gain
i194 0.500 53  1.5     .05    1.0
s

; oboe timbre
;p1  p2     p3  p4   p5      p6    p7    p8   p9 10 p11    12
;    start  dur amp  Hertz   vibr  att   dec  br in offset sw
i155  1.000 35  4000 558.080 1.000 0.230 0.100 5 3  .05    1
i155  5.000 20  5000 279.040 1.000 0.230 0.100 5 3  .04    1
i155 20.000 15  5000 837.120 1.000 0.230 0.100 5 3  .07    1
i155 26.000 26  5000 697.600 1.000 0.230 0.100 5 3  .025   1
i155 26.100 23  5000 976.640 1.000 0.230 0.100 5 3  .03    1
i155 40.000 15  5000 558.080 1.000 0.230 0.100 5 3  .05    1
;reverb--------------------------------------------------------
;p1  p2    p3  p4      p5     p6
;    start dur revtime %revrb gain
i194 0.500 56  1.5     1.0    .1
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
