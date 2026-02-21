<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; sternote.orc (in the noteffct subdirectory on the CD-ROM)

; instr 172 - general wavetable wind instrument with fixed location stereo
; instr 197 - global stereo reverb

giseed    =       .5
giwtsin   =       1
garevl    init    0
garevr    init    0
;______________________________________________________________________________________________________
instr 172                                                    ; general wind instrument with fixed stereo
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
; p11 fixed stereo location (1 is full left, 0 is full right, and .5 is center)
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
ileft     =       p11                                       ; percent left channel
iright    =       1 - ileft                                 ; right channel remaining percent

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
;___________________________________________________________; fixed location stereo
asigl     =       ileft * asig                              ; signal for left channel
asigr     =       iright * asig                             ; signal for right channel
garevl    =       asigl + garevl                            ; send signals to global stereo reverb
garevr    =       asigr + garevr
;         outs    asigl, asigr                              ; DO NOT OUTPUT signals
          endin
;______________________________________________________________________________________________________
instr 197                                                   ; global stereo reverb instrument
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

left:
acl1      comb    garevl, irevtime, .0297                   ; reverberate the left global signal
acl2      comb    garevl, irevtime, .0371
acl3      comb    garevl, irevtime, .0411
acl4      comb    garevl, irevtime, .0437
acombl    =       acl1 + acl2 + acl3 + acl4
apl       alpass  acombl, .09683, .005
arevl     alpass  apl, 03292, .0017
asigl     =       (iacoustic * garevl) + (ireverb * arevl)  ; mix the left signal

right:
acr1      comb    garevr, irevtime, .0297                   ; reverberate the right global signal
acr2      comb    garevr, irevtime, .0371
acr3      comb    garevr, irevtime, .0411
acr4      comb    garevr, irevtime, .0437
acombr    =       acr1 + acr2 + acr3 + acr4
apr       alpass  acombr, .09683, .005
arevr     alpass  apr, 03292, .0017
asigr     =       (iacoustic * garevr) + (ireverb * arevr)  ; mix the right signal

          outs    asigl * igain, asigr * igain              ; attenuate and output the stereo signal
garevl    =       0                                         ; set garevs to 0 to prevent feedback
garevr    =       0
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; sternote.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific fixed location stereo example (with horn)
; Maher Symphony #4 last movement - marking 7

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

f275 0 2048 -17 0 0 85 1 114 2 153 3 204 4 272 5 364 6 486 7                  ; horn wavetables
f276 0 64 -2 277 278 279 52.476 280 281 282 18.006 283 284 285 11.274 286 287 288 6.955 289 290 291 2.260 292 293 4 1.171 294 295 4 1.106 296 4 4 1.019 
f277 0 4097 -9 2 6.236 0 3 12.827 0 
f278 0 4097 -9 4 21.591 0 5 11.401 0 6 3.570 0 7 2.833 0 
f279 0 4097 -9 8 3.070 0 9 1.053 0 10 0.773 0 11 1.349 0 12 0.819 0 13 0.369 0 14 0.362 0 15 0.165 0 16 0.124 0 18 0.026 0 19 0.042 0 
f280 0 4097 -9 2 3.236 0 3 6.827 0 
f281 0 4097 -9 4 5.591 0 5 2.401 0 6 1.870 0 7 0.733 0 
f282 0 4097 -9 8 0.970 0 9 0.553 0 10 0.373 0 11 0.549 0 12 0.319 0 13 0.119 0 14 0.092 0 15 0.045 0 16 0.034 0 
f283 0 4097 -9 2 5.019 0 3 4.281 0 
f284 0 4097 -9 4 2.091 0 5 1.001 0 6 0.670 0 7 0.233 0 
f285 0 4097 -9 8 0.200 0 9 0.103 0 10 0.073 0 11 0.089 0 12 0.059 0 13 0.029 0 
f286 0 4097 -9 2 4.712 0 3 1.847 0 
f287 0 4097 -9 4 0.591 0 5 0.401 0 6 0.270 0 7 0.113 0 
f288 0 4097 -9 8 0.060 0 9 0.053 0 10 0.023 0  
f289 0 4097 -9 2 1.512 0 3 0.247 0 
f290 0 4097 -9 4 0.121 0 5 0.101 0 6 0.030 0 7 0.053 0 
f291 0 4097 -9 8 0.030 0  
f292 0 4097 -9 2 0.412 0 3 0.087 0 
f293 0 4097 -9 4 0.071 0 5 0.021 0  
f294 0 4097 -9 2 0.309 0 3 0.067 0
f295 0 4097 -9 4 0.031 0   
f296 0 4097 -9 2 0.161 0 3 0.047 0

t0 104
;p1  p2    p3    p4    p5      p6    p7    p8   p9 10 p11
;    start dur   amp   Hertz   vibr  att   dec  br in left
;bar 1-----------------------------------------------------
i172 1.000 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.053
i172 1.000 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.914
i172 1.100 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.827
i172 1.500 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.302
i172 1.500 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.631
i172 1.600 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.785
i172 2.000 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.230
i172 2.000 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.011
i172 2.100 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.567
i172 2.500 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.350
i172 2.500 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.307
i172 2.600 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.339
i172 3.000 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.929
i172 3.000 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.216
i172 3.100 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.479
i172 3.500 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.703
i172 3.500 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.699
i172 3.600 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.090
i172 4.000 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.440
i172 4.000 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.926
i172 4.100 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.032
i172 4.500 0.300 10000 372.053 0.000 0.020 0.040 9 16 0.329
i172 4.500 0.150 10000 392.400 0.000 0.020 0.030 9 16 0.682
i172 4.600 0.200 10000 245.250 0.000 0.020 0.040 9 16 0.764

;stereo reverb---------------------------------------------
;p1  p2    p3  p4      p5      p6
;    start dur revtime %reverb gain
i197 0.5   5   1.5     .05     1.0
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
