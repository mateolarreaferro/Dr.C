<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

0dbfs  =    1

gaArr[]  init  2

instr 1
kEnv transeg    1, p3, -3, 0

a_pi = 4 * taninv(1.0);
a1   phasor 440;
a2   = sin(2 * a_pi * 1/ksmps * a1);
a3   dcblock2 a2
asig = signum(a3)

gaArr[0] = a2   * 0.6 * kEnv 
gaArr[1] = asig * 0.6 * kEnv 

outs  gaArr[0], gaArr[1]
endin

</CsInstruments>
<CsScore>
i 1 0 3

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
