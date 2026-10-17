#!/usr/bin/env bash
set -euo pipefail
id=org.tzerokyi.matrix.lock
base="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells"
[[ -s "$base/$id/contents/lockscreen/shaders/rain.frag.qsb" ]] || { echo 'Run bash install.sh first.' >&2; exit 2; }
greeter=''
for path in /usr/lib/kscreenlocker_greet /usr/libexec/kscreenlocker_greet /usr/lib64/libexec/kscreenlocker_greet; do
    if [[ -x "$path" ]]; then greeter="$path"; break; fi
done
if [[ -z "$greeter" ]]; then
    greeter="$(command -v kscreenlocker_greet || true)"
fi
[[ -n "$greeter" ]] || { echo 'kscreenlocker_greet not found; install kscreenlocker.' >&2; exit 3; }
echo 'Opening KDE lockscreen testing window (NOT a real lock). Check the Matrix UI, password field, F12, and KDE default UI.'
exec "$greeter" --testing --shell "$id"
