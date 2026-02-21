<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; combnot2.orc (in the noteffct subdirectory on the CD-ROM)

; instr 159 - general wavetable wind instrument with comb filter 2
; instr 194 - global reverb

giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
instr 159                                                   ; general wind instrument with comb filter 2
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
; p11 attenuation factor for the comb filtered signal
; p12 frequency of the comb filter
; p13 ring time for comb filter
; p14 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p15 initial highpass filter cutoff frequency
; p16 ending highpass filter cutoff frequency
; p17 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p18 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
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
iattn     =       p11                                       ; set attenuation for output signal
icfreq    =       p12                                       ; frequency for comb filter
iring     =       p13                                       ; set ring time for comb filter
icomb     =       p14                                       ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
p3        =       p3 + 2*iring                              ; extend duration to avoid early cutoff
iloop     =       1/icfreq                                  ; loop time (loop time is 1/freq)
ifilt1    =       p15                                       ; initial HP filter cutoff frequency
ifilt2    =       p16                                       ; ending filter cutoff frequency
p17       =       (p17 <= 0 ? .001 : p17)                   ; check for 0 values and fix them
p18       =       (p18 <= 0 ? .001 : p18)                   ; check for 0 values and fix them
iwait     =       p17 * idur                                ; duration of wait before cutoff gliss
igliss    =       p18 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb2a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb2a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note

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
;___________________________________________________________; comb filter 2
ainput    =       asig                                      ; set ainput to original signal
kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   ainput,kfreq                              ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,ainput                             ; balance amplitude
acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       iattn*(iorig*ainput) + (icomb*acomb)

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
; combnot2.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific comb filter 2 example (with contrabassoon)

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f111 0 16384 -17 0 0 42 1 57 2 76 3 101 4 136 5                               ; contrabassoon wavetables
f112 0 64 -2 113 114 115 254 116 117 118 15.412 119 120 121 70.299 122 123 124 35.023 125 126 127 22.423 128 129 130 12.339
f113 0 4097 -9 2 14.555 0 3 25.859 0 
f114 0 4097 -9 4 25.932 0 5 55.018 0 6 61.778 0 7 9.391 0 
f115 0 4097 -10 0 0 0 0 0 0 0 62.144 15.432 7.345 12.448 4.482 8.831 20.487 7.613 2.144 4.507 8.246 2.850 2.192 0.487 0.719 1.145 0.719 1.681 1.608 0.743 0.378 0.499 1.864 1.742 1.620 1.048 0.390 0.865 0.414 0.329 0.414 0.037 0.097 0.146 0.597 0.365 0.256 0.938 0.585 0.378 0.207 0.292 0.280 0.341 0.719 0.365 0.499 0.414 0.402 0.305 0.475 0.122 0.122 0.171 0.122 0.183 0.037 0.171 0.073 0.134 0.146 0.134 0.073 0.000 0.256 0.158 0.122 0.171 0.158 0.207 0.097 0.146 0.037 0.317 0.219 0.073 0.256 0.085 0.122 0.122 0.085 0.012 0.061 0.024 0.097 0.122 0.012 0.158 0.183 0.073 0.122 0.122 0.158 0.183 0.183 0.195 0.280 0.171 0.097 0.110 0.122 0.110 0.122 0.219 0.183 0.183 0.219 0.183 0.158 0.231 0.219 0.268 0.219 0.183 0.231 0.183 0.195 0.085 0.097 0.110 0.085 0.049 0.024 0.061 0.097 0.085 0.037 0.122 0.097 0.061 0.183 0.073 0.146 0.024 0.219 0.146 0.085 0.158 0.097 0.134 0.061 0.073 0.097 0.073 0.049 0.085 0.061 0.049 0.097 0.110 0.073 0.049 0.061 0.037 0.061 0.097 0.085 0.061 0.085 0.085 0.049 0.097 0.085 0.085 0.049 0.012 0.049 0.037 0.037 0.012 0.024 0.024 0.024 0.073 0.024 0.024 0.037 0.061 0.061 0.037 0.085 0.061 0.037 0.037 0.049 0.049 0.012 0.012 0.024 0.012 
f116 0 4097 -9 2 1.575 0 3 1.889 0 
f117 0 4097 -9 4 4.725 0 5 1.501 0 6 6.094 0 7 0.271 0 
f118 0 4097 -10 0 0 0 0 0 0 0 0.104 0.132 1.420 0.796 0.806 0.951 1.587 0.342 0.153 0.030 0.580 0.627 0.289 0.194 0.098 0.114 0.138 0.193 0.188 0.188 0.084 0.005 0.022 0.066 0.073 0.150 0.130 0.094 0.031 0.069 0.098 0.107 0.039 0.114 0.019 0.021 0.015 0.018 0.008 0.008 0.018 0.017 0.028 0.017 0.027 0.018 0.028 0.018 0.027 0.035 0.018 0.008 0.032 0.037 0.008 0.012 0.027 0.028 0.015 0.006 0.017 0.008 0.005 0.019 0.006 0.006 0.010 0.023 0.031 0.014 0.030 0.026 0.019 0.017 0.018 0.028 0.023 0.024 0.021 0.009 0.018 0.028 0.013 0.018 0.012 0.017 0.027 0.012 0.006 
f119 0 4097 -9 2 7.873 0 3 9.447 0 
f120 0 4097 -9 4 23.625 0 5 7.506 0 6 30.469 0 7 1.356 0 
f121 0 4097 -10 0 0 0 0 0 0 0 0.521 0.662 7.102 3.978 0.765 1.632 1.967 4.749 0.868 0.572 0.424 0.469 0.540 0.405 0.829 1.215 0.604 0.720 0.617 0.514 0.758 0.225 0.231 0.148 0.276 0.315 0.167 0.360 0.270 0.051 0.051 0.154 0.064 0.103 0.116 0.064
f122 0 4097 -9 2 8.036 0 3 11.208 0 
f123 0 4097 -9 4 5.508 0 5 1.684 0 6 0.464 0 7 5.992 0 
f124 0 4097 -10 0 0 0 0 0 0 0 5.732 2.540 3.028 2.852 1.680 1.556 0.628 0.644 0.280 0.340 0.288 0.220 0.668 0.676 0.460 0.000 0.404 0.228 0.116 0.176 0.104 0.124
f125 0 4097 -9 2 3.566 0 3 4.243 0 
f126 0 4097 -9 4 7.499 0 5 2.625 0 6 7.361 0 7 0.622 0 
f127 0 4097 -10 0 0 0 0 0 0 0 0.513 0.226 0.402 0.598 0.707 0.390 0.217 0.070 0.038 0.050 0.132 0.185 0.141 0.053 0.047 0.023 0.009 0.009 0.035 0.012 
f128 0 4097 -9 2 6.144 0 3 4.640 0 
f129 0 4097 -9 4 1.257 0 5 1.976 0 6 0.378 0 7 0.399 0 
f130 0 4097 -9 8 0.241 0 9 0.487 0 10 0.096 0 11 0.077 0 12 0.189 0 13 0.050 0 14 0.268 0 15 0.048 0 16 0.027 0 17 0.155 0 18 0.081 0 19 0.054 0 20 0.110 0 21 0.050 0 22 0.041 0 23 0.020 0 24 0.039 0 

t0 100
;p1  p2     p3  p4   p5     p6    p7    p8   p9 10 p11  p12    p13  p14  p15   p16   p17  p18
;    start  dur amp  Hertz  vibr  att   dec  br in attn cmbFr  ring %cmb filt1 filt2 wait gls 
i159  1.000  5  3000 139.52 1.000 0.230 0.100 5 8  .20  139.52 .3   .25   880  7040  .1   .4
i159  5.000 10  5000  69.76 1.000 0.230 0.100 5 8  .25  139.52 .3   .25  7040   880  .1   .4
i159  7.000  5  5000 104.14 1.000 0.230 0.100 5 8  .25  312.42 .3   .25  3520   440  .2   .5
i159  9.000  6  5000  87.20 1.000 0.230 0.100 5 8  .35  384.80 .3   .25  1760  1760  .2   .4
i159 13.100  6  3000 122.08 1.000 0.130 0.100 5 8  .20  610.40 .3   .25  1760   220  .1   .4

;reverb---------------------------------------------------------------------------------------
;p1 p2     p3  p4      p5      p6
;    start dur revtime %reverb gain
i194 0.5   21  1.5     .05     1.0
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
