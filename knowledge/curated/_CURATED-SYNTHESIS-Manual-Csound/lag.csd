<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs = 1.0

instr 1
  ; smooth a krate signal  
  kx = floor(line(0, p3, 10))
  kx2 = lag(kx, 0.1)
  printk2 kx2
endin

instr 2
  ; smooth an audio signal
  kmidi = floor(line(60, p3, 72)/2)*2
  afreq = upsamp(mtof(kmidi))
  afreqsmooth = lag(afreq, 1)
  a1 = oscili(1, afreq)
  a2 = oscili(1, afreqsmooth)
  outch 1, a1
  outch 2, a2 
endin

</CsInstruments>
<CsScore>
i 1 0 5
i 2 0 10

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
