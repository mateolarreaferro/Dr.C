<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

          instr     1908
ax        init      p5                   ; LORENZ ATTRACTOR
ay        init      p6
az        init      p7
as        init      p8
ar        init      p9
ab        init      p10
ah        init      p11
ipanl     init      p12
ipanr     init      1-ipanl

kampenv   linseg    0, .01, p4, p3-.02, p4, .01, 0
axnew     =         ax+ah*as*(ay-ax)
aynew     =         ay+ah*(-ax*az+ar*ax-ay)
aznew     =         az+ah*(ax*ay-ab*az)
ax        =         axnew
ay        =         aynew
az        =         aznew
          outs      ax*kampenv*ipanl,ay*kampenv*ipanr
          endin


</CsInstruments>
<CsScore>
f1 0 8192 10 1

t 0 400

i 1908  0    1   500   .6  .6  .6  30   21  2.52  .002   0
i 1908  +    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   1200  .6  .6  .6  30   21  2.30  .012   1
;
i 1908  14   1   800   .6  .6  .6  30   21  2.00  .012   1
i 1908  +    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .   <     .6  .6  .6  30   21  <     <      <
i 1908  .    .  2000   .6  .6  .6  30   21  2.30  .002   0
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>396</width>
 <height>240</height>
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
