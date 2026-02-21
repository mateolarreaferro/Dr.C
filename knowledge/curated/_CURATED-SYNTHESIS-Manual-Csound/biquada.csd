<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

; Initialize the global variables.

; Instrument #1.
instr 1
  ; Get the values from the score.
  idur = p3
  iamp = p4
  icps = cpspch(p5)
  afco   expon  100, p3, 2000
  arez   line  0.8, p3, 0.99

  ; Calculate the biquadratic filter's coefficients 
  afcon = 2*3.14159265*afco/sr
  aalpha = 1-2*arez*cos(afcon)*cos(afcon)+arez*arez*cos(2*afcon)
  abeta = arez*arez*sin(2*afcon)-2*arez*cos(afcon)*sin(afcon)
  agama = 1+cos(afcon)
  am1 = aalpha*agama+abeta*sin(afcon)
  am2 = aalpha*agama-abeta*sin(afcon)
  aden = sqrt(am1*am1+am2*am2)
  ab0 = 1.5*(aalpha*aalpha+abeta*abeta)/aden
  ab1 = ab0
  ab2 = 0
  aa0 = 1
  aa1 = -2*arez*cos(afcon)
  aa2 = arez*arez
  
  ; Generate an input signal.
  axn vco 1, icps, 1

  ; Filter the input signal.
  ayn biquada axn, ab0, ab1, ab2, aa0, aa1, aa2
  outs ayn*iamp/2, ayn*iamp/2
endin


</CsInstruments>
<CsScore>

; Table #1, a sine wave.
f 1 0 16384 10 1

;    Sta  Dur  Amp    Pitch
i 1  0.0  5.0  20000  6.00 
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
