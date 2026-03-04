# csound-ai-reference

A reference project to help AI coding tools generate correct, idiomatic **Csound 7** code.

## The Problem

AI tools frequently generate incorrect Csound because:
- Csound training data is sparse compared to mainstream languages
- Opcode signatures vary and are easily confused
- Variable rate prefixes (`i`, `k`, `a`, `S`, `f`) have strict semantics
- UDO syntax changed significantly in Csound 7
- Common patterns (signal routing, effects chains, MIDI handling) aren't well-represented

## How to Use This Repo

### Quick setup (single file)

**Claude Code:** Copy `CLAUDE.md` into the root of your Csound project. Claude Code reads this automatically.

**Cursor / Copilot / other tools:** Use `llms.txt` or paste the contents of `CLAUDE.md` into your tool's "rules" or "custom instructions" file.

Both files are **self-contained** — they include all syntax rules, common opcode signatures, and links to the Csound manual. No other files are needed.

### Full setup (skill package)

For deeper AI assistance, install the `skill/` folder as a Claude skill or include it as additional context. It contains detailed reference docs, common patterns, anti-patterns, and compile-verified `.csd` examples.

### Standalone reference
Browse `skill/reference/` for syntax rules, opcode quick-reference, patterns, and anti-patterns.

## Repo Structure

```
csound-ai-reference/
├── CLAUDE.md              # Self-contained — drop into any project
├── llms.txt               # Self-contained — generic LLM reference
├── README.md
├── skill/                 # Full skill package (reference + examples)
│   ├── SKILL.md           # Skill definition for agentic tools
│   ├── reference/
│   │   ├── syntax-rules.md    # Variable rates, UDO syntax, core semantics
│   │   ├── opcodes.md         # Manual URL directory + common opcode signatures
│   │   ├── patterns.md        # Common idioms and design patterns
│   │   └── antipatterns.md    # What AI tools typically get wrong
│   └── examples/
│       ├── synthesis/         # Working .csd synthesis examples
│       ├── effects/           # Working .csd effects examples
│       └── realtime/          # Real-time / MIDI examples
└── dev/                   # Internal: eval prompts, test results
```

## Csound Version

All examples and guidance target **Csound 7** with:
- New-style UDO syntax with named arguments: `opcode Name(args):returnType`
- Functional opcode calling syntax: `asig = vco2(0.5, 440)`
- `outs` deprecated — use `out(aL, aR)` for stereo output
- `pch` / `cpspch` patterns replaced with direct Hz or MIDI-to-Hz conversion

## Contributing

Contributions welcome! Priority areas:
1. Additional working `.csd` examples in `skill/examples/`
2. Expanded opcode reference in `skill/reference/opcodes.md`
3. Eval prompts that expose AI failure modes
4. Corrections to any generated code

## License

MIT
