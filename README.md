# Dr.C
Human-in-the-Loop Generative Agent for Sound Design and Composition in Csound

## Prerequisites

- [Bun](https://bun.sh) (JavaScript runtime)
- [Csound 7+](https://csound.com) (recommended for full functionality)
- Git

## Installation

```bash
# Clone the repo
git clone https://github.com/mateolarreaferro/Dr.C.git
cd Dr.C

# Install dependencies and build
cd opencode/packages/opencode
bun install
bun run build

# Install globally (adds `drc` to your PATH)
bun install -g .
```

## Usage

```bash
# Start Dr.C
drc

# Or run in development mode (no global install needed)
cd opencode/packages/opencode
bun run dev
```

## Updating

```bash
cd Dr.C
git pull
cd opencode/packages/opencode
bun install
bun run build
bun install -g .
```
