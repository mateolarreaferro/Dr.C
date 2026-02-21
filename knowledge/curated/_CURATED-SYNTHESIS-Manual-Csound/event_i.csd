<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

seed 0
gisine ftgen 0, 0, 2^10, 10, 1

instr 1 ;master instrument

ininstr = 10 ;number of called instances
indx = 0
loop:
ipan  random 0, 1
ifreq random 100, 1000
iamp  = 1/ininstr
event_i "i", 10, 0, p3, iamp, ifreq, ipan
loop_lt indx, 1, ininstr, loop

endin

instr 10

      print p4, p5, p6
ipeak random 0, 1 ;where is the envelope peak
asig  poscil3 p4, p5, gisine
aenv  transeg 0, p3*ipeak, 6, 1, p3-p3*ipeak, -6, 0
aL,aR pan2 asig*aenv, p6
      outs aL, aR

endin

</CsInstruments>
<CsScore>
i1 0 10
i1 8 10
i1 16 15
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
