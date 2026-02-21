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
; pate.sco - use with wind.orc (in the pitch subdirectory on the CD-ROM)
; brass choral in just intonation
; uses cup-muted trumpet, trombone, horn and tuba designs

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

;wavetables for trumpet with cup mute
f171 0 16384 -17 0 0 256 1 342 2 458 3 615 4 828 5                            ; cup-muted trumpet wavetables
f172 0 64 -2 173 174 175 55.800 176 177 178 10.923 179 180 181 4.264 182 183 184 5.406 185 186 187 1.250 188 189 190 1.239
f173 0 4097 -9 2 7.185 0 3 10.687 0 
f174 0 4097 -9 4 11.248 0 5 24.453 0 6 5.648 0 7 2.755 0 
f175 0 4097 -9 8 1.709 0 9 1.668 0 10 1.799 0 11 0.461 0 12 0.352 0 13 0.300 0 14 0.643 0 15 0.251 0 16 2.326 0 17 2.222 0 18 1.773 0 19 1.033 0 20 0.598 0 21 0.430 0 22 0.690 0 23 0.325 0 24 0.147 0 25 0.159 0 26 0.038 0 27 0.048 0 28 0.024 0 30 0.054 0 31 0.049 0 32 0.057 0 33 0.078 0 34 0.200 0 35 0.168 0 36 0.109 0 37 0.074 0 38 0.195 0 39 0.091 0 40 0.041 0 42 0.049 0 
f176 0 4097 -9 2 2.628 0 3 4.112 0 
f177 0 4097 -9 4 3.323 0 5 0.637 0 6 0.421 0 7 0.785 0 
f178 0 4097 -9 8 0.503 0 9 0.161 0 10 0.359 0 11 0.482 0 12 1.210 0 13 1.522 0 14 0.566 0 15 0.241 0 16 0.247 0 17 0.097 0 19 0.021 0 20 0.027 0 22 0.069 0 23 0.051 0 24 0.054 0 25 0.052 0 26 0.116 0 27 0.059 0 28 0.071 0 29 0.044 0 30 0.025 0 
f179 0 4097 -9 2 3.326 0 3 0.639 0 
f180 0 4097 -9 4 0.451 0 5 0.086 0 6 0.191 0 7 0.507 0 
f181 0 4097 -10 0 0 0 0 0 0 0 0.157 0.326 0.046 0.038 0.036 0.106 0.048 0.048 0.027 0.022 0.020
f182 0 4097 -9 2 4.440 0 3 0.658 0 
f183 0 4097 -9 4 0.589 0 5 0.110 0 6 0.349 0 7 0.782 0 
f184 0 4097 -9 8 0.211 0 9 0.507 0 10 0.131 0 11 0.111 0 12 0.097 0 13 0.100 0 14 0.122 0 15 0.053 0 16 0.114 0 17 0.033 0 18 0.020 0  
f185 0 4097 -9 2 0.112 0 3 0.137 0 
f186 0 4097 -9 4 0.057 0 5 0.484 0 6 0.060 0 7 0.173 0 
f187 0 4097 -9 8 0.051 0 9 0.055 0 10 0.065 0 11 0.036 0 12 0.047 0 13 0.056 0 
f188 0 4097 -9 2 0.062 0 3 0.029 0 
f189 0 4097 -9 4 0.325 0 5 0.150 0 6 0.020 0 7 0.044 0 
f190 0 4097 -9 8 0.062 0 9 0.049 0 10 0.042 0 11 0.028 0 

;wavetables for trombone
f211 0 16384 -17 0 0 49 1 78 2 114 3 152 4 203 5 272 6 363 7 484 8            ; trombone wavetables
f212 0 64 -2 213 214 215 1097.095 216 217 218 333.625 219 220 221 52.730 222 223 224 44.207 225 226 227 16.212 228 229 230 11.992 231 232 233 10.655 234 235 236 2.527 237 238 4 1.441
f213 0 4097 -9 2 6.250 0 3 9.625 0 
f214 0 4097 -9 4 15.625 0 5 16.500 0 6 19.875 0 7 18.125 0 
f215 0 4097 -10 0 0 0 0 0 0 0 16.875 46.500 48.000 66.125 74.375 47.125 44.500 32.625 45.000 54.750 56.500 47.875 47.500 36.625 39.750 44.500 37.875 33.875 32.625 23.875 29.125 29.500 28.125 29.625 22.250 24.750 38.125 36.625 30.375 23.125 19.625 18.750 16.750 19.750 15.875 14.250 13.875 12.000 13.000 11.125 13.000 9.875 9.750 9.000 8.875 9.000 7.125 7.875 7.625 6.500 5.375 6.000 6.000 4.250 4.625 4.625 4.375 3.750 4.000 3.875 3.125 3.250 3.500 3.125 3.000 2.875 3.125 2.625 2.750 2.500 2.750 2.750 2.125 1.625 1.750 2.125 1.875 1.875 1.875 1.625 1.500 1.500 1.500 1.375 1.375 1.250 1.250 
f216 0 4097 -9 2 2.483 0 3 3.763 0 
f217 0 4097 -9 4 6.934 0 5 8.465 0 6 10.877 0 7 12.769 0 
f218 0 4097 -10 0 0 0 0 0 0 0 24.484 11.435 22.587 22.086 22.754 26.312 19.037 18.337 19.727 15.371 16.113 10.108 11.592 14.140 14.021 12.964 17.916 16.845 17.381 10.054 7.988 7.321 5.230 4.326 4.511 3.824 3.549 3.398 3.250 2.375 1.952 2.044 1.147 1.710 0.725 0.694 0.712 0.343 0.667 0.334 0.172 0.174 0.198 0.284 0.419 0.504 0.506 0.581 0.538 0.626 0.699 0.780 0.698 0.941 0.818 0.754 0.771 0.820 0.929 0.861 0.854 0.910 0.932 0.769 0.921 0.818 0.966 0.924 0.848 0.867 0.782 0.770 0.809 0.737 0.799 0.682 0.651 0.630 0.657 0.608 0.635 0.573 0.547 0.596 0.545 0.499 
f219 0 4097 -9 2 2.288 0 3 3.627 0 
f220 0 4097 -9 4 3.741 0 5 6.847 0 6 4.659 0 7 6.059 0 
f221 0 4097 -10 0 0 0 0 0 0 0 5.318 4.141 4.906 3.447 2.506 3.988 2.800 4.306 2.447 2.200 1.376 1.541 1.647 1.035 1.106 0.765 0.682 0.718 0.553 0.435 0.459 0.259 0.282 0.141 0.224 0.188 0.188 0.141 0.153 0.106  0.099 0.082 0.072 0.059 0.074 0.048 0.042 0.041 0.038 0 0.026 0.027 0 0.021 0.021
f222 0 4097 -9 2 2.336 0 3 3.832 0 
f223 0 4097 -9 4 5.788 0 5 4.676 0 6 5.923 0 7 5.964 0 
f224 0 4097 -10 0 0 0 0 0 0 0 4.695 2.915 3.063 4.612 3.124 2.738 2.422 1.780 1.378 1.392 1.441 0.867 0.811 0.646 0.554 0.337 0.437 0.385 0.303 0.287 0.236 0.149 0.166 0.148 0.126 0.095 0.099 0.082 0.072 0.059 0.074 0.048 0.042 0.041 0.038 0 0.026 0.027 0 0.021 0.021 
f225 0 4097 -9 2 2.109 0 3 3.239 0 
f226 0 4097 -9 4 2.557 0 5 3.340 0 6 1.898 0 7 1.943 0 
f227 0 4097 -10 0 0 0 0 0 0 0 1.743 1.664 1.013 0.708 0.691 0.628 0.412 0.371 0.292 0.262 0.249 0.196 0.150 0.134 0.124 0.097 0.075 0.071 0.061 0.059 0.047 0.044 0.040 0.031 0.027 0.025 0.021 
f228 0 4097 -9 2 1.701 0 3 2.444 0 
f229 0 4097 -9 4 2.824 0 5 1.432 0 6 1.976 0 7 1.645 0 
f230 0 4097 -10 0 0 0 0 0 0 0 1.270 0.745 0.567 0.533 0.346 0.184 0.201 0.153 0.108 0.097 0.086 0.075 0.059 0.048 0.043 0.038 0.030 
f231 0 4097 -9 2 1.978 0 3 4.767 0 
f232 0 4097 -9 4 2.309 0 5 1.417 0 6 1.233 0 7 0.801 0 
f233 0 4097 -10 0 0 0 0 0 0 0 0.493 0.382 0.301 0.178 0.163 0.151 0.095 0.074 0.062 0.041 0.035 0.033 0.026 
f234 0 4097 -9 2 1.020 0 3 0.700 0 
f235 0 4097 -9 4 0.441 0 5 0.292 0 6 0.240 0 7 0.139 0 
f236 0 4097 -10 0 0 0 0 0 0 0 0.087 0.084 0.062 0.045 0.032 0.030 0.025 
f237 0 4097 -9 2 0.567 0 3 0.251 0 
f238 0 4097 -9 4 0.108 0 5 0.030 0  

;wavetables for horn
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

;wavetables for tuba
f311 0 16384 -17 0 0 68 1 90 2 121 3 161 4 216 5                              ; tuba wavetables
f312 0 64 -2 313 314 315 13.556 316 317 318 13.193 319 320 321 2.961 322 323 324 2.392 325 326 4 2.348 327 328 4 1.266
f313 0 4097 -9 2 2.638 0 3 1.176 0 
f314 0 4097 -9 4 3.122 0 5 1.523 0 6 2.396 0 7 1.547 0 
f315 0 4097 -9 8 1.347 0 9 1.330 0 10 0.766 0 11 0.739 0 12 0.451 0 13 0.387 0 14 0.388 0 15 0.393 0 16 0.298 0 17 0.232 0 18 0.172 0 19 0.152 0 20 0.077 0 21 0.063 0 22 0.097 0 23 0.039 0 
f316 0 4097 -9 2 3.183 0 3 3.822 0 
f317 0 4097 -9 4 2.992 0 5 2.243 0 6 1.999 0 7 1.053 0 
f318 0 4097 -9 8 0.742 0 9 0.501 0 10 0.377 0 11 0.369 0 12 0.288 0 13 0.288 0 14 0.216 0 15 0.130 0 16 0.105 0 17 0.069 0 18 0.021 0 
f319 0 4097 -9 2 0.685 0 3 0.741 0 
f320 0 4097 -9 4 0.791 0 5 0.395 0 6 0.327 0 7 0.175 0 
f321 0 4097 -9 8 0.105 0 9 0.102 0 10 0.074 0 11 0.063 0 12 0.034 0 
f322 0 4097 -9 2 0.329 0 3 0.939 0 
f323 0 4097 -9 4 0.593 0 5 0.240 0 6 0.100 0 7 0.095 0 
f324 0 4097 -9 8 0.082 0 9 0.028 0 
f325 0 4097 -9 2 1.072 0 3 0.537 0 
f326 0 4097 -9 4 0.351 0 5 0.185 0 6 0.054 0 7 0.024 0 
f327 0 4097 -9 2 0.448 0 3 0.183 0 
f328 0 4097 -9 4 0.087 0 5 0.028 0 

;p1   p2   p3  p4     p5        p6      p7      p8      p9  p10
;    start dur amp    Hertz     vibr    att     dec  bright inst ; inst name
i15    1   4   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15    1   2   2000   163.333   0.000   0.130   0.100   5   13   ; trombone
i15    1   2   2000   392       0.000   0.130   0.100   5   16   ; horn
i15    1   4   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15    3   2   2000   174.222   0.000   0.130   0.100   5   13   ; trombone
i15    3   2   2000   435.555   0.000   0.130   0.100   5   16   ; horn

i15    5   2   2000    73.5     0.000   0.130   0.100   5   18   ; tuba
i15    5   2   2000   147.0     0.000   0.130   0.100   5   13   ; trombone
i15    5   4   2000   392       0.000   0.130   0.100   5   16   ; horn
i15    5   2   2000   490       0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15    7   4   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15    7   2   2000   163.333   0.000   0.130   0.100   5   13   ; trombone
i15    7   1   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15    8   1   2000   470.4     0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15    9   4   2000   174.222   0.000   0.130   0.100   5   13   ; trombone
i15    9   2   2000   435.555   0.000   0.130   0.100   5   16   ; horn
i15    9   2   2000   435.555   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   11   2   2000    73.5     0.000   0.130   0.100   5   18   ; tuba
i15   11   9   2000   392       0.000   0.130   0.100   5   16   ; horn
i15   11   2   2000   490       0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   13   4   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15   13   6   2000   163.333   0.000   0.130   0.100   5   13   ; trombone
i15   13   2   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   15   5   2000   470.4     0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   17   4   2000    73.5     0.000   0.130   0.100   5   18   ; tuba

i15   19   4   2000   174.222   0.000   0.130   0.100   5   13   ; trombone

i15   20   7   2000   435.555   0.000   0.130   0.100   5   16   ; horn
i15   20   3   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   21   2   2000    65.333   0.000   0.130   0.100   5   18   ; tuba

i15   23   4   2000    73.5     0.000   0.130   0.100   5   18   ; tuba
i15   23   2   2000   185.833   0.000   0.130   0.100   5   13   ; trombone
i15   23   2   2000   490       0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   25   4   2000   163.333   0.000   0.130   0.100   5   13   ; trombone
i15   25   3   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   27   2   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15   27   4   2000   392       0.000   0.130   0.100   5   16   ; horn

i15   28   1   2000   490       0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   29   4   2000    58.8     0.000   0.130   0.100   5   18   ; tuba
i15   29   2   2000   156.8     0.000   0.130   0.100   5   13   ; trombone
i15   29   2   2000   470.4     0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   31   2   2000   139.378   0.000   0.130   0.100   5   13   ; trombone
i15   31   2   2000   348.444   0.000   0.130   0.100   5   16   ; horn
i15   31   4   2000   418.133   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   33   3   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15   33   2   2000   130.667   0.000   0.130   0.100   5   13   ; trombone
i15   33   2   2000   313.6     0.000   0.130   0.100   5   16   ; horn

i15   35   1   2000   156.8     0.000   0.130   0.100   5   13   ; trombone
i15   35   2   2000   348.444   0.000   0.130   0.100   5   16   ; horn
i15   35   2   2000   470.4     0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   36   3   2000    73.5     0.000   0.130   0.100   5   18   ; tuba
i15   36   3   2000   147.0     0.000   0.130   0.100   5   13   ; trombone

i15   37   2   2000   371.674   0.000   0.130   0.100   5   16   ; horn
i15   37   4   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   39   4   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15   39   2   2000   163.333   0.000   0.130   0.100   5   13   ; trombone
i15   39   2   2000   392       0.000   0.130   0.100   5   16   ; horn

i15   41   2   2000   156.8     0.000   0.130   0.100   5   13   ; trombone
i15   41   5   2000   348.444   0.000   0.130   0.100   5   16   ; horn
i15   41   4   2000   470.4     0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   43   4   2000    73.5     0.000   0.130   0.100   5   18   ; tuba
i15   43   4   2000   147.0     0.000   0.130   0.100   5   13   ; trombone

i15   45   2   2000   490       0.000   0.130   0.100   5   11   ; trumpet with cup mute

i15   46   5   2000   392       0.000   0.130   0.100   5   16   ; horn

i15   47   4   2000    65.333   0.000   0.130   0.100   5   18   ; tuba
i15   47   4   2000   163.333   0.000   0.130   0.100   5   13   ; trombone
i15   47   4   2000   522.667   0.000   0.130   0.100   5   11   ; trumpet with cup mute

;reverb------------------------------------------------------------------
;p1    p2      p3    p4        p5        p6
;      start   dur   revtime   %reverb   gain
i194   .5      51    1.5       .1        1.0
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
