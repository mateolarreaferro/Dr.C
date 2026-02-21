<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs = 1

instr 1
; Generate a band-limited pulse train.
asrc buzz 0.9, 440, sr/440, 1

; Send the source signal through 2 filters.
a1 reson asrc, 1000, 100       
a2 reson a1, 3000, 500

; Balance the filtered signal with the source.
afin balance2 a2, asrc
     outs afin, afin

endin

</CsInstruments>
<CsScore>
;sine wave.
f 1 0 16384 10 1

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
