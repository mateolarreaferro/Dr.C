<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>


0dbfs = 1

instr 1			;sawtooth waveform.

kfco  line 200, p3, 2000;filter-cutoff frequency from .2 to 5 KHz.
kres  = p4		;resonance
imode = p5		;mode
asig	vco 0.2, 220, 1
afilt	bqrez asig, kfco, kres, imode
asig	balance afilt, asig
	outs asig, asig

endin

</CsInstruments>
<CsScore>
;sine wave
f 1 0 16384 10 1

i 1 0 3 1 0		; low pass
i 1 + 3 30 0		; low pass
i 1 + 3 1 1		; high pass
i 1 + 3 30 1		; high pass

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
