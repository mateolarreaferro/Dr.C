<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; GLSNSE.O
; CSOUND CODE FOR RANDOM RING MODULATING INSTRUMENT DESCRIBED IN SECTION
; 3.11B AND FIGURE. 3.25 OF "COMPUTER MUSIC" - DODGE



               instr     1

; p3           =         dur
; p4           =         pitch
; p5           =         amp
; p6           =         bw%
; p7           =         gliss interval (in octave.point.decimal notation)

ifreq          =         cpspch(p4)          ; CONVERT PITCH TO HZ
iband          =         p6*ifreq            ; BANDWIDTH AS A PERCENTAGE OF STARTING FREQUENCY
ioct           =         octpch(p4)          ; CONVERT PITCH TO OCTAVE.POINT.DECIMAL NOTATION
igliss         =         p7                  ; GLISS INTERVAL IN OCTAVE NOTATION

amp            randi     p5,iband
aenv           linen     amp,.01,p3,.05
agliss         linseg    0,p3,igliss
afreq          =         cpsoct     (ioct+agliss)

aout           oscili    aenv,afreq,1
               out       aout
               endin

</CsInstruments>
<CsScore>
; GLSNSE.S
; SCORE FOR THE RING MODULATING INSTRUMENT IN SECTION 3.11B AND FIGURE 3.25 OF
; "COMPUTER MUSIC" - DODGE

f0 11
f1 0 1024 9 1 1 0

;       start   dur     pitch   amp     bw%     gliss_interval
i1      1       4      28.00    25000   .01     .81
i1      6       4      28.10    25000   .01    -.81
e
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
