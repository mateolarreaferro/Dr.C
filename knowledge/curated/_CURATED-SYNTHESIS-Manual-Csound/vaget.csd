<CsoundSynthesizer>
<CsInstruments>

	instr 1	; Sqrt Signal
ifreq = (p4 > 15 ? p4 : cpspch(p4))
iamp = ampdb(p5)

aout init 0
ksampnum init 0

kenv	linseg 0, p3 * .5, 1, p3 * .5, 0

aout1	vco2	1, ifreq
aout2	vco2	.5, ifreq * 2
aout3	vco2	.2, ifreq * 4

aout	sum 	aout1, aout2, aout3

;Take Sqrt of signal, checking for negatives
kcount = 0

loopStart:

	kval vaget kcount,aout

	if (kval > .0) then
		kval = sqrt(kval)
	elseif (kval < 0) then
		kval = sqrt(-kval) * -1
	else
		kval = 0
	endif

	vaset kval, kcount,aout

loop_lt kcount, 1, ksmps, loopStart

aout = aout * kenv

aout	moogladder aout, 8000, .1

aout = aout * iamp

outs aout, aout
	endin

</CsInstruments>

<CsScore>

i1	0.0	2 440 80
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
