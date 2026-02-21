<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  = 1

instr 1

kleft init 1
asig  vco2 .5, 220			;sawtooth
idur = p3/(nchnls-1)
knext init idur
kpos init 0
krate init 1/idur
kbase init 0
ktime timeinsts
if ktime>=knext then
  kleft = kleft + 1
  knext = knext + idur
  kpos = 0
  kbase = ktime
else
  kpos = (ktime-kbase)/idur
endif
;printks "speaker %d position %f\n", 0, kleft, kpos
a1,a2 pan2 asig, kpos
      outrg  kleft, a1, a2
kpos = kbase/idur
endin

</CsInstruments>
<CsScore>

i 1 0 10
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
