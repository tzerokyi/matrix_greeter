#!/usr/bin/env bash
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
shader="$here/shaders/rain.frag"
output="$here/shaders/rain.frag.qsb"
qsb=''
for candidate in /usr/lib/qt6/bin/qsb /usr/bin/qsb; do
    if [[ -x "$candidate" ]]; then qsb="$candidate"; break; fi
done
if [[ -z "$qsb" ]]; then
    printf >&2 'Qt 6 shader baker not found. On Arch Linux run: sudo pacman -S --needed qt6-shadertools\n'
    exit 2
fi
if [[ ! -s "$here/assets/glyph-atlas.png" || ! -s "$here/assets/fallback.png" ]]; then
    printf >&2 'Asset validation failed: missing atlas or fallback PNG.\n'
    exit 3
fi
printf 'Compiling shader with: %s\n' "$qsb"
tmp="$(mktemp "${TMPDIR:-/tmp}/matrix-rain-XXXXXXXX.qsb")"
trap 'rm -f -- "$tmp"' EXIT
"$qsb" --glsl '100 es,120,150' -o "$tmp" "$shader"
if [[ ! -s "$tmp" ]]; then
    printf >&2 'qsb reported success but produced an empty shader.\n'
    exit 4
fi
mv -f -- "$tmp" "$output"
printf 'OK: %s (%s bytes)\n' "$output" "$(stat -c %s "$output")"
