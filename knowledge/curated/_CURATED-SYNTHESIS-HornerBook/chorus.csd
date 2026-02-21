<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; chorus.orc (in the global subdirectory on the CD-ROM)

; instr 77 - general wind instrument going to chorus
; instr 177 - global chorus

giseed    =       .5
giwtsin   =       1
gachorus  init    0
;______________________________________________________________________________________________________
instr 77                                                    ; general wind instrument going to chorus
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
gachorus  =       gachorus + asig                           ; send signal to global chorus
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 177                                                   ; global chorus with 1-5 voices
; parameters
; p4 maximum delay time   20-40ms
;         20ms max delay keeps tight sound
;         30-40ms max delay gives more broadening
; p5 number of voices in chorus (2=doubling; 5 maximum)

imaxdt    =       p4
ivoices   =       p5
ivoices   =       (ivoices < 1 ? 1 : ivoices)               ; minimum 1 voice
ivoices   =       (ivoices > 5 ? 5 : ivoices)               ; maximum 5 voices
iattn     =       1/ivoices                                 ; attenuation factor = 1/#voices
imindt    =       0.016                                     ; minimum delay time
imaxdt    =       (imaxdt < imindt + .0025 ? imindt + .0025 : imaxdt) ; maximum delay time
idelaylim =       imaxdt + .01
p3        =       p3 + idelaylim                            ; increase dur to prevent cutoff of delayed signal
asig      =       gachorus                                  ; set asig to original signal

          if ivoices < 2 goto chorend                       ; output only the original signal if 1 voice
idelay1a  =       (imaxdt-imindt)*giseed + imindt           ; in range [imindt, imaxdt]
giseed    =       frac(giseed*105.947)
idelay2a  =       .8*idelay1a + .4*idelay1a*giseed          ; in range [.8*idelay1a, 1.2*idelay1a]
giseed    =       frac(giseed*105.947)
kdeltime  linseg  idelay1a, p3, idelay2a
adump     delayr  idelaylim
adelay    deltapi kdeltime
          delayw  gachorus
igain1    =       .2*giseed + 0.8                           ; in range [.8, 1.0]
giseed    =       frac(giseed*105.947)
asig      =       asig + (igain1 * adelay)

          if ivoices < 3 goto chorend
idelay1b  =       (imaxdt-imindt)*giseed + imindt           ; in range [imindt, imaxdt]
giseed    =       frac(giseed*105.947)
idelay2b  =       .8*idelay1b + .4*idelay1b*giseed          ; in range [.8*idelay1b, 1.2*idelay1b]
giseed    =       frac(giseed*105.947)
idelay3b  =       .8*idelay1b + .4*idelay1b*giseed          ; in range [.8*idelay1b, 1.2*idelay1b]
giseed    =       frac(giseed*105.947)
kdeltime  linseg  idelay1b, p3/2, idelay2b, p3/2, idelay3b
adump     delayr  idelaylim
adelay    deltapi kdeltime
          delayw  gachorus
igain2    =       .2*giseed + 0.8                           ; in range [.8, 1.0]
giseed    =       frac(giseed*105.947)
asig      =       asig + (igain2 * adelay)

          if ivoices < 4 goto chorend
idelay1c  =       (imaxdt-imindt)*giseed + imindt           ; in range [imindt, imaxdt]
giseed    =       frac(giseed*105.947)
idelay2c  =       .8*idelay1c + .4*idelay1c*giseed          ; in range [.8*idelay1c, 1.2*idelay1c]
giseed    =       frac(giseed*105.947)
idelay3c  =       .8*idelay1c + .4*idelay1c*giseed          ; in range [.8*idelay1c, 1.2*idelay1c]
giseed    =       frac(giseed*105.947)
kdeltime  linseg  idelay1c, p3/2, idelay2c, p3/2, idelay3c
adump     delayr  idelaylim
adelay    deltapi kdeltime
          delayw  gachorus
igain3    =       .2*giseed + 0.8                           ; in range [.8, 1.0]
giseed    =       frac(giseed*105.947)
asig      =       asig + (igain3 * adelay)

          if ivoices < 5 goto chorend
idelay1d  =       (imaxdt-imindt)*giseed + imindt           ; in range [imindt, imaxdt]
giseed    =       frac(giseed*105.947)
idelay2d  =       .8*idelay1d + .4*idelay1d*giseed          ; in range [.8*idelay1d, 1.2*idelay1d]
giseed    =       frac(giseed*105.947)
kdeltime  linseg  idelay1d, p3, idelay2d
adump     delayr  idelaylim
adelay    deltapi kdeltime
          delayw  gachorus
igain4    =       .2*giseed + 0.8                           ; in range [.8, 1.0]
giseed    =       frac(giseed*105.947)
asig      =       asig + (igain4 * adelay)

chorend:
asig      =       asig * iattn                              ; attenuate the accumulated signal
          out     asig
gachorus  =       0
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; chorus.sco (in the global subdirectory on the CD-ROM)

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

;p1   p2      p3    p4      p5        p6      p7      p8      p9  p10
;     start   dur   amp     Hertz     vibr    attk    dec     br  inst
i77    1.000    5   10000   558.080   1.000   0.230   0.100   5   2   ; with chorus   
i77    5.000   10   10000   279.040   1.000   0.230   0.100   5   2
i77    7.000    5   10000   837.120   1.000   0.230   0.100   5   2
i77    9.000    6   10000   697.600   1.000   0.230   0.100   5   2
i77   13.000    3   10000   976.640   1.000   0.130   0.100   5   2

;[two-second break between notes - the 16.5 second duration of i177 ends before the next note begins]

i77   18.000    3   10000   976.640   1.000   0.130   0.100   5   2   ; without chorus

; chorus (use only one line at a time)------------------------------------------------
;      start  dur   delay   voices
 i177   1     15    0.04    5      ; chorus (5 voices)
;i177   1     15    0.04    2      ; alternate example: doubling (2 voices)

 i177  18      3    0.00    1      ; no chorus (1 voice)
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
