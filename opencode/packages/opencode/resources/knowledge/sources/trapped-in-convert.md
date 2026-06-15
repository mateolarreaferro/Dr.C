# Trapped in Convert (1979) — Richard Boulanger

Landmark computer music work composed at the M.I.T. Experimental Music Studio (music11, 1979), revised for Csound (1986) and SHARCsound (1996). The orchestra is organized as **thirteen color-named timbres** plus global **SMEAR** (delay) and **SWIRL** (reverb/pan) processors.

Workshop copies live in `resources/workshop-starters/trapped_*` and `resources/knowledge/trapped-in-convert/`.

## Global buses

| Global | Used by | Role |
|--------|---------|------|
| `garvb` | BLUE, VIOLET, BLACK, GREEN, COPPER, PEWTER, RED, SAND, TAUPE, RUST, TEAL | Reverb send accumulator |
| `gadel` | SAND, RUST, SMEAR (98) | Delay send accumulator |

| Instr | Name | Signature opcodes | Character |
|-------|------|-------------------|-----------|
| 1 | **IVORY** | layered `oscil`, `expseg` gliss, vibrato LFO | six detuned partials, stereo pairs |
| 2 | **BLUE** | `gbuzz`, `randi`, harmonic sweep | bright buzz, reverb send |
| 3 | **VIOLET** | `randh`, `buzz`, `oscil` layers | noisy FM clusters |
| 4 | **BLACK** | `reson` + `rand` noise, `oscil` tone | filtered noise + pitch |
| 5 | **GREEN** | `foscili`, `randh`, `linseg` pan | classic 2-op FM + pan motion |
| 6 | **COPPER** | `phasor` table sweep + `reson` noise | animated filterbank |
| 7 | **PEWTER** | `oscil` + `oscili` phase modulation | wavetable morph |
| 8 | **RED** | dual `reson` noise, `balance`, stereo `randh` | wide noisy spectrum |
| 9 | **SAND** | four detuned `oscil`, delay + reverb | grainy chorus |
| 10 | **TAUPE** | same as SAND without delay | dry variant |
| 11 | **RUST** | four `oscil` + heavy `randh` | dense animated texture |
| 12 | **TEAL** | `reson` noise + `oscil` pitched layer | sweep + tone |
| 13 | **FOAM** | six `oscil` partials, `octpch` | octave-based shimmer |
| 98 | **SMEAR** | `delay` on `gadel` | short feedback smear |
| 99 | **SWIRL** | `reverb` on `garvb`, pan LFO | global space |

## Score conventions

- Pitch often via `cpspch(p5)` or `octpch(p5)` — workshop starters use MIDI `p4` for Agent compatibility.
- Many instruments use **10+ p-fields** — document parameter meaning in comments.
- Piece runs ~283 s in four sections with variable tempo (`t` statement) in Section IV.

## When to cite this model

- User asks for **gbuzz**, **buzz**, **layered oscil**, **color timbres**, **MIT EMS style**, **Trapped in Convert**
- Noisy / resonant / swept-filter textures (BLACK, COPPER, RED, TEAL)
- Global `garvb` + instr 99 **SWIRL** pattern for spatialization

## Anti-patterns when adapting

- Do not strip `instr 99` if any voice uses `garvb` — start `i 99` for the section duration.
- `expseg` / `expsegr` with `p3` math is score-timed — for Player keyboard use `linsegr` with `i -1.NNN` release.
- Table numbers (f1, f9–f22) are required — copy ftgens from the reference score block.
