#!/usr/bin/env bash
# Shared PATH for Dr.C Terminal launchers (macOS + Linux).
#   source "$(dirname "$0")/workshop-path.sh"

_workshop_prepend() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" ]] || return 0
  case ":${PATH}:" in
    *":${dir}:"*) ;;
    *) PATH="${dir}:${PATH}" ;;
  esac
}

if [[ "$(uname -s)" == "Darwin" ]]; then
  _workshop_prepend "${HOME}/bin"
  _workshop_prepend "${HOME}/Applications/Csound"
  _workshop_prepend "${HOME}/.local/bin"
  _workshop_prepend "/opt/homebrew/bin"
  _workshop_prepend "/opt/homebrew/opt/bun/bin"
  _workshop_prepend "/usr/local/bin"
  _workshop_prepend "/Applications/Csound/CsoundLib64.framework/Versions/Current/Resources/bin"
  _workshop_prepend "/Library/Frameworks/CsoundLib64.framework/Versions/Current/Resources/bin"
else
  _workshop_prepend "${HOME}/bin"
  _workshop_prepend "${HOME}/.local/bin"
  _workshop_prepend "${HOME}/Applications/Csound"
  _workshop_prepend "${HOME}/.bun/bin"
  _workshop_prepend "/usr/local/bin"
  _workshop_prepend "/usr/bin"
  _workshop_prepend "/opt/csound/bin"
  _workshop_prepend "/snap/bin"
fi

export PATH
