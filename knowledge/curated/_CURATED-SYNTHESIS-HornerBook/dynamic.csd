<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;______________________________________________________________________________________________________
; custom.orc - general wavetable wind instrument with custom pitch in Octave.Pitch Class
; (in the pitch subdirectory on the CD-ROM)

sr        =       22050
kr        =       2205
ksmps     =       10
nchnls    =       1

giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
instr 7                               ; general wind instrument with custom pitch in Octave.Pitch Class
; parameters
; p4 overall amplitude scaling factor
; p5 custom pitch in Octave.Pitch Class
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
ipitch    =       frac(p5)                                  ; fractional part from octave.pitch class 
ioct      =       int(p5)                                   ; integer part from octave.pitch class 
ivibfac   =       p6                                        ; percent vibrato depth
iatt      =       p7                                        ; attack time
idec      =       p8                                        ; decay time
ibrite    tablei  p9, 2                                     ; lowpass filter cutoff frequency
itablno   table   p10, 3                                    ; select first wavetable number for this
                                                            ; instrument (in table 3)
;octave
ifreq     =       0
ifreq     =       (ioct =  4 ?   16.35 : ifreq)   ; C0
ifreq     =       (ioct =  5 ?   32.7  : ifreq)   ; C1
ifreq     =       (ioct =  6 ?   65.4  : ifreq)   ; C2
ifreq     =       (ioct =  7 ?  130.8  : ifreq)   ; C3
ifreq     =       (ioct =  8 ?  261.6  : ifreq)   ; C4
ifreq     =       (ioct =  9 ?  523.2  : ifreq)   ; C5
ifreq     =       (ioct = 10 ? 1046.4  : ifreq)   ; C6
ifreq     =       (ioct = 11 ? 2092.8  : ifreq)   ; C7
ifreq     =       (ioct = 12 ? 4185.6  : ifreq)   ; C8
ifreq     =       (ioct = 13 ? 8371.2  : ifreq)   ; C9

;pitch (1/1 is the default)
ifreq     =       (ipitch >= .005 && ipitch < .015 ? ifreq * 1.0667  : ifreq)   ; 16/15
ifreq     =       (ipitch >= .015 && ipitch < .025 ? ifreq * 1.125   : ifreq)   ; 9/8
ifreq     =       (ipitch >= .025 && ipitch < .035 ? ifreq * 1.2     : ifreq)   ; 6/5
ifreq     =       (ipitch >= .035 && ipitch < .045 ? ifreq * 1.25    : ifreq)   ; 5/4
ifreq     =       (ipitch >= .045 && ipitch < .055 ? ifreq * 1.3333  : ifreq)   ; 4/3
ifreq     =       (ipitch >= .055 && ipitch < .065 ? ifreq * 1.4     : ifreq)   ; 7/5
ifreq     =       (ipitch >= .065 && ipitch < .075 ? ifreq * 1.5     : ifreq)   ; 3/2
ifreq     =       (ipitch >= .075 && ipitch < .085 ? ifreq * 1.6     : ifreq)   ; 8/5
ifreq     =       (ipitch >= .085 && ipitch < .095 ? ifreq * 1.6667  : ifreq)   ; 5/3
ifreq     =       (ipitch >= .095 && ipitch < .105 ? ifreq * 1.8     : ifreq)   ; 9/5
ifreq     =       (ipitch >= .105 && ipitch < .115 ? ifreq * 1.875   : ifreq)   ; 15/8

ivibd     =       abs(ivibfac*ifreq/100.0)      ; calculate vibrato depth relative to fundamental freq

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
; dynamic.sco - use with season.orc (in the season subdirectory on the CD-ROM)
; Ayers - opening to hot breath of wind, part 3

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f93 0 16384 -17 0 0 86 1 129 2 194 3 291 4 436 5                              ; bassoon wavetables
f94 0 64 -2 95 96 97 11.900 98 99 100 18.823 101 102 103 18.635 104 105 106 5.404 107 108 109 5.624 110 111 4 2.081
f95 0 4097 -9 2 1.339 0 3 1.324 0 
f96 0 4097 -9 4 1.567 0 5 1.602 0 6 1.777 0 7 1.143 0 
f97 0 4097 -9 8 0.746 0 9 1.231 0 10 1.618 0 11 0.823 0 12 0.572 0 13 0.282 0 14 0.421 0 15 0.419 0 16 0.470 0 17 0.126 0 18 0.722 0 19 0.609 0 20 0.402 0 21 0.273 0 22 0.272 0 23 0.351 0 24 0.152 0 25 0.087 0 26 0.067 0 27 0.189 0 28 0.172 0 29 0.227 0 30 0.152 0 31 0.114 0 32 0.060 0 33 0.059 0 34 0.069 0 35 0.084 0 36 0.073 0 37 0.054 0 38 0.025 0 39 0.038 0 40 0.070 0 41 0.064 0 42 0.055 0 43 0.032 0 44 0.027 0 45 0.051 0 46 0.034 0 47 0.041 0 48 0.056 0 49 0.026 0 53 0.024 0  
f98 0 4097 -9 2 1.348 0 3 2.896 0 
f99 0 4097 -9 4 4.100 0 5 6.159 0 6 3.342 0 7 0.109 0 
f100 0 4097 -9 8 1.577 0 9 0.756 0 10 0.745 0 11 0.781 0 12 1.175 0 13 1.204 0 14 0.572 0 15 1.003 0 16 0.430 0 17 0.166 0 18 0.488 0 19 0.212 0 20 0.142 0 21 0.077 0 22 0.047 0 23 0.059 0 24 0.094 0 25 0.048 0 26 0.041 0 27 0.035 0 28 0.022 0 29 0.062 0 30 0.167 0 31 0.200 0 32 0.100 0 33 0.037 0 34 0.023 0 36 0.061 0 37 0.030 0 38 0.100 0 39 0.125 0 40 0.098 0 41 0.053 0 42 0.073 0 43 0.073 0 44 0.063 0 45 0.046 0 47 0.030 0 48 0.042 0 
f101 0 4097 -9 2 6.037 0 3 6.737 0 
f102 0 4097 -9 4 6.752 0 5 1.300 0 6 0.536 0 7 0.339 0 
f103 0 4097 -9 8 1.719 0 9 1.347 0 10 0.866 0 11 0.753 0 12 0.238 0 13 0.346 0 14 0.169 0 15 0.190 0 16 0.063 0 17 0.084 0 18 0.258 0 19 0.181 0 20 0.076 0 21 0.069 0 22 0.087 0 23 0.085 0 24 0.116 0 25 0.107 0 26 0.195 0 27 0.096 0 28 0.086 0 29 0.093 0 30 0.036 0 31 0.074 0 32 0.052 0 33 0.052 0 34 0.040 0 35 0.046 0 36 0.039 0 
f104 0 4097 -9 2 3.912 0 3 1.245 0 
f105 0 4097 -9 4 0.301 0 5 0.537 0 6 0.827 0 7 0.161 0 
f106 0 4097 -9 8 0.258 0 9 0.205 0 10 0.129 0 11 0.060 0 12 0.080 0 13 0.131 0 14 0.094 0 15 0.054 0 16 0.057 0 17 0.061 0 18 0.054 0 19 0.026 0 20 0.021 0 21 0.024 0 22 0.024 0 
f107 0 4097 -9 2 4.071 0 3 1.026 0 
f108 0 4097 -9 4 0.618 0 5 0.186 0 6 0.153 0 7 0.026 0 
f109 0 4097 -9 8 0.056 0 9 0.070 0 10 0.040 0 11 0.026 0 12 0.026 0 
f110 0 4097 -9 2 0.759 0 3 0.568 0 
f111 0 4097 -9 4 0.374 0 5 0.052 0 

;p1    p2      p3      p4     p5   p6     p7     p8        p9      p10     p11    p12  p13
;      start   dur     amp1   tim1 amp2   amp3   Hertz     vibr    att     dec    br   inst
i103   1.000   2.600   1500   .1   4000   1500   173.827   0.050   0.030   0.090   7   7
i103   3.500   3.300   1500   .8   3000   1000   220       2.000   0.090   0.100   7   7

i103   7.000   0.600   1500   .5   3000   4500   173.827   0.050   0.030   0.090   7   7
i103   7.500   5.300   6000   .1   3000   1000   234.667   2.000   0.090   0.300   7   7

;reverb------------------------------------------------------------------
;p1    p2  p3   p4       p5       p6
;      st  dur  revtime  %reverb  gain
i194   0   13   1.5      .15      1.0
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
