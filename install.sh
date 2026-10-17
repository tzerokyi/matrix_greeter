#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Run as your ordinary Plasma user, not root.' >&2; exit 2; }
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:---all}"

if [[ "$mode" == --all || "$mode" == --sddm ]]; then
  sddm_dest=/usr/share/sddm/themes/matrix-greeter
  [[ ! -e "$sddm_dest" && ! -L "$sddm_dest" ]] || {
    echo "Already installed: $sddm_dest. Review and back up the existing theme before replacing it." >&2
    exit 3
  }
fi
if [[ "$mode" == --all || "$mode" == --lock ]]; then
  lock_dest="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells/org.tzerokyi.matrix.lock"
  [[ ! -e "$lock_dest" && ! -L "$lock_dest" ]] || {
    echo "Already installed: $lock_dest. Review and back up the existing package before replacing it." >&2
    exit 3
  }
fi

case "$mode" in
  --help|-h)
    echo 'Usage: bash install.sh [--all|--sddm|--lock]'
    exit 0
    ;;
  --all)
    [[ $# -eq 0 || $# -eq 1 ]] || { echo 'Usage: bash install.sh [--all|--sddm|--lock]' >&2; exit 2; }
    bash "$here/sddm/install.sh"
    bash "$here/plasma-lock/install.sh"
    ;;
  --sddm)
    [[ $# -eq 1 ]] || { echo 'Usage: bash install.sh [--all|--sddm|--lock]' >&2; exit 2; }
    bash "$here/sddm/install.sh"
    ;;
  --lock)
    [[ $# -eq 1 ]] || { echo 'Usage: bash install.sh [--all|--sddm|--lock]' >&2; exit 2; }
    bash "$here/plasma-lock/install.sh"
    ;;
  *)
    echo 'Usage: bash install.sh [--all|--sddm|--lock]' >&2
    exit 2
    ;;
esac

printf '\nBoth themes remain inactive until you select them after testing.\n'
printf 'SDDM preview: sddm-greeter-qt6 --test-mode --theme %s/sddm\n' "$here"
printf 'Lock preview: bash %s/plasma-lock/test.sh\n' "$here"
printf 'See README.md for activation and recovery.\n'
