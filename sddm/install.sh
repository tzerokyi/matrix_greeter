#!/usr/bin/env bash
set -euo pipefail
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dest='/usr/share/sddm/themes/matrix-greeter'
if [[ ! -e "$here/Main.qml" || ! -e "$here/metadata.desktop" ]]; then
    printf >&2 'Invalid Matrix Greeter source directory.\n'; exit 1
fi
bash "$here/build.sh"
if [[ -e "$dest" ]]; then
    printf >&2 'Refusing to overwrite an existing theme: %s\n' "$dest"
    printf >&2 'Back up or rename that folder yourself before reinstalling.\n'
    exit 5
fi
printf '\nInstalling to %s (existing active theme remains unchanged)\n' "$dest"
sudo install -d -o root -g root -m 0755 "$dest" "$dest/assets" "$dest/shaders"
sudo install -o root -g root -m 0644 \
    "$here/Main.qml" "$here/RainEngine.qml" "$here/FlatAction.qml" \
    "$here/theme.conf" "$here/metadata.desktop" "$here/LICENSE" \
    "$here/preview.png" "$dest/"
sudo install -o root -g root -m 0644 "$here/assets/glyph-atlas.png" \
    "$here/assets/fallback.png" "$dest/assets/"
sudo install -o root -g root -m 0644 "$here/shaders/rain.frag" \
    "$here/shaders/rain.frag.qsb" "$dest/shaders/"
printf '\nInstall complete — NOT activated. Preview safely with:\n'
printf '  sddm-greeter-qt6 --test-mode --theme %s\n' "$dest"
printf '\nOnce validated, choose Matrix Greeter in Plasma System Settings > Login Screen (SDDM).\n'
