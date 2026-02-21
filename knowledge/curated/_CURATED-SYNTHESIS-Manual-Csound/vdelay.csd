<CsoundSynthesizer>
<CsInstruments>

0dbfs  = 1

instr 1 

ims  = 100				;maximum delay time in msec
aout poscil .8, 220, 1			;make a signal
a2   poscil3 ims/2, 1/p3, 1		;make an LFO
a2   = a2 + ims/2 			;offset the LFO so that it is positive
asig vdelay aout, a2, ims		;use the LFO to control delay time
     outs  asig, asig

endin
</CsInstruments>
<CsScore>
f1 0 8192 10 1 ;sine wave

i 1 0 5 

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
