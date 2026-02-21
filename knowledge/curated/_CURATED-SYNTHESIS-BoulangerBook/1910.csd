<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
          instr     1910
kampenv   linseg    0, .01, p4, p3-.02, p4, .01, 0
; PLANET POSITION (X, Y, Z) & VELOCITY (VX, VY, VZ)
kx        init      0
ky        init      .1
kz        init      0
kvx       init      .5
kvy       init      .6
kvz       init      -.1
ih        init      p5
ipanl     init      p9
ipanr     init      1-ipanl
; STAR 1 MASS & X, Y, Z
imass1    init      p6
is1x      init      0
is1y      init      0
is1z      init      p8
; STAR 2 MASS & X, Y, Z
imass2    init      p7
is2x      init      0
is2y      init      0
is2z      init      -p8
; CALCULATE DISTANCE TO STAR 1
kdx       =         is1x-kx
kdy       =         is1y-ky
kdz       =         is1z-kz
ksqradius =         kdx*kdx+kdy*kdy+kdz*kdz+1
kradius   =         sqrt(ksqradius)
; DETERMINE ACCELERATION DUE TO STAR 1 (AX, AY, AZ)
kax       =         imass1/ksqradius*kdx/kradius
kay       =         imass1/ksqradius*kdy/kradius
kaz       =         imass1/ksqradius*kdz/kradius
; CALCULATE DISTANCE TO STAR 2
kdx       =         is2x-kx
kdy       =         is2y-ky
kdz       =         is2z-kz
ksqradius =         kdx*kdx+kdy*kdy+kdz*kdz+1
kradius   =         sqrt(ksqradius)
; DETERMINE ACCELERATION DUE TO STAR 2 (AX, AY, AZ)
kax       =         kax+imass2/ksqradius*kdx/kradius
kay       =         kay+imass2/ksqradius*kdy/kradius
kaz       =         kaz+imass2/ksqradius*kdz/kradius
; UPDATE THE VELOCITY
kvx       =         kvx+ih*kax
kvy       =         kvy+ih*kay
kvz       =         kvz+ih*kaz
; UPDATE THE POSITION
kx        =         kx+ih*kvx
ky        =         ky+ih*kvy
kz        =         kz+ih*kvz
aoutx     =         kx*kampenv*ipanl
aouty     =         ky*kampenv*ipanr
          outs      aoutx,aouty
          endin

</CsInstruments>
<CsScore>
f1 0 8192 10 1

t 0 400

; PLANETARY ORBIT IN A BINARY STAR SYSTEM
;      START  DUR  AMP      H  MASS1 MASS2 SEPARATION  PAN
i 1910  0		16	3000    .2   .5    .6      2        .7
i 1910  12		48	5500    .15  .4    .34     1.1      .5
i 1910  36		4	5000    .3   .5    .5      1        .2
i 1910  +		.	5500    .3   .5    .48     1.2      <
i 1910  .		.	6000    .3   .5    .46     1.4      <
i 1910  .		.	6500    .3   .5    .44     1.6      <
i 1910  .		8	6000    .3   .5    .42     1.8      .8
s
;
i 1910  0	8	6000	.04		.5  .6   2  .5
i 1910  +	.	6000	<		.5  .6   2  .5
i 1910  .	.	7000	<		.5  .6   2  .5
i 1910  .	.	7000	.16		.5  .6   2  .5


</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>180</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>0</r>
  <g>0</g>
  <b>0</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
