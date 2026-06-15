#!/usr/bin/env bash
# Launch Dr.C Terminal TUI with Csound 7 on PATH (macOS + Linux).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=workshop-path.sh
source "${SCRIPT_DIR}/workshop-path.sh"

ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$ROOT"

WORK_DIR="${1:-${HOME}/lac-workshop-demo}"
mkdir -p "$WORK_DIR"

if ! command -v csound >/dev/null 2>&1; then
  echo "Csound not found. Install Csound 7 — see GET-STARTED.md"
  exit 1
fi

if ! command -v bun >/dev/null 2>&1; then
  echo "Bun not found. Install from https://bun.sh — see GET-STARTED.md"
  exit 1
fi

echo "Dr.C Terminal (Csound 7) — OS: $(uname -s)"
echo "Csound: $(csound --version 2>&1 | head -1)"
echo "Bun: $(bun --version)"
echo "Work folder: $WORK_DIR"
echo ""

if [[ ! -d node_modules ]]; then
  echo "First run: bun install"
  bun install
fi

exec bun run dev -- "$WORK_DIR"
