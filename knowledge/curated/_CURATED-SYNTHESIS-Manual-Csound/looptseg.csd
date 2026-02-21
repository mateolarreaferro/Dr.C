<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1
kfreq   =        1         ; frequency of loop repetition
ktrig   init     0         ; loop restart trigger (not used)
iphase  =        0         ; initial phase
ktyp    line     6,p3,-6   ; explore the useful range of curve types
; loop of filter cutoff values (oct format)
;                                     value curve dur.
kcfoct looptseg  kfreq, ktrig, iphase,13,   ktyp, 1, \
                                      4,    ktyp, 0, \
                                      11,   ktyp, 1, \
                                      4
asig  vco2     0.2,cpsmidinn(48),0             ; a sawtooth
asig  moogladder  asig,cpsoct(kcfoct),rnd(0.6) ; filter sawtooth
      outs     asig, asig
endin

</CsInstruments>
<CsScore>
i 1 0 12
e
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
