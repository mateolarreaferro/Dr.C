<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
;---------------------------------------------------------------------------
; MIKELSON'S MULTI-FX SYSTEM
;---------------------------------------------------------------------------
; 3002. PLUCK
; 3013. TUBE AMP DISTORTION
; 3099. MIX
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
        zakinit 30, 30
;---------------------------------------------------------------------------
; SOUND SOURCE
;---------------------------------------------------------------------------
; PLUCK PHYSICAL MODEL
;---------------------------------------------------------------------------
        instr   3002
iamp    =       p4                  ; AMPLITUDE
ifqc    =       cpspch(p5)          ; CONVERT TO FREQUENCY
itab1   =       p6                  ; INITIAL TABLE
imeth   =       p7                  ; DECAY METHOD
ioutch  =       p8                  ; OUTPUT CHANNEL
kamp    linseg  0, .002, iamp, p3-.004, iamp, .002, 0  ; DECLICK
aplk    pluck   kamp, ifqc, ifqc, itab1, imeth         ; PLUCK WAVEGUIDE MODEL
        zawm    aplk, ioutch                           ; WRITE TO OUTPUT
gifqc   =       ifqc
        endin

;---------------------------------------------------------------------------
; PITCH SHIFTER
;---------------------------------------------------------------------------
        instr   3022
;ipshift =      p4
ipshift =       (p4<=1 ? p4-1 : p4/2)
itab1   =       p5
izin    =       p6
izout   =       p7
asig    zar     izin
kosc    oscil   1/gifqc, gifqc*ipshift, itab1
atmp    delayr  .1
aout    deltapi kosc+1/gifqc
        delayw  asig
        zaw     aout,izout
        endin
;---------------------------------------------------------------------------
; MIXER SECTION
;---------------------------------------------------------------------------
        instr   3099                    
asig1   zar     p4                  ; p4 = ch1 IN
igl1    init    p5*p6               ; p5 = ch1 GAIN
igr1    init    p5*(1-p6)           ; p6 = ch1 PAN
asig2   zar     p7                  ; p7 = ch2 IN
igl2    init    p8*p9               ; p8 = ch2 GAIN
igr2    init    p8*(1-p9)           ; p9 = ch2 PAN
asig3   zar     p10                 ; p10 = ch3 IN
igl3    init    p11*p12             ; p11 = ch3 GAIN
igr3    init    p11*(1-p12)         ; p12 = ch3 PAN
asig4   zar     p13                 ; p13 = ch4 IN
igl4    init    p14*p15             ; p14 = ch4 GAIN
igr4    init    p14*(1-p15)         ; p15 = ch4 PAN
asigl   =       asig1*igl1+asig2*igl2+asig3*igl3+asig4*igl4 
asigr   =       asig1*igr1+asig2*igr2+asig3*igr3+asig4*igr4 
        outs    asigl, asigr    
        zacl    0, 30   
        endin

</CsInstruments>
<CsScore>
;---------------------------------------------------------------------------
; PITCH SHIFTER
;---------------------------------------------------------------------------
i 3002  0.0  .8  16000  7.00   0     1    1
i 3002  0.8  .4  16000  7.00   0     1    1
i 3002  1.2  .8  16000  7.00   0     1    1

; SAW WAVE
f 9 0 1024 7 1 1024 0

; PITCH SHIFTER NEWFQC=SHIFT*FQC
;      STA  DUR  SHIFT  TABLE  INCH  OUTCH
i 3022 0.0  .8   .995   9      1     2       ; STEREO DETUNE
i 3022 0.8  .4   1.5    9      1     2       ; UP A FIFTH
i 3022 1.2  .8   .5     9      1     2       ; DOWN AN OCTAVE

; MIXER
;      STA DUR  CH1  GAIN  PAN  CH2  GAIN  PAN  CH3  GAIN  PAN  CH4  GAIN  PAN
i 3099 0   2.0  1    1     1    2    1     0    6    0     1    7    0     0

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
