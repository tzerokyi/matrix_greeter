#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Run as your ordinary KDE user, not sudo.' >&2; exit 2; }
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$here/build.sh"
id=org.tzerokyi.matrix.lock
base="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells"
dest="$base/$id"
mkdir -p "$base"
[[ ! -e "$dest" && ! -L "$dest" ]] || { echo "Already installed: $dest; restore first, then remove the old package." >&2; exit 3; }
tmp="$(mktemp -d "$base/.matrix-install-XXXXXXXX")"
trap 'rm -rf -- "$tmp"' EXIT
cp -a "$here/metadata.json" "$here/contents" "$tmp/"
find "$tmp" -type d -exec chmod 755 {} +
find "$tmp" -type f -exec chmod 644 {} +
mv -- "$tmp" "$dest"
trap - EXIT
printf '\nStaged at: %s\nNo lock-screen config was changed.\nTest first: bash test.sh\nActivate only after testing: bash activate.sh\n' "$dest"
