# dev/

Internal tools for developing and testing the csound-ai-reference deliverables (`CLAUDE.md`, `llms.txt`, `skill/`).

## Contents

- **prompts.md** — Eval prompts for benchmarking AI tools on Csound 7 code generation. Each prompt includes expected output criteria, common failure modes, and a scoring rubric.
- **evals/** — Directory for storing test results and comparison data.

## Usage

Run each prompt in `prompts.md` against your AI tool **without** the reference files, then **with** them, to measure improvement. Score using the rubric at the bottom of the file.
