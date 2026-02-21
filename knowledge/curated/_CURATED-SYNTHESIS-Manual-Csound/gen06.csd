<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs  = 1

instr 1

ifn  = p4				;choose between tables
kcps init 1/p3				;create index over duration of note.
kndx phasor kcps
ixmode = 1
kval table kndx, ifn, ixmode		;normalize mode

kfreq = kval * 30			;scale frequency to emphasixe effect
asig  poscil .7, 220 + kfreq, 1		;add to frequency
      outs asig, asig
  
endin
</CsInstruments>
<CsScore>
f 1 0 16384 10 1 ;sine wave.
f 2 0 513 6 1 128 -1 128 1 64 -.5 64 .5 16 -.5 8 1 16 -.5 8 1 16 -.5 84 1 16 -.5 8 .1 16 -.1 17 0
f 3 0 513 6 0 128 0.5 128 1 128 0 129 -1

i 1 0 3 2
i 1 4 3 3
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
