<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
0dbfs = 1

instr 1 ;without arrays
; generate pink noise
anoise pinkish 1
        
; two full turns
kalpha line 0, p3, 720
kbeta = 0
        
; generate B format
aw, ax, ay, az, ar, as, at, au, av bformenc1 anoise, kalpha, kbeta
        
; decode B format for 8 channel circle loudspeaker setup
a1, a2, a3, a4, a5, a6, a7, a8 bformdec1 4, aw, ax, ay, az, ar, as, at, au, av        

; write audio out
outo a1, a2, a3, a4, a5, a6, a7, a8
endin

instr 2 ;with arrays (csound6)
;set file names for:
S_bform = "bform_out.wav" ;b-format (2nd order) output
S_sound = "sound_out.wav" ;sound output

; generate pink noise
anoise pinkish 1
        
; two full turns
kalpha line 0, p3, 720
kbeta = 0
        
;create array for B-format 2nd order (9 chnls)
aBform[] init 9

; generate B-format
aBform bformenc1 anoise, kalpha, kbeta

;write out b-format
fout "fout.wav", 18, aBform

;create array for audio output (8 channels)
aAudio[] init 8
        
;decode B format for 8 channel circle loudspeaker setup
aAudio bformdec1 4, aBform

; write audio out
fout S_sound, 18, aAudio
endin


</CsInstruments>
<CsScore>
i 1 0 8
i 2 8 8
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
