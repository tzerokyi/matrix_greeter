#!/usr/bin/env python3
import json, pathlib, re, sys
base=pathlib.Path(sys.argv[1]).resolve()
m=json.loads((base/'metadata.json').read_text())
assert m['KPackageStructure']=='Plasma/Shell'
assert m['KPlugin']['Id']=='org.tzerokyi.matrix.lock'
assert m['X-Plasma-APIVersion']=='2'
p=base/'contents/lockscreen'
for filename in ('LockScreen.qml','RainEngine.qml','FlatAction.qml','shaders/rain.frag', 'assets/glyph-atlas.png', 'assets/fallback.png'):
    assert (p/filename).is_file() and (p/filename).stat().st_size>0,filename
for filename in ('LockScreen.qml','RainEngine.qml','FlatAction.qml'):
    t=(p/filename).read_text()
    t=re.sub(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', ' ',t)
    stack=[]; pairs={'}':'{',')':'(',']':'['}
    for c in t:
        if c in '{([':stack.append(c)
        elif c in '})]':
            assert stack and stack.pop()==pairs[c], f'{filename}: bad delimiter'
    assert not stack,f'{filename}: unclosed delimiter'
q=(p/'LockScreen.qml').read_text()
for token in ('authenticator.startAuthenticating()', 'authenticator.respond(pass.text)', 'qrc:/fallbacktheme/LockScreen.qml', 'Qt.Key_F12', 'function onFailed()', 'function onSucceeded()', 'SessionManagement'):
    assert token in q, token
for banned in ('sddm.login', 'sddm.reboot', 'Qt.createQmlObject', 'XMLHttpRequest'):
    assert banned not in q,banned
try:
    from PIL import Image
    for name in ('glyph-atlas.png','fallback.png'):
        with Image.open(p/'assets'/name) as im:
            im.verify()
except ImportError:pass
print('Static checks passed (NOT Qt runtime or login validation).')
