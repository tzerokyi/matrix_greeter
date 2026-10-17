#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Run as the SAME KDE account, without sudo.' >&2; exit 2; }
command -v kwriteconfig6 >/dev/null && command -v kreadconfig6 >/dev/null || { echo 'Missing KDE config utilities.' >&2; exit 3; }
id=org.tzerokyi.matrix.lock
state="${XDG_STATE_HOME:-$HOME/.local/state}/matrix-greeter-lock"
snapshot="$state/previous-shell.txt"
dropin="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/plasma-kwin_wayland.service.d/99-matrix-greeter-lock.conf"
current="$(kreadconfig6 --file plasmashellrc --group Shell --key ShellPackage --default 'org.kde.plasma.desktop')"
if [[ "$current" == "$id" ]]; then
  if [[ ! -f "$snapshot" ]]; then
    echo 'No previous-shell snapshot: reverting to KDE stock org.kde.plasma.desktop.'
    kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage --delete
  else
    IFS= read -r mode < "$snapshot"
    if [[ "$mode" == UNSET ]]; then
        kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage --delete
    elif [[ "$mode" == SET ]]; then
        original="$(sed -n '2p' "$snapshot")"
        [[ -n "$original" && "$original" != "$id" ]] || { echo 'Invalid saved shell; stopping.' >&2; exit 4; }
        kwriteconfig6 --file plasmashellrc --group Shell --key ShellPackage "$original"
    else
        echo 'Unknown state; refusing to guess.' >&2; exit 5
    fi
  fi
elif [[ "$current" != 'org.kde.plasma.desktop' ]]; then
    echo "Current ShellPackage is $current; preserving someone else's choice."
fi
if [[ -e "$dropin" ]]; then
    unlink -- "$dropin"
fi
systemctl --user daemon-reload 2>/dev/null || true
new="$(kreadconfig6 --file plasmashellrc --group Shell --key ShellPackage --default 'org.kde.plasma.desktop')"
[[ "$new" != "$id" ]] || { echo 'Rollback config verification failed.' >&2; exit 6; }
if [[ -f "$snapshot" ]]; then unlink -- "$snapshot"; fi
echo "Restored desktop ShellPackage to: $new"
echo 'Removed the Matrix lock greeter environment override.'
echo 'This does not bypass your password or instantly replace a running locker.'
echo 'Log out and log back in to start KWin without this override.'
echo 'If locked out, use KDE fallback authentication or reboot safely; the current KWin retains its startup environment.'
