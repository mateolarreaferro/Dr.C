<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; Initialize the global variables.

; Define the oscillator macro.
#define OSCMACRO(VOLUME'FREQ'TABLE) #oscil $VOLUME, $FREQ, $TABLE#

; Instrument #1
instr 1
  ; Use the oscillator macro.
  ; This will be expanded to "a1 oscil 5000, 440, 1".
  a1 $OSCMACRO(5000'440'1)

  ; Send it to the output.
  out a1
endin


</CsInstruments>
<CsScore>

; Define Table #1 with an ordinary sine wave.
f 1 0 32768 10 1 
         
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
