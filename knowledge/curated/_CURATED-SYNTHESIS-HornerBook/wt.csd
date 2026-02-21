<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
; wt.orc (in the design subdirectory on the CD-ROM)

instr 13

iamp    =       p4                                                 ; p4 controls the amplitude
ifreq   =       p5                                                 ; input pitch in Hertz
iwt1    =       6                                                  ; set wavetable numbers
iwt2    =       7
iwt3    =       8
iwt4    =       9

amp1    linseg  0, .001, 0, .03, 1, p3 - .061, .9, .03, 0, 1, 0    ; amplitude envelopes
amp2    =       amp1 * amp1
amp3    =       amp2 * amp1
amp4    =       amp3 * amp1

awt1    oscili  amp1, ifreq, iwt1                                  ; signal 1
awt2    oscili  amp2, ifreq, iwt2                                  ; signal 2
awt3    oscili  amp3, ifreq, iwt3                                  ; signal 3
awt4    oscili  amp4, ifreq, iwt4                                  ; signal 4

asig    =       (awt1 + awt2 + awt3 + awt4) * iamp                 ; combine signal
        out     asig                                               ; output signal
        endin

</CsInstruments>
<CsScore>
; wt.sco - use with wt.orc (in the design subdirectory on the CD-ROM)
			
f6 0 8193 -9 1  1 0
f7 0 8193 -9 2 .9 0  3 .8 0
f8 0 8193 -9 4 .7 0  5 .6 0   6 .5 0  7 .4 0
f9 0 8193 -9 8 .3 0  9 .2 0  10 .1 0

;p1     p2      p3     p4      p5
;inst   start   dur    amp     Hertz
i13     1       4      4000    392                                  ; G4 - G above middle C
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
