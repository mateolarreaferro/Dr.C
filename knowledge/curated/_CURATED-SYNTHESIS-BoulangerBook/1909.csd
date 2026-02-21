<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>
sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         2

          instr     1909 
ax        init      0                    ; ROSSLER'S ATTRACTOR
ay        init      0
az        init      0
ih        init      p5
aa        init      .375
ib        init      p6
ic        init      p7
ipanl     init      p8
ipanr     init      1-ipanl
; AMPLITUDE ENVELOPE
kampenv   linseg    0,.01,p4,p3-.02,p4,.01,0
aa        oscil     1/7,.5,1
aa        =         .3+aa
axnew     =         ax+ih*(-ay-az)
aynew     =         ay+ih*(ax+aa*ay)
aznew     =         az+ih*(ib+ax*az-ic*az)
ax        =         axnew
ay        =         aynew
az        =         aznew
          outs      kampenv*ax*ipanl,kampenv*ay*ipanr
          endin

</CsInstruments>
<CsScore>
f1 0 8192 10 1

t 0 400

; Rossler Attractor
;      Start  Dur  Amp   Freq  B  C  Pan
i 1909  0     1   2000   .04   4  4  1
i 1909  +     1   <      .06   4  4  <
i 1909  .     1   <      .08   4  4  <
i 1909  .     1   <      .10   4  4  <
i 1909  .     1   <      .12   4  4  <
i 1909  .     1   <      .14   4  4  <
i 1909  .     1   <      .16   4  4  <
i 1909  .     1   5500   .18   4  4  0
;
i 1909  .     1   2000   .14   4  4  1
i 1909  .     1   2500   .16   4  4  <
i 1909  .     1   3000   .18   4  4  <
i 1909  .     1   3500   .20   4  4  <
i 1909  .     1   4000   .22   4  4  <
i 1909  .     1   4500   .24   4  4  <
i 1909  .     1   5000   .26   4  4  <
i 1909  .     1   5500   .28   4  4  0
;
i 1909  .     1   3000   .26   4.0  4    .8
i 1909  .     1   2800   .30   4.0  4    .1
i 1909  .     1   2600   .26   3.8  4    .9
i 1909  .     1   2400   .32   4.0  4    .6
i 1909  .     1   2200   .26   3.6  4    .2
i 1909  .     1   2000   .30   4.0  3.8  .8
i 1909  .     1   1800   .26   3.4  4    .3
i 1909  .     1   1600   .32   4.0  4    .4
i 1909  .     1   1400   .26   3.2  4    .9
i 1909  .     1   1200   .30   4.0  4    .1
;
i 1909  .     1   3400   .26   3.8  4     1
i 1909  .     1   3200   .20   3.7  4     <
i 1909  .     1   3000   .26   3.6  4     <
i 1909  .     1   2800   .20   3.5  4     <
i 1909  .     1   2600   .26   3.4  4     0
i 1909  .     1   2400   .20   3.2  3.8   <
i 1909  .     1   2000   .26   3.1  3.6   <
i 1909  .     1   1600   .20   3.0  4     <
i 1909  .     1   1200   .26   2.9  4     1
i 1909  .     1   800    .20   3.0  3.9   <
i 1909  .     1   600    .20   3.0  3.8   <
i 1909  .     1   400    .20   3.0  3.7   <
i 1909  .     1   200    .20   3.0  3.6   <
i 1909  .     1   100    .20   3.0  3.5   .5
</CsScore>
</CsoundSynthesizer>


<MacGUI>
ioView nobackground {0, 0, 0}
</MacGUI>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>30</y>
 <width>0</width>
 <height>0</height>
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
