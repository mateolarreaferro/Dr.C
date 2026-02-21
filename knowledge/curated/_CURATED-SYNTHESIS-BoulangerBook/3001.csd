<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;---------------------------------------------------------------------------
; A MULTI-EFFECTS SYSTEM
;---------------------------------------------------------------------------
; 3002. PLUCK
; 3011. COMPRESSOR/LIMITER/EXPANDER
; 3099. MIXER
;---------------------------------------------------------------------------

          zakinit 30, 30

;---------------------------------------------------------------------------
; SOUND SOURCES
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
; PLUCK PHYSICAL MODEL
;---------------------------------------------------------------------------
          instr     3002
iamp      =         p4                  ; AMPLITUDE
ifqc      =         cpspch(p5)               ; CONVERT TO FREQUENCY
itab1     =         p6                  ; INITIAL TABLE
imeth     =         p7                  ; DECAY METHOD
ioutch    =         p8                  ; OUTPUT CHANNEL
kamp      linseg    0, .002, iamp, p3-.004, iamp, .002, 0  ; DECLICK
aplk      pluck     kamp, ifqc, ifqc, itab1, imeth         ; PLUCK WAVEGUIDE MODEL
          zawm      aplk, ioutch                           ; WRITE TO OUTPUT
gifqc     =         ifqc
          endin
;---------------------------------------------------------------------------
; COMPRESSOR/LIMITER
;---------------------------------------------------------------------------
          instr     3011
ifqc      =         1/p4                ; RMS CALCULATION FREQUENCY
ideltm    =         p5                  ; DELAY TIME TO APPLY COMPRESSION TO INITIAL DYNAMICS
itab      =         p6                  ; COMPRESSOR/LIMITER TABLE
ipostgain =         p7                       ; POST GAIN
iinch     =         p8                  ; INPUT CHANNEL
ioutch    =         p9                  ; OUTPUT CHANNEL
kenv      linseg    0, .02, 1, p3-.04, 1, .02, 0  ; AMP ENVELOPE TO DECLICK.
asig      zar       iinch               ; READ INPUT CHANNEL
kamp      rms       asig, ifqc          ; FIND RMS LEVEL
kampn     =         kamp/30000          ; NORMALIZE RMS LEVEL 0-1.
kcomp     tablei    kampn,itab,1,0      ; LOOK UP COMPRESSION VALUE IN TABLE
adel1     delayr    ideltm              ; DELAY FOR THE INPUT DELAY TIME, 1/ifqc/2 IS TYPICAL
          delayw    asig                ; WRITE TO DELAY LINE
acomp     =         kcomp*adel1*ipostgain ; COMPRESS THE DELAYED SIGNAL AND POST GAIN,
          zaw       acomp*kenv, ioutch  ; DECLICK AND WRITE TO OUTPUT CHANNEL
          endin
;---------------------------------------------------------------------------
; MIXER SECTION
;---------------------------------------------------------------------------
;    STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN

          instr     3099 ; MIXER
asig1     zar       p4
igl1      init      p5*p6
igr1      init      p5*(1-p6)
asig2     zar       p7
igl2      init      p8*p9
igr2      init      p8*(1-p9)
asig3     zar       p10
igl3      init      p11*p12
igr3      init      p11*(1-p12)
asig4     zar       p13
igl4      init      p14*p15
igr4      init      p14*(1-p15)
asigl     =         asig1*igl1 + asig2*igl2 + asig3*igl3 + asig4*igl4
asigr     =         asig1*igr1 + asig2*igr2 + asig3*igr3 + asig4*igr4
          outs      asigl, asigr
          zacl      0, 30
          endin

</CsInstruments>
<CsScore>


;---------------------------------------------------------------------------
; A MULTI-EFFECTS SYSTEM
;---------------------------------------------------------------------------
; 3002. PLUCK
; 3011. COMPRESSOR/LIMITER/EXPANDER
; 3099. MIXER
;---------------------------------------------------------------------------
; PLAIN PLUCK
;---------------------------------------------------------------------------
;       STA  DUR    AMP   FQC   FUNC  METH OUTCH
i 3002  0.0  1.6  16000  7.00   0     1    1
i 3002  0.2  1.4  12000  7.05   .     .    .
i 3002  0.4  1.2  10400  8.00   .     .    .
i 3002  0.6  1.0  12000  8.05   .     .    .
i 3002  0.8  0.8  16000  7.00   .     .    .
i 3002  1.0  0.6  12000  7.05   .     .    .
i 3002  1.2  0.4  10400  8.00   .     .    .
i 3002  1.4  0.2  12000  8.05   .     .    .
;---------------------------------------------------------------------------
; MIXER
;    STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN
i3099 0   2    1    1     1    1    1     0    3    0     1    4    0     0
;---------------------------------------------------------------------------
; COMPRESSION
;---------------------------------------------------------------------------
i 3002  2.0  1.6  16000  7.00   0     1    1
i 3002  2.2  1.4  12000  7.05   .     .    .
i 3002  2.4  1.2  10400  8.00   .     .    .
i 3002  2.6  1.0  12000  8.05   .     .    .
i 3002  2.8  0.8  16000  7.00   .     .    .
i 3002  3.0  0.6  12000  7.05   .     .    .
i 3002  3.2  0.4  10400  8.00   .     .    .
i 3002  3.4  0.2  12000  8.05   .     .    .
;---------------------------------------------------------------------------
; COMPRESSION CURVE
f 6 2 1024 7 1 128 1 128 .4 256 .2 256 .1 256 .01
;---------------------------------------------------------------------------
; COMPRESSOR/LIMITER
;       STA  DUR  RMSTIME  DELTIME  TABLE  POSTGAIN  INCH  OUTCH
i 3011  2    1.6  .02      .01       6     1.5       1     2
; MIXER
;     STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN
i 3099 2   2    2    1     1    2    1     0    6    0     1    7    0     0
s
;---------------------------------------------------------------------------
; PLAIN PLUCK
;---------------------------------------------------------------------------
;       STA  DUR  AMP    FQC   FUNC  METH  OUTCH
i 3002  0.0  1.6  16000  7.00   0     1    1
i 3002  0.2  1.4  12000  7.05   .     .    .
i 3002  0.4  1.2  10400  8.00   .     .    .
i 3002  0.6  1.0  12000  8.05   .     .    .
i 3002  0.8  0.8  16000  7.00   .     .    .
i 3002  1.0  0.6  12000  7.05   .     .    .
i 3002  1.2  0.4  10400  8.00   .     .    .
i 3002  1.4  0.2  12000  8.05   .     .    .
;--------------------------------------------------------------------------
; MIXER
;    STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN
i3099 0   2    1    1     1    1    1     0    3    0     1    4    0     0
;---------------------------------------------------------------------------
; LIMITING
;---------------------------------------------------------------------------
i 3002  2.0  1.6  16000  7.00   0     1    1
i 3002  2.2  1.4  12000  7.05   .     .    .
i 3002  2.4  1.2  10400  8.00   .     .    .
i 3002  2.6  1.0  12000  8.05   .     .    .
i 3002  2.8  0.8  16000  7.00   .     .    .
i 3002  3.0  0.6  12000  7.05   .     .    .
i 3002  3.2  0.4  10400  8.00   .     .    .
i 3002  3.4  0.2  12000  8.05   .     .    .
;---------------------------------------------------------------------------
; LIMITING CURVE
f 6 2 1025 7 1 256 1 512 .01 257 .01
; COMPRESSOR/LIMITER
;       STA  DUR  RMSTIME  DELTIME  TABLE  POSTGAIN  INCH  OUTCH
i 3011  2    1.6  .02      .01       6     1.5       1     2
; MIXER
;     STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN
i 3099 2   2    2    1     1    2    1     0    6    0     1    7    0     0
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>1</width>
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
