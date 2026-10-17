# Plasma lock screen

This component is the KDE Plasma 6 lock/unlock frontend. It uses KDE's own authenticator; it does not run SDDM or change PAM. Its package ID is `org.tzerokyi.matrix.lock`.

From the repository root, run `bash install.sh --lock` to build and stage it. Existing installations are deliberately not overwritten. Preview safely with `bash plasma-lock/test.sh`. Test mode does not engage a real lock and does not prove that unlock works. Check password entry and F12 / KDE DEFAULT, then run `bash plasma-lock/activate.sh` and type `TESTED`. Remove any other custom lock greeter override first; activation refuses to replace one silently. Log out and back in so KWin receives the lock-theme selection. Test a real `Meta+L` lock and unlock before relying on it.

The activation script keeps Plasma's desktop shell on its default package so panels remain intact. On Wayland, it selects this shell package only for KWin's lock greeter with a user `plasma-kwin_wayland.service` drop-in. The script also enables lock-on-resume. It does not restart KWin or bypass authentication.

If the custom UI fails, try F12 / KDE DEFAULT to open KDE's built-in fallback. To roll back, run `bash plasma-lock/restore.sh` as the same user, then log out and back in. If the screen is unusable, switch to a TTY with `Ctrl+Alt+F3`, log in, and run the same restore script. Removing the override does not immediately change a running KWin process; do not kill KWin to bypass the lock.

Shader source is in `contents/lockscreen/shaders/rain.frag`; `build.sh` generates the untracked `.qsb` file. `tests/check.py` performs structural checks only. Qt rendering, hardware authenticators, and secure lock/unlock require manual testing on the target machine.
