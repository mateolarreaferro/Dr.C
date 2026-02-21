<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; Generate a sinewave table.
giwave ftgen 1, 0, 1024, 10, 1 

; Instrument #1
instr 1
  ; Generate 10 voices.
  icnt = 10 
  ; Empty the output buffer.
  asum = 0 
  ; Reset the loop index.
  kindex = 0 

; This loop is executed every k-cycle.
loop: 
  ; Generate non-harmonic partials.
  kcps = (kindex+1)*100+30 
  ; Get the phase for each voice.
  aphas phasorbnk kcps, kindex, icnt 
  ; Read the wave from the table.
  asig table aphas, giwave, 1 
  ; Accumulate the audio output.
  asum = asum + asig 

  ; Increment the index.
  kindex = kindex + 1

  ; Perform the loop until the index (kindex) reaches 
  ; the counter value (icnt).
  if (kindex < icnt) kgoto loop 

  out asum*3000
endin


</CsInstruments>
<CsScore>

; Play Instrument #1 for two seconds.
i 1 0 2
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
