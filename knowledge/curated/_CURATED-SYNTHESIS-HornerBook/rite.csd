<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;______________________________________________________________________________________________________
; season.orc (in the season subdirectory on the CD-ROM)

; instr 15  - wind.orc instrument - used in grace.sco
; instr 102 - articulation instrument 
; instr 107 - dynamic levels and beat scaling instrument
; instr 103 - instrument with dynamic changes 
; instr 104 - slur instrument 
; instr 105 - trill instrument
; instr 106 - tremolo instrument
; instr 194 - reverb

sr        =       22050
kr        =       2205
ksmps     =       10
nchnls    =       1

gibaseamp =       1000                                      ; global base amplitudefor pp (i107)
giampfact =       1.5                                       ; global amplitude scaling factor (i107)
gibeatsc  =       .9                                        ; global beat scaling factor (i107)
giseed    =       .5
giwtsin   =       1
garev     init    0
;______________________________________________________________________________________________________
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
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
;______________________________________________________________________________________________________
instr 102                                          ; general wavetable wind instrument with articulation
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
; p11 articulation type (0=sustain, 1=cresc, 2=decr, 3=fp, 4=swell)
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
iartic    =       p11                                       ; articulation type
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
if iartic = 0 goto artic0
if iartic = 1 goto artic1
if iartic = 2 goto artic2
if iartic = 3 goto artic3
if iartic = 4 goto artic4
artic0:                         ; sustained articulation
amp1      linseg  0,.001,0,.5*iatt,.5,.5*iatt,.9,.5*isus,1,.5*isus,.9,.5*idec,.3,.5*idec,0,1,0   
goto articend
artic1:                         ; cresc. articulation
amp1      linseg  0,.001,0,.5*iatt,.2,.5*iatt,.5,.5*isus,.7,.4*isus,1,.1*isus,.9,.5*idec,.4,.5*idec,0,1,0
goto articend
artic2:                         ; decr. articulation
amp1      linseg  0,.001,0,.5*iatt,.6,.5*iatt,1,.5*isus,.7,.5*isus,.5,.5*idec,.2,.5*idec,0,1,0    
goto articend
artic3:                         ; fp articulation
amp1      linseg  0,.001,0,.5*iatt,.6,.5*iatt,1,.1*isus,.7,.4*isus,.5,.5*isus,.45,.5*idec,.2,.5*idec,0,1,0    
goto articend
artic4:                         ; swell articulation
amp1      linseg  0,.001,0,.5*iatt,.2,.5*iatt,.5,.5*isus,1,.5*isus,.5,.5*idec,.4,.5*idec,0,1,0    
articend:
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
;______________________________________________________________________________________________________

instr 107                    ; general wavetable wind instrument with dynamic levels and beat scaling
; parameters
; p4 dynamic level (0=ppp, 1=pp, 2=p, 3=mp, 4=mf, 5=f, 6=ff, 7=fff)
; p5 pitch in Hertz
; p6 percent vibrato depth, recommended values in range [0, 1]
;         0 = no vibrato, 1 = 1% vibrato depth
; p7 attack time in seconds, recommended values in range [.03, .1]
; p8 decay time in seconds, recommended values in range [.04, .2]
; p9 overall brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p10 wind instrument number (1 = piccolo, 2 = flute, etc.)
; p11 beat scaling (0=downbeat, 1=3rd beat, 2=2nd & 4th beats, 3=8th note offbeats, 4=16th note offbeats)
;___________________________________________________________; initial variables 
idur      =       p3                                        ; duration
idynam    =       p4                                        ; dynamic level
ibeat     =       p11                                       ; beat scaling level
iampsc    =       exp(idynam * log(giampfact))              ; convert dynamic level to amplitude
ibeatsc   =       exp(ibeat * log(gibeatsc))                ; convert beat scaling level to amplitude
iamp      =       gibaseamp * iampsc * ibeatsc              ; overall amplitude scaling factor
iamp      =       iamp * (.99 + giseed*.02)                 ; overall amplitude scaling factor +/- 1%
giseed    =       frac(giseed*105.947)
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
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
;______________________________________________________________________________________________________
instr 103                                      ; general wavetable wind instrument with dynamic changes
; parameters
; p4 initial amplitude scaling factor
; p5 percent duration of change from initial amplitude to intermediate amplitude 
; p6 intermediate amplitude scaling factor
; p7 ending amplitude scaling factor
; p8 pitch in Hertz
; p9 percent vibrato depth, recommended values in range [0, 1]
;         0 = no vibrato, 1 = 1% vibrato depth
; p10 attack time in seconds, recommended values in range [.03, .1]
; p11 decay time in seconds, recommended values in range [.04, .2]
; p12 overall brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p13 wind instrument number (1 = piccolo, 2 = flute, etc.)
;___________________________________________________________; initial variables 
idur      =       p3                                        ; duration
iamp1     =       p4                                        ; initial amplitude
p5        =       (p5 <= 0 ? .01 : p5)                      ; keep values between 0 and 1
p5        =       (p5 >= 1 ? .99 : p5)
itime1    =       p5 * p3                                   ; time for change from initial to middle amplitude
itime2    =       p3 - itime1                               ; time for change from middle to endling amplitude
iamp2     =       p6                                        ; intermediate amplitude
iamp3     =       p7                                        ; ending amplitude
adynam    linseg  iamp1,itime1,iamp2,itime2,iamp3,1,iamp3   ; overall dynamic change
ifreq     =       p8                                        ; pitch in Hertz
ivibd     =       abs(p9*ifreq/100.0)                       ; vibrato depth relative to fund. freq
iatt      =       p10                                       ; attack time
idec      =       p11                                       ; decay time
ibrite    tablei  p12, 2                                    ; lowpass filter cutoff frequency
itablno   table   p13, 3                                    ; select first wavetable number for this
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
asig      =       (awt1+awt2+awt3+awt4)*adynam/inorm
afilt     tone    asig, ibrite                              ; lowpass filter for brightness control
asig      balance afilt, asig
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
;______________________________________________________________________________________________________
instr 104               ; general wavetable wind instrument with dynamic changes & function table slurs
; parameters
; p4 initial amplitude scaling factor
; p5 percent duration of change from initial amplitude to intermediate amplitude 
; p6 intermediate amplitude scaling factor
; p7 ending amplitude scaling factor
; p8 pitch in Hertz
; p9 percent vibrato depth, recommended values in range [0, 1]
;         0 = no vibrato, 1 = 1% vibrato depth
; p10 attack time in seconds, recommended values in range [.03, .1]
; p11 decay time in seconds, recommended values in range [.04, .2]
; p12 overall brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p13 wind instrument number (1 = piccolo, 2 = flute, etc.)
; p14 function table number for slur
;___________________________________________________________; initial variables 
idur      =       p3                                        ; duration
iamp1     =       p4                                        ; initial amplitude
p5        =       (p5 <= 0 ? .01 : p5)                      ; keep values between 0 and 1
p5        =       (p5 >= 1 ? .99 : p5)
itime1    =       p5 * p3                                   ; time for change from initial to middle amplitude
itime2    =       p3 - itime1                               ; time for change from middle to ending amplitude
iamp2     =       p6                                        ; intermediate amplitude
iamp3     =       p7                                        ; ending amplitude
adynam    linseg  iamp1,itime1,iamp2,itime2,iamp3,1,iamp3   ; overall dynamic change
ifreq     =       p8                                        ; highest pitch in Hertz
ivibd     =       abs(p9*ifreq/100.0)                       ; vibrato depth relative to fund. freq
iatt      =       p10                                       ; attack time
idec      =       p11                                       ; decay time
ibrite    tablei  p12, 2                                    ; lowpass filter cutoff frequency
itablno   table   p13, 3                                    ; select first wavetable number for this
                                                            ; instrument (in table 3)
ifrtabl   =       p14                                       ; function table number for slur
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
kpctdur   phasor  1.0/p3                                    ; current time (in percentage of total duration)
kfreq     table   100*kpctdur, ifrtabl, 0                   ; frequency from frequency table
kfreq     =       kfreq + kvib
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
asig      =       (awt1+awt2+awt3+awt4)*adynam/inorm
afilt     tone    asig, ibrite                              ; lowpass filter for brightness control
asig      balance afilt, asig
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
;______________________________________________________________________________________________________
instr 105                                               ; general wavetable wind instrument with trills
; parameters
; p4 initial amplitude scaling factor
; p5 percent duration of change from initial amplitude to intermediate amplitude 
; p6 intermediate amplitude scaling factor
; p7 ending amplitude scaling factor
; p8 initial pitch in Hertz
; p9 ending pitch in Hertz
; p10 initial trill rate (in cycles/sec), recommended values in range [2, 10]
; p11 percent duration of change from initial to intermediate trill rate 
; p12 intermediate trill rate (in cycles/sec)
; p13 ending trill rate (in cycles/sec)
; p14 attack time in seconds, recommended values in range [.03, .1]
; p15 decay time in seconds, recommended values in range [.04, .2]
; p16 overall brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p17 wind instrument number (1 = piccolo, 2 = flute, etc.)
;___________________________________________________________; initial variables 
idur      =       p3                                        ; duration
iamp1     =       p4                                        ; initial amplitude
p5        =       (p5 <= 0 ? .01 : p5)                      ; keep values between 0 and 1
p5        =       (p5 >= 1 ? .99 : p5)
itime1    =       p5 * p3                                   ; time for change from initial to middle amplitude
itime2    =       p3 - itime1                               ; time for change from middle to ending amplitude
iamp2     =       p6                                        ; intermediate amplitude
iamp3     =       p7                                        ; ending amplitude
adynam    linseg  iamp1,itime1,iamp2,itime2,iamp3,1,iamp3   ; overall dynamic change
ifreq     =       p8                                        ; initial pitch in Hertz
ifreq2    =       p9                                        ; intermediate pitch in Hertz
ihighfr   =       (ifreq >= ifreq2 ? ifreq : ifreq2)        ; higher of two frequencies
itr1      =       p10                                       ; initial trill rate (in cycles/sec)
p11       =       (p11 <= 0 ? .01 : p11)                    ; keep values between 0 and 1
p11       =       (p11 >= 1 ? .99 : p11)
itime3    =       p11 * p3                                  ; time for change from initial to middle trill rate
itr2      =       p12                                       ; intermediate trill rate (in cycles/sec)
itr3      =       p13                                       ; ending trill rate (in cycles/sec)
iatt      =       p14                                       ; attack time
idec      =       p15                                       ; decay time
itime4    =       idur - iatt - itime3 - idec               ; time for change from middle to ending trill rate
ibrite    tablei  p16, 2                                    ; lowpass filter cutoff frequency
itablno   table   p17, 3                                    ; select first wavetable number for this
                                                            ; instrument (in table 3)
isus      =       idur - iatt - idec - .005                 ; sustain time
iphase    =       giseed                                    ; use same phase for all wavetables
giseed    =       frac(giseed*105.947)
;___________________________________________________________; range-specific variables
irange    table   ihighfr, itablno                          ; use higher frequency to determine range
itabl2    =       itablno + 1
iwt1      =       1                                         ; wavetable numbers
iwt2      table   (irange*4), itabl2
iwt3      table   (irange*4)+1, itabl2
iwt4      table   (irange*4)+2, itabl2
inorm     table   (irange*4)+3, itabl2                      ; normalization factor
;___________________________________________________________; trill block
ktrillrat linseg  0,iatt,itr1,itime3,itr2,itime4,itr3,idec,0,1,0 ; time-varying trill rate
ktrill    oscili  (ifreq2-ifreq), ktrillrat, 9, .5
kfreq     =       ifreq + ktrill
;___________________________________________________________; amplitude envelopes
amp1      linseg  0,.001,0,.5*iatt,.5,.5*iatt,.9,.5*isus,1,.5*isus,.9,.5*idec,.3,.5*idec,0,1,0
amp2      =       amp1 * amp1   
amp3      =       amp2 * amp1
amp4      =       amp3 * amp1
;___________________________________________________________; wavetable lookup
atra      oscili  1, ktrillrat, 9, 0      
awt1a     oscili  amp1*atra, kfreq, iwt1, iphase      
awt2a     oscili  amp2*atra, kfreq, iwt2, iphase
awt3a     oscili  amp3*atra, kfreq, iwt3, iphase
awt4a     oscili  amp4*atra, kfreq, iwt4, iphase
asiga     =       awt1a + awt2a + awt3a + awt4a

atrb      oscili  1, ktrillrat, 9, .5      
awt1b     oscili  amp1*atrb, kfreq, iwt1, iphase      
awt2b     oscili  amp2*atrb, kfreq, iwt2, iphase
awt3b     oscili  amp3*atrb, kfreq, iwt3, iphase
awt4b     oscili  amp4*atrb, kfreq, iwt4, iphase
asigb     =       awt1b + awt2b + awt3b + awt4b

asig      =       (asiga + asigb)*adynam/inorm
afilt     tone    asig, ibrite                              ; lowpass filter for brightness control
asig      balance afilt, asig
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
;______________________________________________________________________________________________________
instr 106                                              ; general wavetable wind instrument with tremolo
; parameters
; p4 initial amplitude scaling factor
; p5 percent duration of change from initial amplitude to intermediate amplitude 
; p6 intermediate amplitude scaling factor
; p7 ending amplitude scaling factor
; p8 initial pitch in Hertz
; p9 ending pitch in Hertz
; p10 initial tremolo rate (in cycles/sec), recommended values in range [2, 10]
; p11 percent duration of change from initial to intermediate tremolo rate 
; p12 intermediate tremolo rate (in cycles/sec)
; p13 ending tremolo rate (in cycles/sec)
; p14 attack time in seconds, recommended values in range [.03, .1]
; p15 decay time in seconds, recommended values in range [.04, .2]
; p16 initial brightness / filter cutoff factor 
;         1 -> least bright / lowest filter cutoff frequency (40 Hz)
;         9 -> brightest / highest filter cutoff frequency (10,240Hz)
; p17 ending brightness / filter cutoff factor 
; p18 wind instrument number (1 = piccolo, 2 = flute, etc.)
;___________________________________________________________; initial variables 
idur      =       p3                                        ; duration
iamp1     =       p4                                        ; initial amplitude
p5        =       (p5 <= 0 ? .01 : p5)                      ; keep values between 0 and 1
p5        =       (p5 >= 1 ? .99 : p5)
itime1    =       p5 * p3                                   ; time for change from initial to middle amplitude
itime2    =       p3 - itime1                               ; time for change from middle to ending amplitude
iamp2     =       p6                                        ; intermediate amplitude
iamp3     =       p7                                        ; ending amplitude
adynam    linseg  iamp1,itime1,iamp2,itime2,iamp3,1,iamp3   ; overall dynamic change
ifreq     =       p8                                        ; initial pitch in Hertz
ifreq2    =       p9                                        ; intermediate pitch in Hertz
ihighfr   =       (ifreq >= ifreq2 ? ifreq : ifreq2)        ; higher of two frequencies
itr1      =       p10                                       ; initial tremolo rate (in cycles/sec)
p11       =       (p11 <= 0 ? .01 : p11)                    ; keep values between 0 and 1
p11       =       (p11 >= 1 ? .99 : p11)
itime3    =       p11 * p3                                  ; time for change from initial to middle tremolo rate
itr2      =       p12                                       ; intermediate tremolo rate (in cycles/sec)
itr3      =       p13                                       ; ending tremolo rate (in cycles/sec)
iatt      =       p14                                       ; attack time
idec      =       p15                                       ; decay time
itime4    =       idur - iatt - itime3 - idec               ; time for change from middle to ending tremolo rate
ibrite    tablei  p16, 2                                    ; initial lowpass filter cutoff frequency
ibrite2   tablei  p17, 2                                    ; ending lowpass filter cutoff frequency
itablno   table   p18, 3                                    ; select first wavetable number for this
                                                            ; instrument (in table 3)
isus      =       idur - iatt - idec - .005                 ; sustain time
iphase    =       giseed                                    ; use same phase for all wavetables
giseed    =       frac(giseed*105.947)
;___________________________________________________________; range-specific variables
irange    table   ifreq, itablno                            ; frequency range of 1st note
itabl2    =       itablno + 1
iwt1      =       1                                         ; wavetable numbers
iwt2      table   (irange*4), itabl2
iwt3      table   (irange*4)+1, itabl2
iwt4      table   (irange*4)+2, itabl2
inorm1    table   (irange*4)+3, itabl2                      ; normalization factor

irange2   table   ifreq2, itablno                           ; frequency range of 2nd note
iwt12     table   (irange2*4), itabl2
iwt13     table   (irange2*4)+1, itabl2
iwt14     table   (irange2*4)+2, itabl2
inorm2    table   (irange2*4)+3, itabl2                     ; normalization factor
inorm     =       (inorm1 + inorm2)/2                       ; average normalization factor
;___________________________________________________________; tremolo block
ktremrat  linseg  0,iatt,itr1,itime3,itr2,itime4,itr3,idec,0,1,0 ; time-varying tremolo rate
ktrem     oscili  (ifreq2-ifreq), ktremrat, 9, .5
kfreq     =       ifreq + ktrem
;___________________________________________________________; amplitude envelopes
amp1      linseg  0,.001,0,.5*iatt,.5,.5*iatt,.9,.5*isus,1,.5*isus,.9,.5*idec,.3,.5*idec,0,1,0
amp2      =       amp1 * amp1   
amp3      =       amp2 * amp1
amp4      =       amp3 * amp1
;___________________________________________________________; wavetable lookup
atra      oscili  1, ktremrat, 9, 0      
awt1a     oscili  amp1*atra, kfreq, iwt1, iphase      
awt2a     oscili  amp2*atra, kfreq, iwt2, iphase
awt3a     oscili  amp3*atra, kfreq, iwt3, iphase
awt4a     oscili  amp4*atra, kfreq, iwt4, iphase
asiga     =       awt1a + awt2a + awt3a + awt4a
afilta    tone    asiga, ibrite                             ; lowpass filter for brightness control
asiga     balance afilta, asiga

atrb      oscili  1, ktremrat, 9, .5      
awt1b     oscili  amp1*atrb, kfreq, iwt1, iphase      
awt2b     oscili  amp2*atrb, kfreq, iwt12, iphase
awt3b     oscili  amp3*atrb, kfreq, iwt13, iphase
awt4b     oscili  amp4*atrb, kfreq, iwt14, iphase
asigb     =       awt1b + awt2b + awt3b + awt4b
afiltb    tone    asigb, ibrite2                            ; lowpass filter for brightness control
asigb     balance afiltb, asigb

asig      =       (asiga + asigb)*adynam/inorm
garev     =       garev + asig                              ; send signal to global reverberator
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
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
; rite.sco (in the woodwind subdirectory on the CD-ROM)
; Stravinsky - The Rite of Spring (opening)
; (use with wind.orc)

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

f57 0 16384 -17 0 0 181 1 259 2 363 3 501 4 685 5                             ; clarinet wavetables
f58 0 64 -2 59 60 61 1.933 62 63 64 1.546 65 66 67 2.965 68 69 70 3.096 71 72 73 1.019 74 75 4 1.221
f59 0 4097 -9 3 0.389 0 
f60 0 4097 -9 4 0.029 0 5 0.226 0 6 0.034 0 7 0.449 0 
f61 0 4097 -9 8 0.168 0 9 0.480 0 10 0.089 0 11 0.099 0 12 0.040 0 13 0.061 0 14 0.031 0 15 0.079 0 16 0.040 0 17 0.062 0 18 0.063 0 20 0.026 0 21 0.022 0 22 0.044 0 24 0.034 0 26 0.020 0 
f62 0 4097 -9 3 0.560 0 
f63 0 4097 -9 4 0.035 0 5 0.304 0 6 0.122 0 7 0.397 0 
f64 0 4097 -9 8 0.055 0 9 0.141 0 10 0.038 0 11 0.052 0 12 0.022 0 13 0.027 0 14 0.026 0 16 0.038 0 17 0.076 0 18 0.046 0 19 0.029 0 
f65 0 4097 -9 2 0.061 0 3 0.628 0 
f66 0 4097 -9 4 0.231 0 5 1.161 0 6 0.201 0 7 0.328 0 
f67 0 4097 -9 8 0.154 0 9 0.072 0 10 0.186 0 11 0.133 0 12 0.309 0 13 0.071 0 14 0.098 0 15 0.114 0 16 0.027 0 17 0.057 0 18 0.022 0 19 0.042 0 20 0.023 0 
f68 0 4097 -9 2 0.045 0 3 1.408 0 
f69 0 4097 -9 4 0.842 0 5 0.574 0 6 0.124 0 7 0.158 0 
f70 0 4097 -9 8 0.079 0 9 0.185 0 10 0.076 0 11 0.047 0 12 0.059 0 13 0.039 0 14 0.033 0 
f71 0 4097 -9 2 0.206 0 3 0.302 0 
f72 0 4097 -9 4 0.052 0 5 0.069 0 6 0.072 0 7 0.032 0 
f73 0 4097 -9 8 0.031 0 
f74 0 4097 -9 2 0.155 0 3 0.305 0 
f75 0 4097 -9 4 0.322 0 5 0.048 0 6 0.061 0 7 0.025 0 

f76 0 16384 -17 0 0 70 1 99 2 140 3 198 4                                     ; bassclar wavetables
f77 0 64 -2 78 79 80 5.293 81 82 83 3.726 84 85 86 4.229 87 88 89 1.620 90 91 92 1.347
f78 0 4097 -9 3 1.148 0 
f79 0 4097 -9 4 0.027 0 5 1.620 0 6 0.023 0 7 0.545 0 
f80 0 4097 -9 8 0.056 0 9 1.113 0 10 0.033 0 11 0.866 0 12 0.038 0 13 0.324 0 14 0.086 0 15 0.219 0 16 0.127 0 17 0.057 0 18 0.026 0 19 0.029 0 20 0.081 0 21 0.133 0 22 0.123 0 23 0.157 0 24 0.232 0 25 0.077 0 26 0.064 0 27 0.241 0 28 0.187 0 29 0.244 0 30 0.202 0 31 0.116 0 32 0.023 0 34 0.081 0 35 0.157 0 36 0.106 0 37 0.158 0 38 0.036 0 39 0.095 0 41 0.117 0 43 0.048 0 44 0.025 0 
f81 0 4097 -9 2 0.024 0 3 0.985 0 
f82 0 4097 -9 4 0.039 0 5 0.740 0 7 0.178 0 
f83 0 4097 -9 9 0.093 0 10 0.050 0 11 0.285 0 12 0.083 0 13 0.317 0 14 0.137 0 15 0.400 0 16 0.047 0 17 0.476 0 18 0.128 0 19 0.370 0 20 0.054 0 21 0.093 0 22 0.083 0 23 0.110 0 24 0.030 0 25 0.061 0 26 0.056 0 27 0.113 0 28 0.225 0 29 0.050 0 30 0.091 0 31 0.022 0 32 0.034 0 34 0.055 0 35 0.039 0 
f84 0 4097 -9 3 0.492 0 
f85 0 4097 -9 5 0.730 0 6 0.061 0 7 0.678 0 
f86 0 4097 -9 8 0.217 0 9 1.125 0 10 0.131 0 11 0.383 0 12 0.092 0 13 0.314 0 14 0.104 0 15 0.139 0 16 0.135 0 17 0.218 0 18 0.044 0 19 0.135 0 20 0.283 0 21 0.046 0 22 0.150 0 24 0.059 0 25 0.029 0 26 0.047 0 29 0.029 0 30 0.044 0 31 0.050 0 32 0.041 0  
f87 0 4097 -9 3 0.084 0 
f88 0 4097 -9 4 0.025 0 5 0.359 0 6 0.072 0 7 0.440 0 
f89 0 4097 -9 9 0.271 0 10 0.087 0 11 0.095 0 12 0.079 0 13 0.061 0 14 0.093 0 15 0.058 0 16 0.045 0 18 0.026 0 19 0.027 0 22 0.023 0 
f90 0 4097 -9 2 0.040 0 3 0.354 0 
f91 0 4097 -9 5 0.178 0 6 0.058 0 7 0.294 0 
f92 0 4097 -9 8 0.081 0 9 0.073 0 10 0.230 0 11 0.048 0 12 0.052 0 13 0.067 0 16 0.028 0 

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


;p1   p2       p3      p4      p5        p6      p7      p8      p9  p10
;     start    dur     amp     Hertz     vibr    att     dec     br  in#
; bassoon bar 1-------------------------------------------------------------------
i15    1.000   3.200   5000    523.200   1.000   0.040   0.350   9   7 ; hold 1
i15    4.100   0.200   5000    490.500   1.000   0.030   0.040   9   7
i15    4.200   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15    4.300   0.300   5000    490.500   1.000   0.040   0.100   9   7
i15    4.500   0.350   5000    392.400   1.000   0.040   0.100   9   7
i15    4.750   0.400   5000    327.000   1.000   0.040   0.100   9   7
i15    5.050   0.450   5000    490.500   1.000   0.040   0.100   9   7
i15    5.400   2.250   5000    436.000   1.000   0.040   0.100   9   7 ; hold 2
i15    7.550   0.450   5000    523.200   1.000   0.040   0.100   9   7
i15    7.900   0.200   5000    490.500   1.000   0.030   0.040   9   7
i15    8.000   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15    8.100   0.400   5000    490.500   1.000   0.040   0.100   9   7
i15    8.400   0.450   5000    392.400   1.000   0.040   0.100   9   7
i15    8.750   0.450   5000    327.000   1.000   0.040   0.100   9   7
i15    9.100   0.500   5000    490.500   1.000   0.040   0.100   9   7
; bassoon bar 2-------------------------------------------------------------------
i15    9.500   0.900   5000    436.000   1.000   0.040   0.100   9   7
i15   10.300   0.500   5000    523.200   1.000   0.040   0.150   9   7
i15   10.700   0.200   5000    490.500   1.000   0.030   0.040   9   7
i15   10.800   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15   10.900   0.600   5000    490.500   1.000   0.040   0.100   9   7
i15   11.400   0.600   5000    436.000   1.000   0.040   0.150   9   7
i15   11.900   0.550   5000    588.600   1.000   0.040   0.300   9   7
i15   12.350   0.250   5000    392.400   1.000   0.040   0.100   9   7
i15   12.500   0.700   5000    436.000   1.000   0.040   0.150   9   7
; bassoon bar 3-------------------------------------------------------------------
i15   13.100   0.400   5000    523.200   1.000   0.040   0.100   9   7
i15   13.400   0.200   5000    490.500   1.000   0.030   0.040   9   7
i15   13.500   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15   13.600   0.300   5000    490.500   1.000   0.040   0.100   9   7
i15   13.800   0.300   5000    392.400   1.000   0.040   0.100   9   7
i15   14.000   0.300   5000    327.000   1.000   0.040   0.100   9   7
i15   14.200   0.300   5000    490.500   1.000   0.040   0.100   9   7
i15   14.400   4.400   5000    436.000   1.000   0.040   0.350   9   7
i15   18.800   2.700   5000    523.200   1.000   0.040   0.100   9   7
; bassoon bar 4-------------------------------------------------------------------
i15   21.400   0.200   5000    490.500   1.000   0.030   0.040   9   7
i15   21.500   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15   21.600   0.300   5000    490.500   1.000   0.040   0.100   9   7
i15   21.800   0.300   5000    392.400   1.000   0.040   0.100   9   7
i15   22.000   0.300   5000    490.500   1.000   0.040   0.100   9   7
i15   22.200   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15   22.300   0.400   5000    470.080   1.000   0.040   0.100   9   7
; bassoon bar 5-------------------------------------------------------------------
i15   22.600   0.400   5000    436.000   1.000   0.040   0.100   9   7
i15   22.900   0.200   5000    523.200   1.000   0.030   0.040   9   7
i15   23.000   0.300   5000    470.080   1.000   0.040   0.100   9   7
i15   23.200   0.450   5000    436.000   1.000   0.040   0.100   9   7
i15   23.550   0.650   5000    372.053   1.000   0.040   0.100   9   7
i15   24.100   0.800   5000    523.200   1.000   0.040   0.350   9   7
; bassoon bar 6-------------------------------------------------------------------
i15   29.500   1.600   3500    523.200   1.000   0.040   0.150   7   7
; bassoon bar 7-------------------------------------------------------------------
i15   31.000   0.200   3500    490.500   1.000   0.030   0.040   7   7
i15   31.110   0.200   3500    523.200   1.000   0.030   0.040   7   7
i15   31.200   0.300   3500    490.500   1.000   0.040   0.100   7   7
i15   31.410   0.325   3500    392.400   1.000   0.040   0.100   7   7
i15   31.625   0.350   3500    327.000   1.000   0.040   0.100   7   7
i15   31.875   0.375   3500    490.500   1.000   0.040   0.100   7   7
; bassoon bar 8-------------------------------------------------------------------
i15   32.150   0.650   3500    436.000   1.000   0.040   0.100   7   7
i15   32.700   0.500   3500    523.200   1.000   0.040   0.150   7   7
i15   33.100   0.200   3500    490.500   1.000   0.030   0.040   7   7
i15   33.200   0.200   3500    523.200   1.000   0.030   0.040   7   7
i15   33.300   0.550   3500    490.500   1.000   0.040   0.100   7   7
i15   33.760   0.550   3500    436.000   1.000   0.040   0.150   7   7
i15   34.210   0.500   3500    588.600   1.000   0.040   0.300   7   7
i15   34.600   0.200   3500    392.400   1.000   0.040   0.100   7   7
i15   34.710   0.650   3500    436.000   1.000   0.040   0.150   7   7
; bassoon bar 9-------------------------------------------------------------------
i15   35.260   0.300   3500    523.200   1.000   0.040   0.100   7   7
i15   35.460   0.200   3500    490.500   1.000   0.030   0.040   7   7
i15   35.560   0.200   3500    523.200   1.000   0.030   0.040   7   7
i15   35.660   0.300   3500    490.500   1.000   0.040   0.100   7   7
i15   35.860   0.300   3500    392.400   1.000   0.040   0.100   7   7
i15   36.060   0.300   3500    327.000   1.000   0.040   0.100   7   7
i15   36.260   0.300   3000    490.500   1.000   0.040   0.100   7   7
i15   36.460   9.350   2500    436.000   1.000   0.040   0.350   7   7
;---------------------------------------------------------------------------------
; horn 2 bar 2--------------------------------------------------------------------
i15    9.520   1.700   2500    279.040   0.400   0.100   0.100   7   16
i15   11.110   3.400   2500    294.300   0.400   0.100   0.100   7   16
i15   14.420   4.400   2500    279.040   0.400   0.100   0.250   7   16
;---------------------------------------------------------------------------------
; clarinet 1 bar 4----------------------------------------------------------------
i15   19.300   2.700   1250    279.040   0.400   0.050   0.100   5   5
i15   21.910   1.100   1250    261.600   0.400   0.050   0.100   5   5
; clarinet 1 bar 5----------------------------------------------------------------
i15   22.920   0.800   1250    245.250   0.400   0.050   0.100   5   5
i15   23.570   1.300   1250    235.040   0.400   0.050   0.100   5   5
i15   24.800   1.400   1250    218.000   0.400   0.050   0.100   5   5
i15   25.110   0.400   1250    209.280   0.400   0.050   0.100   5   5
; clarinet 1 bar 6----------------------------------------------------------------
i15   25.420   0.400   1250    196.200   0.400   0.050   0.100   5   5
i15   25.710   0.400   1250    186.027   0.400   0.050   0.100   5   5
i15   26.000   0.400   1250    174.400   0.400   0.050   0.100   5   5
i15   26.320   0.400   1250    163.500   0.400   0.050   0.100   5   5
i15   26.610   0.400   1250    156.960   0.400   0.050   0.100   5   5
i15   26.910   0.400   1250    147.150   0.400   0.050   0.100   5   5
; clarinet 2 pickup to bars 7 & 8-------------------------------------------------
i15   27.230   6.470   650    139.520   0.400   0.050   0.200    5   5
i15   33.570   0.470   650    147.150   0.400   0.050   0.100    5   5
i15   33.940   0.760   650    156.960   0.400   0.050   0.100    5   5
i15   34.600   0.750   650    147.150   0.400   0.050   0.200    5   5
; clarinet 2-1 bar 9--------------------------------------------------------------
i15   35.250  10.550   650    139.520   0.400   0.050   0.200    5   5
;---------------------------------------------------------------------------------
; bass clarinet 2 bar 4-----------------------------------------------------------
i15   19.310   2.900   1250    209.280   0.400   0.100   0.100   5   6
i15   21.920   1.100   1250    196.200   0.400   0.100   0.100   5   6
; bass clarinet 2 bar 5-----------------------------------------------------------
i15   22.910   0.800   1250    186.027   0.400   0.100   0.100   5   6
i15   23.560   1.300   1250    174.400   0.400   0.100   0.100   5   6
i15   24.810   1.400   1250    163.500   0.400   0.100   0.100   5   6
i15   25.100   0.400   1250    156.960   0.400   0.100   0.100   5   6
; bass clarinet 2 bar 6-----------------------------------------------------------
i15   25.400   0.400   1250    147.150   0.400   0.100   0.100   5   6
i15   25.700   0.400   1250    139.520   0.400   0.100   0.100   5   6
i15   26.010   0.400   1250    130.800   0.400   0.100   0.100   5   6
i15   26.310   0.400   1250    122.625   0.400   0.100   0.100   5   6
i15   26.620   0.400   1250    117.520   0.400   0.100   0.100   5   6
i15   26.920   0.400   1250    109.000   0.400   0.100   0.100   5   6
; bass clarinet 1 pickup to bars 7 & 8--------------------------------------------
i15   27.210   6.470   650     104.640   0.400   0.100   0.350   5   6
i15   33.580   0.470   650     109.000   0.400   0.100   0.100   5   6
i15   33.930   0.760   650     117.520   0.400   0.100   0.100   5   6
i15   34.610   0.750   650     109.000   0.400   0.100   0.100   5   6
; bass clarinet 1-2 bar 9---------------------------------------------------------
i15   35.270  10.550   650     104.640   0.400   0.100   0.350   5   6
;---------------------------------------------------------------------------------
; clarinet in D bar 5-------------------------------------------------------------
i15   23.600   2.200   4000    372.053   0.400   0.100   0.100   6   5
i15   25.710   0.400   3500    313.920   0.400   0.100   0.100   6   5
i15   26.020   0.150   3500    372.053   0.400   0.030   0.050   6   5
i15   26.120   0.400   3500    327.000   0.400   0.100   0.100   6   5
i15   26.320   0.400   3000    279.040   0.400   0.100   0.100   6   5
i15   26.600   0.150   3000    327.000   0.400   0.030   0.050   6   5
i15   26.710   0.400   3000    294.300   0.400   0.100   0.100   6   5
i15   26.900   0.700   2000    245.250   0.400   0.100   0.200   6   5
;---------------------------------------------------------------------------------
; English horn bar 10-------------------------------------------------------------
i15   38.300   0.600   4000    279.040   0.450   0.030   0.100   9   4
i15   38.800   0.500   4000    372.053   0.450   0.030   0.100   9   4
i15   39.300   0.200   4000    279.040   0.450   0.030   0.100   9   4
i15   39.400   0.200   4000    372.053   0.450   0.030   0.100   9   4
i15   39.500   0.400   4000    313.920   0.450   0.030   0.100   9   4
i15   39.800   0.400   4000    279.040   0.450   0.030   0.100   9   4
i15   40.100   0.350   4000    372.053   0.450   0.030   0.270   9   4
; English horn bar 11-------------------------------------------------------------
i15   40.400   0.200   4000    279.040   0.450   0.030   0.100   9   4
i15   40.500   0.200   4000    372.053   0.450   0.030   0.100   9   4
i15   40.600   0.400   4000    313.920   0.450   0.030   0.100   9   4
i15   40.900   0.420   4000    279.040   0.450   0.030   0.100   9   4
i15   41.220   0.350   4000    372.053   0.450   0.030   0.100   9   4
i15   41.940   0.300   3500    418.560   0.450   0.030   0.100   9   4
i15   42.140   0.310   3500    313.920   0.450   0.030   0.100   9   4
i15   42.350   0.320   3000    372.053   0.450   0.030   0.100   9   4
i15   42.570   0.330   3000    279.040   0.450   0.030   0.100   9   4
; English horn bar 12-------------------------------------------------------------
i15   42.800   3.000   2500    313.920   0.450   0.030   0.270   9   4
;---------------------------------------------------------------------------------

;reverb---------------------------------------------------------------------------
;p1    p2      p3     p4        p5        p6
;      start   dur    revtime   %reverb   gain
i194   1.0     45.8   1.5       .1        1.0
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
