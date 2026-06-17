#!/usr/bin/env bash
# LAC 2026 — Dr.C Terminal (Csound 7 workshop build)
set -euo pipefail

export PATH="${HOME}/bin:${HOME}/Applications/Csound:${HOME}/.bun/bin:/opt/homebrew/opt/node@22/bin:/opt/homebrew/bin:/usr/local/bin:${PATH:-}"

WORK_DIR="${DRC_WORK_DIR:-${HOME}/Dr.C-Workshop-Demo}"
DRC_ROOT="${DRC_TERMINAL_ROOT:-${HOME}/Dr.C/opencode}"

mkdir -p "$WORK_DIR"

die() {
  echo "$@"
  echo ""
  read -r -p "Press Enter to close..." || true
  exit 1
}

[[ -d "$DRC_ROOT" ]] || die "Dr.C Terminal not found at $DRC_ROOT

Install:
  git clone https://github.com/mateolarreaferro/Dr.C.git ~/Dr.C
  cd ~/Dr.C/opencode && bun install"

command -v bun >/dev/null 2>&1 || die "Bun not installed — https://bun.sh"
command -v csound >/dev/null 2>&1 || die "Csound not on PATH — install Csound 7 to ~/Applications/Csound"

echo "Dr.C Terminal — LAC 2026 workshop"
echo "Project: $WORK_DIR"
echo "Repo:    $DRC_ROOT"
echo "Csound:  $(csound --version 2>&1 | head -1)"
echo ""
echo "First time? Run: cd ~/Dr.C/opencode && bun run dev -- auth login"
echo ""

cd "$DRC_ROOT"
exec bun run dev -- "$WORK_DIR"
