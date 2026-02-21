<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; comb3.orc (in the global subdirectory on the CD-ROM)

; instr 84 - general wavetable wind instrument going to comb filter 3
; instr 184-193 - group of global comb filters (comb filter 3)

giseed    =       .5
giwtsin   =       1
gacomb3a  init    0
gacomb3b  init    0
gacomb3c  init    0
gacomb3d  init    0
gacomb3e  init    0
gacomb3f  init    0
gacomb3g  init    0
gacomb3h  init    0
gacomb3i  init    0
gacomb3j  init    0
;______________________________________________________________________________________________________
instr 84                                                    ; general wind instrument going to comb filter 3
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
gacomb3a  =       gacomb3a + asig                           ; send signal to global comb filter 3
gacomb3b  =       gacomb3b + asig                           ; send signal to global comb filter 3
gacomb3c  =       gacomb3c + asig                           ; send signal to global comb filter 3
gacomb3d  =       gacomb3d + asig                           ; send signal to global comb filter 3
gacomb3e  =       gacomb3e + asig                           ; send signal to global comb filter 3
gacomb3f  =       gacomb3f + asig                           ; send signal to global comb filter 3
gacomb3g  =       gacomb3g + asig                           ; send signal to global comb filter 3
gacomb3h  =       gacomb3h + asig                           ; send signal to global comb filter 3
gacomb3i  =       gacomb3i + asig                           ; send signal to global comb filter 3
gacomb3j  =       gacomb3j + asig                           ; send signal to global comb filter 3
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 184                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3a,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3a                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3a) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3a  =       0
          endin
;______________________________________________________________________________________________________
instr 185                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3b,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3b                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3b) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3b  =       0
          endin
;______________________________________________________________________________________________________
instr 186                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3c,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3c                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3c) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3c  =       0
          endin
;______________________________________________________________________________________________________
instr 187                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3d,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3d                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3d) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3d  =       0
          endin
;______________________________________________________________________________________________________
instr 188                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3e,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3e                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3e) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3e  =       0
          endin
;______________________________________________________________________________________________________
instr 189                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3f,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3f                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3f) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3f  =       0
          endin
;______________________________________________________________________________________________________
instr 190                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3g,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3g                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3g) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3g  =       0
          endin
;______________________________________________________________________________________________________
instr 191                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3h,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3h                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3h) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3h  =       0
          endin
;______________________________________________________________________________________________________
instr 192                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3i,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3i                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3i) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3i  =       0
          endin
;______________________________________________________________________________________________________
instr 193                                                   ; global comb filter 3
; parameters
; p4 attenuation factor for the comb filtered signal
; p5 "fundamental frequency" of the comb filter (p5*p13 is frequency of the comb filter)
; p6 ring time for comb filter
; p7 percent of combed signal (1 means 100% comb 0% original, .5 means 50% comb 50% original)
; p8 initial highpass filter cutoff frequency
; p9 ending highpass filter cutoff frequency
; p10 percent duration to wait before cutoff frequency changes
;        (e.g., .1 means use the initial cutoff frequency for 10% of the note duration before beginning change)
; p11 percent duration of cutoff frequency change
;        (e.g., .5 means make the change over half the note's duration)
; p12 percent duration of fade in
;        (e.g., .1 means fade the note in for 10% of the note duration, and fade out over the rest of the duration)
; p13 "harmonic number" of the comb filter (p5*p13 is frequency of the comb filter)

idur      =       p3    
iamp      =       p4                                        ; set attenuation for output signal
ifreq     =       p5 * p13                                  ; frequency for comb filter
iring     =       p6                                        ; set ring time for comb filter
icomb     =       p7                                        ; percent of combed signal (vs orginal)
icomb     =       (icomb <= 0 ? .01 : icomb)                ; check for values between 0 and 1
icomb     =       (icomb >= 1 ? .99 : icomb)
iorig     =       1 - icomb                                 ; original signal is the rest
iloop     =       1/ifreq                                   ; loop time (loop time is 1/freq)
ifilt1    =       p8                                        ; initial HP filter cutoff frequency
ifilt2    =       p9                                        ; ending filter cutoff frequency
p10       =       (p10 <= 0 ? .001 : p10)                   ; check for 0 values and fix them
p11       =       (p11 <= 0 ? .001 : p11)                   ; check for 0 values and fix them
iwait     =       p10 * idur                                ; duration of wait before cutoff gliss
igliss    =       p11 * idur                                ; duration of cutoff gliss
          if (iwait + igliss < idur) goto comb3a
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
comb3a:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
p12       =       (p12 <= 0 ? .001 : p12)                   ; check for values between 0 and 1
p12       =       (p12 >= 1 ? .99 : p12)
iattack   =       p12 * idur                                ; duration of fade in
idecay    =       idur - iattack

kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
afilt     atone   gacomb3j,kfreq                            ; HP filter
afilt2    atone   afilt,kfreq                               ; HP filter
abal      balance afilt2,gacomb3j                           ; balance amplitude

acomb     comb    abal,iring,iloop                          ; args:  sig, ring time, loop time
asig      =       (iorig * gacomb3j) + (icomb * acomb)
aenv      linseg  0,iattack,1,idecay,0,1,0                  ; fade signal in and out
          out     iamp*aenv*asig                            ; output original and comb signals
gacomb3j  =       0
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; comb3.sco - i184-i193 used as a group (in the global subdirectory on the CD-ROM)
; Bach's Fugue #2 in C Minor for oboe duet

f1 0 8193 -9 1 1.000 0                                                        ; sine wave
f2 0 16 -2 40 40 80 160 320 640 1280 2560 5120 10240 10240                    ; filter cutoff table
f3 0 64 -2 0 11 22 29 42 57 76 93 111 131 152 171 191 211 239 258 275 297 311 ; instr wt# table
f4 0 5 -9 1 0.0 0                                                             ; zero-amp sine wave

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

t 0 80
;p1   p2       p3      p4     p5        p6      p7      p8      p9  p10
;     start    dur     amp    Hertz     vibr    att     dec     br  in#
;bar 1---------------------------------------------------------------------------------
i84    1.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i84    1.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i84    2.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i84    2.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i84    3.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i84    3.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i84    3.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i84    4.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i84    4.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
;bar 2---------------------------------------------------------------------------------
i84    5.000   0.550  10000   392.400   0.700   0.045   0.150   9   3
i84    5.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i84    5.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
i84    6.000   0.550   8100   523.200   0.700   0.045   0.150   9   3
i84    6.500   0.550   7200   588.600   0.700   0.045   0.150   9   3
i84    7.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i84    7.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i84    7.500   1.050   7200   418.560   0.700   0.045   0.150   9   3
i84    8.500   0.300   7200   392.400   0.700   0.045   0.150   9   3
i84    8.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 3 (upper)-------------------------------------------------------------------------
i84    9.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i84    9.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i84   10.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i84   10.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i84   11.000   0.550   9000   627.840   0.700   0.045   0.150   9   3
i84   11.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i84   11.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i84   12.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i84   12.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
;bar 3 (lower)--------------------------------------------------------------------------
i84    9.000   0.300  10000   313.920   0.700   0.045   0.150   9   3
i84    9.250   0.300   6500   523.200   0.700   0.045   0.150   9   3
i84    9.500   0.300   7200   490.500   0.700   0.045   0.150   9   3
i84    9.750   0.300   6500   436.000   0.700   0.045   0.150   9   3
i84   10.000   0.300   8100   392.400   0.700   0.045   0.150   9   3
i84   10.250   0.300   6500   348.800   0.700   0.045   0.150   9   3
i84   10.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i84   10.750   0.300   6500   294.300   0.700   0.045   0.150   9   3
i84   11.000   0.550   9000   261.600   0.700   0.045   0.150   9   3
i84   11.500   0.550   7200   627.840   0.700   0.045   0.150   9   3
i84   12.000   0.550   8100   588.600   0.700   0.045   0.150   9   3
i84   12.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
;bar 4 (upper)-------------------------------------------------------------------------
i84   13.000   0.550  10000   588.600   0.700   0.045   0.150   9   3
i84   13.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i84   13.750   0.300   6500   744.107   0.700   0.045   0.150   9   3
i84   14.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i84   14.500   0.550   7200   872.000   0.700   0.045   0.150   9   3
i84   15.000   0.300   9000   523.200   0.700   0.045   0.150   9   3
i84   15.250   0.300   6500   588.600   0.700   0.045   0.150   9   3
i84   15.500   1.050   8100   627.840   0.700   0.045   0.150   9   3
i84   16.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i84   16.750   0.300   6500   523.200   0.700   0.045   0.150   9   3
;bar 4 (lower)-------------------------------------------------------------------------
i84   13.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i84   13.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
i84   14.000   0.550   8100   470.080   0.700   0.045   0.150   9   3
i84   14.500   0.550   7200   523.200   0.700   0.045   0.150   9   3
i84   15.000   0.550   9000   372.053   0.700   0.045   0.150   9   3
i84   15.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i84   16.000   0.550   8100   436.000   0.700   0.045   0.150   9   3
i84   16.500   0.550   7200   372.053   0.700   0.045   0.150   9   3
;bar 5 (upper)-------------------------------------------------------------------------
i84   17.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i84   17.500   0.300   7200   627.840   0.700   0.045   0.150   9   3
i84   17.750   0.300   6500   588.600   0.700   0.045   0.150   9   3
i84   18.000   0.550   8100   627.840   0.700   0.045   0.150   9   3
i84   18.500   0.550   7200   392.400   0.700   0.045   0.150   9   3
i84   19.000   0.550   9000   418.560   0.700   0.045   0.150   9   3
i84   19.500   0.300   7200   697.600   0.700   0.045   0.150   9   3
i84   19.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i84   20.000   0.550   8100   697.600   0.700   0.045   0.150   9   3
i84   20.500   0.550   7200   436.000   0.700   0.045   0.150   9   3
;bar 5 (lower)-------------------------------------------------------------------------
i84   17.000   1.050  10000   392.400   0.700   0.045   0.150   9   3
i84   18.250   0.300   6500   261.600   0.700   0.045   0.150   9   3
i84   18.500   0.300   7200   294.300   0.700   0.045   0.150   9   3
i84   18.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i84   19.000   0.300   9000   348.800   0.700   0.045   0.150   9   3
i84   19.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i84   19.500   0.800   7200   418.560   0.700   0.045   0.150   9   3
i84   20.250   0.300   6500   294.300   0.700   0.045   0.150   9   3
i84   20.500   0.300   7200   313.920   0.700   0.045   0.150   9   3
i84   20.750   0.300   6500   348.800   0.700   0.045   0.150   9   3
;bar 6 (upper)-------------------------------------------------------------------------
i84   21.000   0.550  10000   470.080   0.700   0.045   0.150   9   3
i84   21.500   0.300   7200   784.800   0.700   0.045   0.150   9   3
i84   21.750   0.300   6500   697.600   0.700   0.045   0.150   9   3
i84   22.000   0.550   8100   784.800   0.700   0.045   0.150   9   3
i84   22.500   0.550   7200   490.500   0.700   0.045   0.150   9   3
i84   23.000   0.550   9000   523.200   0.700   0.045   0.150   9   3
i84   23.500   0.300   7200   588.600   0.700   0.045   0.150   9   3
i84   23.750   0.300   6500   627.840   0.700   0.045   0.150   9   3
i84   24.000   2.050   8100   697.600   0.700   0.045   0.150   9   3
;bar 6 (lower)-------------------------------------------------------------------------
i84   21.000   0.300  10000   392.400   0.700   0.045   0.150   9   3
i84   21.250   0.300   6500   436.000   0.700   0.045   0.150   9   3
i84   21.500   0.800   7200   470.080   0.700   0.045   0.150   9   3
i84   22.250   0.300   6500   313.920   0.700   0.045   0.150   9   3
i84   22.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i84   22.750   0.300   6500   392.400   0.700   0.045   0.150   9   3
i84   23.000   0.300   9000   418.560   0.700   0.045   0.150   9   3
i84   23.250   0.300   6500   392.400   0.700   0.045   0.150   9   3
i84   23.500   0.300   7200   348.800   0.700   0.045   0.150   9   3
i84   23.750   0.300   6500   313.920   0.700   0.045   0.150   9   3
i84   24.000   0.550   8100   294.300   0.700   0.045   0.150   9   3
i84   24.500   0.300   7200   523.200   0.700   0.045   0.150   9   3
i84   24.750   0.300   6500   490.500   0.700   0.045   0.150   9   3
;bar 7 (lower)-------------------------------------------------------------------------
i84   25.000   1.050  10000   523.200   0.700   0.045   0.150   9   3

;global comb filter 3------------------------------------------------------------------
; (avoid note overlaps within the same instrument)
;p1    p2        p3       p4   p5       p6    p7     p8     p9     p10  p11    p12   p13
;      start     dur      amp  combFrq  ring  %comb  filt1  filt2  wait gliss  attck harm  
i184    7.3000   1.3000   .15  246.9    .3    1      220    1975   .1   .8     .1     7
i184   12.0000   1.0000   .15  246.9    .3    1      220    1975   .1   .8     .1     7
i184   17.3000   1.3000   .15  246.9    .3    1      220    1975   .1   .8     .1     7
i184   22.0000   1.3000   .15  246.9    .3    1      220    1975   .1   .8     .1     7

i185    2.0000   1.0000   .15  246.9    .3    1      220    1975   .1   .8     .1     8
i185    5.3000   1.3000   .15  246.9    .3    1      220    1975   .1   .8     .1     8
i185   11.0000   1.0000   .15  246.9    .3    1      220    1975   .1   .8     .1     8
i185   15.3000   1.3000   .15  246.9    .3    1      220    1975   .1   .8     .1     8
i185   21.0000   1.0000   .15  246.9    .3    1      220    1975   .1   .8     .1     8

i186    3.1300   1.0000   .15  246.9    .4    1      220    1975   .1   .8     .1     9
i186   11.2000   1.7000   .15  246.9    .4    1      220    1975   .1   .8     .1     9
i186   13.1300   1.0000   .15  246.9    .4    1      220    1975   .1   .8     .1     9
i186   21.2000   1.7000   .15  246.9    .4    1      220    1975   .1   .8     .1     9
i186   23.1300   1.0000   .15  246.9    .4    1      220    1975   .1   .8     .1     9

i187    4.7200    .6000   .15  246.9    .5    1      220    1975   .1   .8     .1    10
i187   11.0000   1.3000   .15  246.9    .5    1      220    1975   .1   .8     .1    10
i187   14.7200    .6000   .15  246.9    .5    1      220    1975   .1   .8     .1    10
i187   21.0000   1.3000   .15  246.9    .5    1      220    1975   .1   .8     .1    10

i188    2.3000   1.0000   .15  246.9    .6    1      220    1975   .1   .8     .1    11
i188   11.3000   1.0000   .15  246.9    .6    1      220    1975   .1   .8     .1    11
i188   12.4200    .3000   .15  246.9    .6    1      220    1975   .1   .8     .1    11
i188   21.3000   1.0000   .15  246.9    .6    1      220    1975   .1   .8     .1    11
i188   22.4200    .3000   .15  246.9    .6    1      220    1975   .1   .8     .1    11

i189    1.5000   1.3000   .15  246.9    .7    1      220    1975   .1   .8     .1    12
i189    4.7300   1.3000   .15  246.9    .7    1      220    1975   .1   .8     .1    12
i189   11.5000   1.3000   .15  246.9    .7    1      220    1975   .1   .8     .1    12
i189   14.7300   1.3000   .15  246.9    .7    1      220    1975   .1   .8     .1    12
i189   21.5000   1.3000   .15  246.9    .7    1      220    1975   .1   .8     .1    12

i190    2.1000   1.0000   .15  246.9    .6    1      220    1975   .1   .8     .1    13
i190    5.4500    .5000   .15  246.9    .6    1      220    1975   .1   .8     .1    13
i190   11.1000   1.0000   .15  246.9    .6    1      220    1975   .1   .8     .1    13
i190   15.4500    .5000   .15  246.9    .6    1      220    1975   .1   .8     .1    13
i190   21.1000   1.0000   .15  246.9    .6    1      220    1975   .1   .8     .1    13

i191    1.7000   1.4000   .15  246.9    .5    1      220    1975   .1   .8     .1    14
i191    7.8400    .3000   .15  246.9    .5    1      220    1975   .1   .8     .1    14
i191   11.7000   1.4000   .15  246.9    .5    1      220    1975   .1   .8     .1    14
i191   17.8400    .3000   .15  246.9    .5    1      220    1975   .1   .8     .1    14
i191   21.7000   1.4000   .15  246.9    .5    1      220    1975   .1   .8     .1    14

i192    2.2000   1.0000   .15  246.9    .4    1      220    1975   .1   .8     .1    15
i192    7.4300   1.6000   .15  246.9    .4    1      220    1975   .1   .8     .1    15
i192   11.2000   1.0000   .15  246.9    .4    1      220    1975   .1   .8     .1    15
i192   17.4300   1.6000   .15  246.9    .4    1      220    1975   .1   .8     .1    15
i192   21.2000   1.0000   .15  246.9    .4    1      220    1975   .1   .8     .1    15
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
