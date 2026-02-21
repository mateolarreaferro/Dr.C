<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; basicfm.orc

; THIS INSTRUMENT IMPLEMENTS SIMPLE FREQUENCY MODULATION TO PRODUCE TIME-VARYING SPECTRA.


          instr 1

; p4      =         CARRIER FREQUENCY
; p5      =         AMPLITUDE
; p6      =         FM FACTOR
; p7      =         

i1        =         1/p3                     ; ONE CYCLE PER DURATION OF NOTE
i2        =         cpspch(p4)               ; CONVERTS PCHCLASS NOTATION TO Hz
i3        =         i2 * p6                  ; i3 IS THE MODULATING FREQUENCY
i4        =         i3 * p7                  ; i4 IS THE MAXIMUM FREQUENCY DEVIATION

ampenv    oscil     p5,i1,1                  ; AMPLITUDE ENVELOPE FOR THE CARRIER
ampdev    oscil     i4,i1,1                  ; ENVELOPE APPLIED TO FREQUENCY DEVIATION
amod      oscili    ampdev,i3,3              ; MODULATING OSCILLATOR
asig      oscili    ampenv,i2+amod,3         ; CARRIER OSCILLATOR
          out       asig
          endin


</CsInstruments>
<CsScore>
; basicfm.s

; exponentially decaying amplitude envelope for carrier signal
f1      0       512     5       1       512     .001

; amplitude envelope for frequency modulation
f2      0       512     7       1       64      0       448     0

; waveform of carrier signal
f3      0       512     9       1       1       0


;       start   dur     carrier_freq    amp     fm_factor       mod_index
i1      1       5       7.06            25000   1               4
i1      7       5       7.06            .       1.414           4
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
