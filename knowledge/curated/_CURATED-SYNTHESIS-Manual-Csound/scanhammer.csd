<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

; by Menno Knevel 2021

instr 1	

initial ftgen 1, 0, p5, 10, 1                         ; initial position = sine wave
imass   ftgen 2, 0, p5, -7, .1, p5, 1                 ; masses
istiff  ftgen 3, 0, p5, -7, 0, p5*.3, 0.8*p5, p5*.7, 0   ; stiffness
idamp   ftgen 4, 0, p5, -7, 1, p5, 1                  ; damping
ivelo   ftgen 5, 0, p5, -7, 0, p5, 0.5                ; initial velocity

iamp = .20
ipch  = cpsmidinn(p4) 
scanhammer 1, 1, 0, p6                                ; scale initial position wave 
asig3 scantable iamp, ipch, 1, 2, 3, 4, 5             ; set ftables in motion
asig  foscili iamp, ipch, 1.414, .03, 1, 1            ; but use FM sound, with slow vibrato
asig  butlp  asig, 2000                               ; lowpass filter
asig dcblock asig
outs asig, asig

endin

</CsInstruments>
<CsScore>
s   ;                  note    size    hit
i1	0	10	50      128     2   ; hit very hard
i1	11	10	50      .       1   ; hit normally
i1	22	10	50      .       .3  ; hit soft
s
i1	1	10	50      32      2   ; different table size 
i1	12	10	50      .       1
i1	23	20	50      .       .3
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
