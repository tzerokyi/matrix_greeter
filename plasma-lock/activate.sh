#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Run as your ordinary KDE user, not sudo.' >&2; exit 2; }
id=org.tzerokyi.matrix.lock
base="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/shells"
[[ -s "$base/$id/contents/lockscreen/shaders/rain.frag.qsb" ]] || { echo 'Not installed or uncompiled: run bash install.sh' >&2; exit 3; }
command -v kreadconfig6 >/dev/null && command -v kwriteconfig6 >/dev/null || { echo 'Missing kreadconfig6 or kwriteconfig6' >&2; exit 4; }
state="${XDG_STATE_HOME:-$HOME/.local/state}/matrix-greeter-lock"
mkdir -p -m 700 "$state"
chmod 700 "$state"
snapshot="$state/previous-shell.txt"
sentinel="__MATRIX_UNSET_SHELL__"
prior="$(kreadconfig6 --file plasmashellrc --group Shell --key ShellPackage --default "$sentinel")"
dropin="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/plasma-kwin_wayland.service.d/99-matrix-greeter-lock.conf"
if [[ "$prior" != "$sentinel" && "$prior" != "$id" ]]; then
    echo "Another desktop ShellPackage is active: $prior" >&2
    echo 'Refusing to replace it; restore that choice first.' >&2
    exit 5
fi
existing_env="$(systemctl --user show plasma-kwin_wayland.service -p Environment --value 2>/dev/null || true)"
if [[ "$existing_env" == *"PLASMA_DEFAULT_SHELL="* && "$existing_env" != *"PLASMA_DEFAULT_SHELL=$id"* ]]; then
    echo 'Another lock greeter override is active. Remove it before activating this package.' >&2
    exit 5
fi
printf '\nWARNING: Plasma uses ShellPackage for desktop AND locker.\n'
printf 'The desktop will stay on org.kde.plasma.desktop; only the real locker\n'
printf 'greeter receives this package through PLASMA_DEFAULT_SHELL.\n'
printf 'Test first via: bash test.sh  (close the test window when done).\n'
read -r -p 'Type TESTED to enable: ' answer
[[ "$answer" == TESTED ]] || { echo 'Cancelled; no configuration changed.'; exit 6; }
if [[ ! -f "$snapshot" && "$prior" == "$id" ]]; then
    printf 'UNSET\n' > "$snapshot"
    chmod 600 "$snapshot"
fi
mkdir -p "$(dirname -- "$dropin")"
tmp="$(mktemp "${dropin}.XXXXXX")"
trap 'unlink -- "$tmp" 2>/dev/null || true' EXIT
printf '%s\n' \
    '[Service]' \
    'Environment=PLASMA_DEFAULT_SHELL=org.tzerokyi.matrix.lock' > "$tmp"
chmod 644 "$tmp"
mv -- "$tmp" "$dropin"
kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage --delete
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume true
systemctl --user daemon-reload 2>/dev/null || true
new="$(kreadconfig6 --file plasmashellrc --group Shell --key ShellPackage --default "$sentinel")"
[[ "$new" == "$sentinel" ]] || { echo 'Desktop ShellPackage cleanup failed.' >&2; exit 7; }
printf '\nConfigured. Log out and log back in to start KWin with the Matrix lock theme.\n'
printf 'The current session still uses its previous lock theme. Do not restart KWin in place.\n'
printf 'Emergency rollback from TTY: Ctrl+Alt+F3, login, bash /path/to/restore.sh\n'
