<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; multnote.orc (in the noteffct subdirectory on the CD-ROM)

; instr 176 - general wavetable wind instrument with multiprocessing


giseed    =       .5
giwtsin   =       1
;______________________________________________________________________________________________________
instr 176                  ; general wavetable wind instrument with multiprocessing
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
; p12 flanging depth ("amount" of flanging): 0=minimum amount, 1=maximum
; p13 minimum delay time; range: .001-.008" (must be greater than zero)
; p14 maximum delay time, e.g. .003-.016" (must be greater than minimum delay time)
; p15 flanging rate (rate of change between minimum and maximum delay times)
;         set so that flanger sweeps up and down every few seconds
;         typical values range from .25 (4" sweeps) to .5 (2" sweeps)
; p16 % of feedback, typical values vary from .1 to .5
;         0=no feedback, values close to 1.0 produce video game effects
; p17 phasing-flanging-ringModulation switch
;         0=no flanging (original signal only without phasing, flanging, or ring modulation)
;         1=phasing only, 2=ring modulation, 3=flanging and ring modulation, 4=flanging
; p18 initial frequency for modulated cosine
; p19 ending frequency for modulated cosine
; p20 initial filter cutoff/center frequency
; p21 ending filter cutoff/center frequency
; p22 initial bandwidth for reson and areson filters
; p23 ending bandwidth for reson and areson filters
; p24 percent duration to wait before glissando 
;        (e.g., p6=.1 means hold the initial frequency for 10% of the note duration before glissing)
; p25 percent duration of glissando
;        (e.g., p7=.5 means gliss over half the note's duration)
; p26 attenuation factor for the input signal
; p27 ring time for comb filter
; p28 filter switch (0=no filter, 1=LP filter, 2=BP filter, 3=notch filter, 4=HP filter, 5=comb filter)
; p29 initial panning position (1 is full left, 0 is full right, and .5 is center)
; p30 intermediate panning  position (1 is full left, 0 is full right, and .5 is center)
; p31 ending panning position (1 is full left, 0 is full right, and .5 is center)
; p32 percent duration of change from initial panning position to intermediate panning position
;         (e.g., .5 means make the first change over half the note's duration)
; p33 initial reverb time
; p34 intermediate reverb time
; p35 final reverb time
; p36 % of reverb relative to source signal at start of note
; p37 % of reverb relative to source signal at middle of note (intermediate position)
; p38 % of reverb relative to source signal at end of note
; p39 amplitude scaler for echos (amount each echo is attenuated)
; p40 echo time (should be greater than 40ms to be heard as a discrete echo)
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
;___________________________________________________________; phasing initial variables
ioff1     =       p11
ioff2     =       2 * ioff1
ioff3     =       3 * ioff1
ioff4     =       4 * ioff1
;___________________________________________________________; flanging initial variables 
idepth    =       p12
idepth    =       (idepth < 0 ? 0 : idepth)
idepth    =       (idepth > 1 ? 1 : idepth)
imindt    =       p13
imaxdt    =       p14
imindt    =       (p13 > p14 ? p14 : imindt)
imaxdt    =       (p13 > p14 ? p13 : imaxdt)
imindt    =       (imindt < .001 ? .001 : imindt)
imindt    =       (imindt > .008 ? .008 : imindt)
imaxdt    =       (imaxdt < imindt + .002 ? imindt + .002 : imaxdt)
irate     =       p15
irate     =       (irate < 0.000001 ? 0.000001 : irate)
ifeedback =       p16
ifeedback =       (ifeedback < .01 ? .01 : ifeedback)
ifeedback =       (ifeedback > .99 ? .99 : ifeedback)
iswitch1  =       p17
idelaylim =       imaxdt + .01
iadd      =       imaxdt*log(.001)/log(ifeedback)           ; extend duration to avoid early cutoff
p3        =       (iswitch1 = 3 ? p3+iadd : p3)
p3        =       (iswitch1 = 4 ? p3+iadd : p3)
;___________________________________________________________; ring modulation initial variables 
imodfreq  =       p18
imodfreq2 =       p19
iwave     =       1                                         ; sine wave (can try with other wavetables)
;___________________________________________________________; filter initial variables 
ifilt1    =       p20                                       ; first filter frequency
ifilt2    =       p21                                       ; last filter frequency
ibw1      =       p22                                       ; first bandwidth for reson and areson filters
ibw2      =       p23                                       ; last bandwidth for reson and areson filters
p24       =       (p24 <= 0 ? .001 : p24)                   ; check for 0 values and fix them
p25       =       (p25 <= 0 ? .001 : p25)                   ; check for 0 values and fix them
iwait     =       p24 * idur                                ; duration of wait before glissando
igliss    =       p25 * idur                                ; duration of glissando
          if (iwait + igliss < idur) goto filt1
iwait     =       .99 * idur * iwait/(iwait + igliss)
igliss    =       .99 * idur * igliss/(iwait + igliss)
filt1:
istay     =       idur - (iwait + igliss)                   ; hold for remainder of note
iattn     =       p26                                       ; set attenuation factor for input signal
iring     =       p27                                       ; ring time for comb filter
iswitch2  =       p28                                       ; switch chooses filter 
                                                            ;   (1=LP, 2=BP, 3=notch, 4=HP, 5=comb)
iloop     =       1/(ifreq)                                 ; comb loop time (loop time is 1/fundFreq)
p3        =       (iswitch2 = 5 ? p3+2*iring : p3)          ; extend comb duration to avoid early cutoff
;___________________________________________________________; spatialization initial variables 
ileft1    =       p29                                       ; initial position for pan - percent left channel
ileft2    =       p30                                       ; second position for pan - percent left channel
ileft3    =       p31                                       ; ending position for pan - percent left channel
ileft1    =       (ileft1 <= 0 ? .01 : ileft1)
ileft1    =       (ileft1 >= 1 ? .99 : ileft1)
ileft2    =       (ileft2 <= 0 ? .01 : ileft2)
ileft2    =       (ileft2 >= 1 ? .99 : ileft2)
ileft3    =       (ileft3 <= 0 ? .01 : ileft3)
ileft3    =       (ileft3 >= 1 ? .99 : ileft3)
iright1   =       1 - ileft1                                ; initial position for pan - percent right channel
iright2   =       1 - ileft2                                ; second position for pan - percent right channel
iright3   =       1 - ileft3                                ; ending position for pan - percent right channel
p32       =       (p32 <= 0 ? .01 : p32)                    ; keep values between 0 and 1
p32       =       (p32 >= 1 ? .99 : p32)
itime1    =       p32 * idur                                ; time for first panning/rev segment
itime2    =       idur - itime1                             ; time for second panning/rev segment

irevtime1 =       p33                                       ; set first duration of reverb time
irevtime2 =       p34                                       ; set middle duration of reverb time
irevtime3 =       p35                                       ; set final duration of reverb time
irev1     =       p36                                       ; first percent for reverberated signal
irev2     =       p37                                       ; middle percent for reverberated signal
irev3     =       p38                                       ; last percent for reverberated signal
irev1     =       (irev1 <= 0 ? .01 : irev1)                ; keep values between 0 and 1
irev1     =       (irev1 >= 1 ? .99 : irev1)
irev2     =       (irev2 <= 0 ? .01 : irev2)
irev2     =       (irev2 >= 1 ? .99 : irev2)
irev3     =       (irev3 <= 0 ? .01 : irev3)
irev3     =       (irev3 >= 1 ? .99 : irev3)
iunrev1   =       1 - irev1
iunrev2   =       1 - irev2
iunrev3   =       1 - irev3
iring     =       (irevtime3 > irevtime2 ? irevtime3 : irevtime2)
iring     =       (irevtime1 > iring ? irevtime1 : iring)
p3        =       p3 + iring                                ; lengthen p3 by longest reverb time

ifeedback =       p39                                       ; echo amplitude scale
iecho     =       p40                                       ; echo time
p3        =       p3 + iecho*log(.0001)/log(ifeedback)      ; also extend duration to avoid echo cutoff

;___________________________________________________________; other initial variables 
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
          if iswitch1 = 1 goto dophasing
awt1      oscili  amp1, kfreq, iwt1, iphase        
awt2      oscili  amp2, kfreq, iwt2, iphase
awt3      oscili  amp3, kfreq, iwt3, iphase
awt4      oscili  amp4, kfreq, iwt4, iphase
          goto    endphasing
;___________________________________________________________; phasing
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

endphasing:
asig      =       (awt1+awt2+awt3+awt4)*iamp/inorm
afilt     tone    asig, ibrite                              ; lowpass filter for brightness control
asig      balance afilt, asig
;___________________________________________________________; flanging
          if iswitch1 < 3 goto flangend
          if iswitch1 > 4 goto flangend
ainput    =       asig                                      ; set ainput to original signal
kdeltime  oscil   0.5, irate, giwtsin, giseed               ; sweeping
giseed    =       frac(giseed*105.947)
kdeltime  =       kdeltime + 0.5                            ; normalize to [0, 1]
kdeltime  =       kdeltime * (imaxdt - imindt) + imindt
adump     delayr  idelaylim
adelay    deltapi kdeltime
                  ; add any custom feedback modifications (e.g. lowpass filtering) to adelay here
asource   =       ainput + ifeedback*adelay
          delayw  asource 
aflange   =       idepth*adelay
asig      =       asig + aflange                            ; add flanged signal
flangend:
;___________________________________________________________; ring modulation
          if iswitch1 < 2 goto rmend                        ; no ring modulation
          if iswitch1 > 3 goto rmend                        ; no ring modulation
ainput    =       asig                                      ; set ainput to original signal
kmodfr    linseg  imodfreq, iwait, imodfreq, igliss, imodfreq2, istay, imodfreq2
amod      oscili  1, kmodfr, iwave, .25                     ; modulator
armsig    =       ainput * amod                             ; ring modulated signal 
asig      =       (armsig + ainput)/2                       ; output combined signal
rmend:
;___________________________________________________________; filtering
asig      =       asig * iattn                              ; attenuation
kfreq     linseg  ifilt1, iwait, ifilt1, igliss, ifilt2, istay, ifilt2
kbw       linseg  ibw1, iwait, ibw1, igliss, ibw2, istay, ibw2

          if iswitch2 = 1 goto lowpass
          if iswitch2 = 2 goto bandpass
          if iswitch2 = 3 goto notch
          if iswitch2 = 4 goto highpass
          if iswitch2 = 5 goto comb
          goto    filtend

lowpass:
afilt     tone    asig,kfreq
afilt2    tone    afilt,kfreq               ; filter out high freqs: kfreq = half amplitude point
          goto    filtbal

bandpass:
afilt     reson   asig,kfreq,kbw,0
afilt2    reson   afilt,kfreq,kbw,0         ; bandpass: kfreq = center frequency of passband
          goto    filtbal

notch:
afilt     areson  asig,kfreq,kbw,1
afilt2    areson  afilt,kfreq,kbw,1         ; notch: kfreq = center frequency of notch
          goto    filtbal

highpass:
afilt     atone   asig,kfreq
afilt2    atone   afilt,kfreq               ; filter out low freqs: kfreq = half amplitude point
          goto    filtbal

filtbal:
asig      balance afilt2, asig              ; balance 
          goto    filtend

comb:
acomb     comb    asig,iring,iloop          ; args:  sig, ring time, loop time
asig      =       acomb
          goto    filtend
filtend:
;___________________________________________________________; spatialization
reverb:
apercent  linseg  irev1, itime1, irev2, itime2, irev3, 1, irev3                 ; percent reverb
aunreverb linseg  iunrev1, itime1, iunrev2, itime2, iunrev3, 1, iunrev3         ; remaining percent
krevtime  linseg  irevtime1, itime1, irevtime2, itime2, irevtime3, 1, irevtime3 ; reverb time
ac1       comb    asig, krevtime, .0297
ac2       comb    asig, krevtime, .0371
ac3       comb    asig, krevtime, .0411
ac4       comb    asig, krevtime, .0437
acomb     =       ac1 + ac2 + ac3 + ac4
ap1       alpass  acomb, .09683, .005
arev      alpass  ap1, .03292, .0017
asig      =       (aunreverb * asig) + (apercent * arev)    ; mix the signal

echo:
ainput    =       asig                                      ; set ainput to original signal
adelay    delayr  iecho
                  ; add any custom feedback modifications (e.g. lowpass filtering) to adelay here
asource   =       ainput + ifeedback*adelay
          delayw  asource 
asig      =       asig + adelay                             ; add echo signal

panning:
apanl     linseg  ileft1, itime1, ileft2, itime2, ileft3, 1, ileft3     ; amplitude envelope for left channel
apanr     linseg  iright1, itime1, iright2, itime2, iright3, 1, iright3 ; amplitude envelope for right channel
apanl     =       sqrt(apanl)
apanr     =       sqrt(apanr)
asigl     =       apanl * asig                              ; signal for left channel
asigr     =       apanr * asig                              ; signal for right channel

          outs    asigl, asigr                              ; output stereo signal
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; multnote.sco (in the noteffct subdirectory on the CD-ROM)
; note-specific multi-effect processor example (with flute)

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

t0 100
; no effects (except spatialization)
;p1  p2     p3   p4   p5      p6    p7    p8   p9 10 p11  p12 p13   p14   p15   p16  p17 p18  p19  p20  p21  p22 p23  p24  p25 p26 p27  p28 p29 p30 p31 p32  p33   p34   p35   p36   p37   p38   p39   p40
;                                                    phas flanging...................... ringmod.. filters................................. spatialization..................................................
;    start  dur  amp  Hertz   vibr  att   dec  br in off  dep mindt maxdt rate  feed sw1 mfr1 mfr2 flt1 flt2 bw1 bw2  wait gls att ring sw2 pn1 pn2 pn3 dur1 rtim1 rtim2 rtim3 %rev1 %rev2 %rev3 eamp  etime
i176  1.000  5.5 3000 558.080 1.000 0.230 0.100 5 2  .05  .5  .005  0.008 0.333 0.5  0      1 200    55 1760 0      0 .1   .4  .2  0    1   .59 0   1   .5   0.091 0.441 0.927 0.123 0.290 0.443 0.415 0.231 ; LP
i176  5.000  9   3000 279.040 1.000 0.230 0.100 5 2  .04  .5  .0025 0.008 0.333 0.6  .      1 200   220 7040 1    100 .1   .4  .2  0    2   .59 0   1   .5   0.541 0.444 0.838 0.359 0.307 0.310 0.528 0.250 ; BP
i176  7.000  5   3000 837.120 1.000 0.230 0.100 5 2  .07  .5  .0045 0.008 0.333 0.4  .      1 200    55  220 1   1000 .2   .5  .2  0    3   .59 0   1   .5   0.960 0.708 0.243 0.284 0.280 0.853 0.485 0.186 ; notch
i176  9.000  6   3000 697.600 1.000 0.230 0.100 5 2  .025 .5  .0025 0.008 0.333 0.85 .      1 200   220 7040 0      0 .2   .4  .2  0    4   .59 0   1   .5   0.682 0.107 0.380 0.960 0.382 0.440 0.419 0.209 ; HP
i176 13.100 10   3000 976.640 1.000 0.230 0.100 5 2  .03  .5  .003  0.008 0.333 0.2  .      1 200   220 7040 0      0 .1   .4  .2  .3   5   .59 0   1   .5   0.873 0.570 0.973 0.745 0.915 0.652 0.527 0.264 ; comb
s

; phasing
i176  1.000  5.5 3000 558.080 1.000 0.230 0.100 5 2  .05  .5  .005  0.008 0.333 0.5  1      1 200    55 1760 0      0 .1   .4  .2  0    1   .59 0   1   .5   0.091 0.441 0.927 0.123 0.290 0.443 0.415 0.231 ; LP
i176  5.000  9   3000 279.040 1.000 0.230 0.100 5 2  .04  .5  .0025 0.008 0.333 0.6  .      1 200   220 7040 1    100 .1   .4  .2  0    2   .59 0   1   .5   0.541 0.444 0.838 0.359 0.307 0.310 0.528 0.250 ; BP
i176  7.000  5   3000 837.120 1.000 0.230 0.100 5 2  .07  .5  .0045 0.008 0.333 0.4  .      1 200    55  220 1   1000 .2   .5  .2  0    3   .59 0   1   .5   0.960 0.708 0.243 0.284 0.280 0.853 0.485 0.186 ; notch
i176  9.000  6   3000 697.600 1.000 0.230 0.100 5 2  .025 .5  .0025 0.008 0.333 0.85 .      1 200   220 7040 0      0 .2   .4  .2  0    4   .59 0   1   .5   0.682 0.107 0.380 0.960 0.382 0.440 0.419 0.209 ; HP
i176 13.100 10   3000 976.640 1.000 0.230 0.100 5 2  .03  .5  .003  0.008 0.333 0.2  .      1 200   220 7040 0      0 .1   .4  .2  .3   5   .59 0   1   .5   0.873 0.570 0.973 0.745 0.915 0.652 0.527 0.264 ; comb
s

; ring modulation
i176  1.000  5.5 3000 558.080 1.000 0.230 0.100 5 2  .05  .5  .005  0.008 0.333 0.5  2      1 200    55 1760 0      0 .1   .4  .2  0    1   .59 0   1   .5   0.091 0.441 0.927 0.123 0.290 0.443 0.415 0.231 ; LP
i176  5.000  9   3000 279.040 1.000 0.230 0.100 5 2  .04  .5  .0025 0.008 0.333 0.6  .      1 200   220 7040 1    100 .1   .4  .2  0    2   .59 0   1   .5   0.541 0.444 0.838 0.359 0.307 0.310 0.528 0.250 ; BP
i176  7.000  5   3000 837.120 1.000 0.230 0.100 5 2  .07  .5  .0045 0.008 0.333 0.4  .      1 200    55  220 1   1000 .2   .5  .2  0    3   .59 0   1   .5   0.960 0.708 0.243 0.284 0.280 0.853 0.485 0.186 ; notch
i176  9.000  6   3000 697.600 1.000 0.230 0.100 5 2  .025 .5  .0025 0.008 0.333 0.85 .      1 200   220 7040 0      0 .2   .4  .2  0    4   .59 0   1   .5   0.682 0.107 0.380 0.960 0.382 0.440 0.419 0.209 ; HP
i176 13.100 10   3000 976.640 1.000 0.230 0.100 5 2  .03  .5  .003  0.008 0.333 0.2  .      1 200   220 7040 0      0 .1   .4  .2  .3   5   .59 0   1   .5   0.873 0.570 0.973 0.745 0.915 0.652 0.527 0.264 ; comb
s

; flanging
i176  1.000  5.5 3000 558.080 1.000 0.230 0.100 5 2  .05  .5  .005  0.008 0.333 0.5  4      1 200    55 1760 0      0 .1   .4  .2  0    1   .59 0   1   .5   0.091 0.441 0.927 0.123 0.290 0.443 0.415 0.231 ; LP
i176  5.000  9   3000 279.040 1.000 0.230 0.100 5 2  .04  .5  .0025 0.008 0.333 0.6  .      1 200   220 7040 1    100 .1   .4  .2  0    2   .59 0   1   .5   0.541 0.444 0.838 0.359 0.307 0.310 0.528 0.250 ; BP
i176  7.000  5   3000 837.120 1.000 0.230 0.100 5 2  .07  .5  .0045 0.008 0.333 0.4  .      1 200    55  220 1   1000 .2   .5  .2  0    3   .59 0   1   .5   0.960 0.708 0.243 0.284 0.280 0.853 0.485 0.186 ; notch
i176  9.000  6   3000 697.600 1.000 0.230 0.100 5 2  .025 .5  .0025 0.008 0.333 0.85 .      1 200   220 7040 0      0 .2   .4  .2  0    4   .59 0   1   .5   0.682 0.107 0.380 0.960 0.382 0.440 0.419 0.209 ; HP
i176 13.100 10   3000 976.640 1.000 0.230 0.100 5 2  .03  .5  .003  0.008 0.333 0.2  .      1 200   220 7040 0      0 .1   .4  .2  .3   5   .59 0   1   .5   0.873 0.570 0.973 0.745 0.915 0.652 0.527 0.264 ; comb
s

; flanging and ring modulation
i176  1.000  5.5 3000 558.080 1.000 0.230 0.100 5 2  .05  .5  .005  0.008 0.333 0.5  3      1 200    55 1760 0      0 .1   .4  .2  0    1   .59 0   1   .5   0.091 0.441 0.927 0.123 0.290 0.443 0.415 0.231 ; LP
i176  5.000  9   3000 279.040 1.000 0.230 0.100 5 2  .04  .5  .0025 0.008 0.333 0.6  .      1 200   220 7040 1    100 .1   .4  .2  0    2   .59 0   1   .5   0.541 0.444 0.838 0.359 0.307 0.310 0.528 0.250 ; BP
i176  7.000  5   3000 837.120 1.000 0.230 0.100 5 2  .07  .5  .0045 0.008 0.333 0.4  .      1 200    55  220 1   1000 .2   .5  .2  0    3   .59 0   1   .5   0.960 0.708 0.243 0.284 0.280 0.853 0.485 0.186 ; notch
i176  9.000  6   3000 697.600 1.000 0.230 0.100 5 2  .025 .5  .0025 0.008 0.333 0.85 .      1 200   220 7040 0      0 .2   .4  .2  0    4   .59 0   1   .5   0.682 0.107 0.380 0.960 0.382 0.440 0.419 0.209 ; HP
i176 13.100 10   3000 976.640 1.000 0.230 0.100 5 2  .03  .5  .003  0.008 0.333 0.2  .      1 200   220 7040 0      0 .1   .4  .2  .3   5   .59 0   1   .5   0.873 0.570 0.973 0.745 0.915 0.652 0.527 0.264 ; comb
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
