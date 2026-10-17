#!/usr/bin/env bash
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
frag="$here/contents/lockscreen/shaders/rain.frag"
out="$frag.qsb"
if command -v qsb &>/dev/null; then qsb="$(command -v qsb)"
elif [[ -x /usr/lib/qt6/bin/qsb ]]; then qsb=/usr/lib/qt6/bin/qsb
else echo 'Missing qsb: sudo pacman -S --needed qt6-shadertools' >&2; exit 2; fi
[[ -s "$here/contents/lockscreen/assets/glyph-atlas.png" ]] || { echo 'Missing atlas' >&2; exit 3; }
[[ -s "$here/contents/lockscreen/assets/fallback.png" ]] || { echo 'Missing background fallback' >&2; exit 3; }
tmp="$(mktemp "${TMPDIR:-/tmp}/matrix-lock-shader-XXXXXXXX.qsb")"
trap 'rm -f -- "$tmp"' EXIT
"$qsb" --glsl '100 es,120,150' -o "$tmp" "$frag"
[[ -s "$tmp" ]] || { echo 'Shader compilation produced empty output' >&2; exit 4; }
mv -f -- "$tmp" "$out"
python "$here/tests/check.py" "$here"
echo "Shader built: $out"
