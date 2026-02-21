<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; flanging.orc  (in the global subdirectory on the CD-ROM)

; instr 78 - general wind instrument going to flanging
; instr 178 - global flanging 


giseed    =       .5
giwtsin   =       1
gaflange  init    0
;______________________________________________________________________________________________________
instr 78                                                    ; general wind instrument going to flanging
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
gaflange  =       gaflange + asig                           ; send signal to global flanger
;         out     asig                                      ; DO NOT OUTPUT asig
          endin
;______________________________________________________________________________________________________
instr 178                                                   ; global flanging (with feedback)
; parameters
; p4 flanging depth          "amount" of flanging: 0=minimum amount, 1=maximum
; p5 minimum delay time      range: .001-.008" (must be greater than zero)
; p6 maximum delay time      e.g. .003-.016" (must be greater than minimum delay time)
; p7 flanging rate           rate of change between minimum and maximum delay times 
;                               set so that flanger sweeps up and down every few seconds
;                               typical values range from .25 (4" sweeps) to .5 (2" sweeps)
; p8 % of feedback           typical values vary from .1 to .5
;                               0=no feedback, 
;                               values close to 1.0 produce video game effects
; p9 flange switch           flanging on-off switch
;                               0=no flanging (original signal only without flanging)
;                               1=flanging (both original and flanged signals)

idepth    =       p4
idepth    =       (idepth < 0 ? 0 : idepth)
idepth    =       (idepth > 1 ? 1 : idepth)
imindt    =       p5
imaxdt    =       p6
imindt    =       (p5 > p6 ? p6 : imindt)
imaxdt    =       (p5 > p6 ? p5 : imaxdt)
imindt    =       (imindt < .001 ? .001 : imindt)
imindt    =       (imindt > .008 ? .008 : imindt)
imaxdt    =       (imaxdt < imindt + .002 ? imindt + .002 : imaxdt)
irate     =       p7
irate     =       (irate < 0.000001 ? 0.000001 : irate)
ifeedback =       p8
ifeedback =       (ifeedback < .01 ? .01 : ifeedback)
ifeedback =       (ifeedback > .99 ? .99 : ifeedback)
iswitch   =       p9
idelaylim =       imaxdt + .01
p3        =       p3 + imaxdt*log(.001)/log(ifeedback)      ; extend duration to avoid early cutoff
asig      =       gaflange                                  ; set asig to original signal

          if iswitch < 1 goto flangend
kdeltime  oscil   0.5, irate, giwtsin, giseed               ; sweeping
giseed    =       frac(giseed*105.947)
kdeltime  =       kdeltime + 0.5                            ; normalize to [0, 1]
kdeltime  =       kdeltime * (imaxdt - imindt) + imindt
adump     delayr  idelaylim
adelay    deltapi kdeltime
                  ; add any custom feedback modifications (e.g. lowpass filtering) to adelay here
asource   =       gaflange + ifeedback*adelay
          delayw  asource 
aflange   =       idepth*adelay
asig      =       asig + aflange                            ; add flanged signal

flangend:
          out     asig
gaflange  =       0
          endin
;______________________________________________________________________________________________________

</CsInstruments>
<CsScore>
; flanging.sco (in the global subdirectory on the CD-ROM)

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

;p1   p2      p3   p4     p5        p6      p7      p8      p9   p10
;     start   dur  amp    Hertz     vibr    attk    dec     br   inst
i78    1.000   5   2000   558.080   1.000   0.230   0.100   5    2   ; with flanging   
i78    5.000  10   2000   279.040   1.000   0.230   0.100   5    2
i78    7.000   5   2000   837.120   1.000   0.230   0.100   5    2
i78    9.000   6   2000   697.600   1.000   0.230   0.100   5    2
i78   13.000   3   2000   976.640   1.000   0.130   0.100   5    2

;[6-second break between notes - the duration of i178 (plus ringtime) ends before next note begins]

i78   22.000   3   5000   976.640   1.000   0.130   0.100   5    2   ; without flanging

;flanging (use only one line at a time)---------------------------------
;p1    p2     p3   p4     p5      p6      p7      p8        p9
;      start  dur  depth  mindt   maxdt   rate    feedbck   switch
 i178   1.0   15   0.25   0.004   0.008   0.333   0.99      1        ; extreme flanged signal 
;i178   1.0   15   0.25   0.004   0.008   0.333   0.4       1        ; alternate milder example
 i178  22.0    3   0.00   0.000   0.000   0.000   0.0       0        ; original signal only
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
