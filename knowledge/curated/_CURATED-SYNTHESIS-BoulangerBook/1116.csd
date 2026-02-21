<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

        instr 1116
;-------------------------------------------------------; PARAMETER LIST
;p4 : MAXIMUM OVERALL AMPLITUDE
;p5 : OVERALL AMPLITUDE ENVELOPE FUNCTION TABLE
;p6 : MINIMUM GRAIN DURATION
;p7 : MAXIMUM GRAIN DURATION
;p8 : GRAIN DURATION FUNCTION
;p9 : GRAIN WAVEFORM FUNCTION TABLE
;p10: GRAIN ENVELOPE FUNCTION TABLE
;p11: LOWER BAND LIMIT MINIMUM FREQUENCY 
;p12: LOWER BAND LIMIT MAXIMUM FREQUENCY
;p13: LOWER BAND LIMIT SHAPE FUNCTION TABLE
;p14: UPPER BAND LIMIT MINIMUM FREQUENCY 
;p15: UPPER BAND LIMIT MAXIMUM FREQUENCY
;p16: LOWER BAND LIMIT SHAPE FUNCTION TABLE
;p17: MINIMUM C/M
;p18: MAXIMUM C/M
;p19: C/M FUNCTION
;p20: MINIMUM FM INDEX
;p21: MAXIMUM FM INDEX
;p22: FM INDEX FUNCTION
;p23: MAXIMUM PAN VALUES:
;                        BEYOND LEFT SPEAKER < -1
;                        LEFT SPEAKER = -1
;                        BETWEEN SPEAKERS <1 AND > -1
;                        RIGHT SPEAKER = 1
;                        BEYOND RIGHT SPEAKER = -1
;p24: PAN FUNCTION
;p25: MAXIMUM SCATTER (1 COVERS FULL SPREAD BETWEEN SPEAKERS)
;p26: SCATTER FUNCTION
;p27: SEED FOR RANDOM NUMBER GENERATORS (0<p27<1)
;----------------------------------------; GENERAL INITIALIZATION
idur    =       p3                       ; DURATION
iseed   =       p27                      ; RANDOM NUMBER SEED
;----------------------------------------; OVERALL AMPLITUDE
imaxamp =       p4                       ; MAXIMUM AMPLITUDE
iampfunc=       p5                       ; AMPLITUDE FUNCTION TABLE
kenv    oscil1  0,imaxamp,idur,iampfunc  ; OVERALL ENVELOPE
;----------------------------------------; GRAIN DURATION and RATE
imingd  =       p6/1000.0                ; MINIMUM GRAIN DURATION
imaxgd  =       p7/1000.0                ; MAXIMUM GRAIN DURATION
igddiff =       imaxgd-imingd            ; DIFFERENCE
igdfunc =       p8                       ; GRAIN DURATION FUNCTION TABLE
kgdur   oscil1  0,igddiff,idur,igdfunc   ; GRAIN DURATION FLUCTUATION
kgdur   =       imingd+kgdur             ; GRAIN DURATION
kgrate  =       1.0/kgdur                ; GRAIN RATE
;----------------------------------------; FREQUENCY BAND LOWER LIMIT
ilfbmin =       p11                      ; MINIMUM FREQUENCY OF LIMIT
ilfbmax =       p12                      ; MAXIMUM FREQUENCY OF LIMIT
ilfbdiff=       ilfbmax-ilfbmin          ; DIFFERENCE
ilbffunc=       p13                      ; LOWER LIMIT FUNCTION
klfb    oscil1  0,ilfbdiff,idur,ilbffunc ; LOWER LIMIT FLUCTUATION       
klfb    =       ilfbmin+klfb             ; LOWER LIMIT
;----------------------------------------; FREQUENCY BAND UPPER LIMIT
iufbmin =       p14                      ; MINIMUM FREQUENCY OF LIMIT
iufbmax =       p15                      ; MAXIMUM FREQUENCY OF LIMIT
iufbdiff=       iufbmax-iufbmin          ; DIFFERENCE
iubffunc=       p16                      ; UPPER LIMIT FUNCTION
kufb    oscil1  0,iufbdiff,idur,iubffunc ; UPPER LIMIT FLUCTUATION
kufb    =       iufbmin+kufb             ; UPPER LIMIT
;----------------------------------------; CARRIER TO MODULATOR RATIO
icmrmin =       p17                      ; MINIMUM C/M
icmrmax =       p18                      ; MAXIMUM C/M
icmrdiff=       icmrmax-icmrmin          ; C/M DIFF
icmrfunc=       p19                      ; C/M FLUCTUATION FUNCTION
kcmr    oscil1  0,icmrdiff,idur,icmrfunc ; CARRIER TO MODULATOR RATIO FLUCTUATION
kcmr    =       icmrmin+kcmr             ; CARRIER TO MODULATOR RATIO
;----------------------------------------; INDEX
iidxmin =       p20                      ; MINIMUM INDEX
iidxmax =       p21                      ; MAXIMUM INDEX
iidxdiff=       iidxmax-iidxmin          ; INDEX DIFF
iidxfunc=       p22                      ; INDEX FLUXTUATION FUNCTION
kidx    oscil1  0,iidxdiff,idur,iidxfunc ; INDEX FLUCTUATION
kidx    =       iidxmin+kidx             ; CARRIER TO MODULATOR RATIO
;----------------------------------------; SCATTER      
imaxscat=       p25                      ; MAXIMUM SCATTER
isctfunc=       p26                      ; SCATTER FUNCTION
kscat   oscil1  0,imaxscat,idur,isctfunc ; CURRENT MAXIMUM SCATTER
kgscat  randh   kscat,kgrate,iseed/5     ; GRAIN RANDOM SCATTER
;----------------------------------------; PANNING
isr2    =       sqrt(2.0)                ; SQUARE ROOT OF 2
isr2b2  =       isr2/2.0                 ; HALF OF SQUARE ROOT OF 2
imaxpan =       p23                      ; MAXIMUM POSSIBLE PAN
ipanfunc=       p24                      ; PAN FUNCTION
kpan    oscil1  0,imaxpan,idur,ipanfunc  ; PAN WITHOUT SCATTER
kpan    =       kpan+kgscat              ; ADD GRAIN SCATTER            
        if kpan<-1 kgoto beyondl         ; CHECK FOR PAN BEYOND LEFT SPEAKER
        if kpan>1  kgoto beyondr         ; CHECK FOR PAN BEYOND RIGHT SPEAKER
;----------------------------------------; PAN BETWEEN SPEAKERS
ktemp   =       sqrt(1+kpan*kpan)
kpleft  =       isr2b2*(1-kpan)/ktemp
kpright =       isr2b2*(1+kpan)/ktemp
        kgoto   donepan
beyondl:                                 ; PAN BEYOND LEFT SPEAKER
kpleft  =       2.0/(1+kpan*kpan)
kpright =       0
        kgoto   donepan
beyondr:                                 ; PAN BEYOND RIGHT SPEAKER
kpleft  =       0
kpright =       2.0/(1+kpan*kpan)
donepan:
;----------------------------------------; GRAIN ENVELOPE
igefunc =       p10                      ; GRAIN ENVELOPE FUNCTION TABLE
kgenvf  =       kgrate                   ; GRAIN ENVELOPE FREQUENCY
kgenv   oscili  1.0,kgenvf,igefunc       ; ENVELOPE
;----------------------------------------; GRAIN FREQUENCY
kgband  =       kufb-klfb                ; CURRENT FREQUENCY BAND
kgfreq  randh   kgband/2,kgrate,iseed    ; GENERATE FREQUENCY
kgfreq  =       klfb+kgfreq+kgband/2     ; FREQUENCY
;----------------------------------------; GRAIN AMPLITUDE SCALING FACTOR 
                                         ; (BETWEEN 0.5 AND 1)
ihmaxfc =       0.25                     ; HALF OF MAXIMUM AMPLITUDE DEVIATION
kgafact randh   ihmaxfc,kgfreq,iseed/3   ; -ihmaxfc < random number < +ihmaxfc
kgafact =       1.00-(ihmaxfc+kgafact)   ; 2*ihmaxfc < scaling factor < 1.00
;----------------------------------------; GRAIN GENERATOR
igfunc  =       p9                       ; GRAIN WAVEFORM FUNCTION TABLE
agrain  foscili kgenv,kgfreq,1,kcmr,kidx,igfunc ; FM GENERATOR            
;----------------------------------------; GRAIN DELAY (UP TO ITS WHOLE DURATION)
kgdel   randi   kgdur/2,kgrate,iseed/2   ; RANDOM SAMPLE DELAY
kgdel   =       kgdel+kgdur/2            ; MAKE IT POSITIVE
adump   delayr  imaxgd                   ; DELAY LINE
adelgr  deltapi kgdel
        delayw  kgafact*agrain
;----------------------------------------; DOPPLER SHIFT (FROM Csound MANUAL)
ihspeakd=       5.0                      ; HALF OF THE DISTANCE BETWEEN SPEAKERS (m)
isndsp  =       331.45                   ; SOUND SPEED IN AIR (m/sec)
impandel=       (imaxpan+imaxscat)*ihspeakd/isndsp ; MAXIMUM PAN DELAY
kpdel   =       kpan*ihspeakd/isndsp     ; FIND PAN DELAY
adump   delayr  impandel                 ; SET MAXIMUM DOPPLER DELAY
agdop   deltapi abs(kpdel)               ; TAP DELAY ACCORDING TO PAN VALUE
        delayw  adelgr                   ; DELAY SIGNAL
;----------------------------------------; OUTPUT
asig    =       kenv*agdop
        outs    kpleft*asig,kpright*asig
        endin


</CsInstruments>
<CsScore>
;1116.SCO     CREATES A GRANULAR CLOUD
;                (C) RAJMIL FISCHMAN, 1997
;-----------------------------------------
;GRAIN WAVEFORM: SINEWAVE 
f 1  0 8192 10 1 
;OVERALL AMPLITUDE: HALF SINE 
f 2  0 1024 9 0.5 1 0 
;GRAIN DURATION
f 3  0 2048 7 1 996 0 64 0.3 64 0 256 0.3 256 0.7 512 0.52
;GRAIN ENVELOPE: HALF SINE 
f 4  0 1024 9 0.5 1 0 
;LOWER BAND LIMIT
f 5  0 2048 7 1 1024 0.2 256 1 512 0 256 0.9
;UPPER BAND LIMIT
f 6  0 2048 7 0 1024 0.8 256 0.5 512 1 256 0.8
;C/M RATIO
f 7  0 2048 7 0 128 1 128 0.16 128 0.637 512 0.23 128 0.24 256 0.8 256 0.3
;FM INDEX
f 8  0 2048 7 0 256 0.1 256 0.25 256 0.55 128 0.42 128 0.8 256 1 512 0.4 256 0.7
;PAN
f 9  0 2048 9 0.5 0.3 90  0.7 0.5 90  1.6 0.7 90  2.3 0.9 90 7.8 1 90
;SCATTER
f 10 0 2048 10 1 1
;--------------------------------------------------------------------
;       p3  p4    p5  p6  p7  p8 p9  p10 p11  p12  p13 p14  p15  p16
;           CLOUD    |GRAIN             |CLOUD FREQUENCY BAND       |
;       DUR MAX   ENV|DURATION   WFM ENV|LOWER LIMIT  |UPPER LIMIT  |
;       SEC AMP   FN | (MSEC)    FN  FN |MIN  MAX     |MIN  MAX     |
;                    |MIN MAX FN        |FREQ FREQ FN |FREQ FREQ FN |
;--------------------------------------------------------------------
i 1116 0 20  10000 2   10  30  3  1   4   1000 2500 5   2500 4670 6

;-------------------------------------------------
;     p17 p18 p19 p20 p21 p22 p23 p24 p25 p26 p27
;     FM PARAMETERS          |SPATIALIZATION
;     C/M        |INDEX      |PAN    |SCATTER
;     MIN MAX FN |MIN MAX FN |MAX FN |MAX FN  SEED
;-------------------------------------------------
      1   4   7   1   8   8   1.5 9   1   10  0.5
e


</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>4</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
