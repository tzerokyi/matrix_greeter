#!/usr/bin/env python3
from pathlib import Path
import re
import struct

root = Path(__file__).resolve().parents[1]
for name in ('Main.qml','RainEngine.qml','FlatAction.qml','theme.conf','metadata.desktop',
             'shaders/rain.frag','assets/glyph-atlas.png','assets/fallback.png','preview.png'):
    path=root/name
    assert path.is_file() and path.stat().st_size>0, f'Missing or empty: {name}'
for file in ('Main.qml','RainEngine.qml','FlatAction.qml'):
    qml=(root/file).read_text()
    assert 'import QtQuick' in qml
    assert 'Canvas {' not in qml, f'Unexpected CPU paint canvas: {file}'
    assert not re.search(r'\bRepeater\s*\{',qml)
    assert not re.search(r'\bWebView\s*\{',qml)
    for char,left,right in (('braces','{','}'),('paren','(',')')):
        count=0
        for ch in qml:
            if ch==left: count+=1
            if ch==right: count-=1
            assert count>=0, f'Unbalanced {char} in {file}'
        assert count==0, f'Unbalanced {char} in {file}'
frag=(root/'shaders/rain.frag').read_text()
assert '#version 440' in frag
assert 'layout(std140, binding = 0)' in frag
assert 'layout(binding = 1) uniform sampler2D glyphAtlas;' in frag
assert 'qt_TexCoord0' in frag
assert 'qt_Matrix' in frag and 'qt_Opacity' in frag
assert 'fragColor = ' in frag
for img in ('assets/glyph-atlas.png','assets/fallback.png','preview.png'):
    data=(root/img).read_bytes()
    assert data[:8]==b'\x89PNG\r\n\x1a\n', f'Invalid PNG signature: {img}'
    assert data[12:16]==b'IHDR', f'Missing PNG header: {img}'
    width,height=struct.unpack('>II',data[16:24])
    assert width>0 and height>0, f'Invalid PNG dimensions: {img}'
    if img=='assets/glyph-atlas.png':
        assert (width,height)==(512,640),(width,height)
print('PASS: Structural checks, resource integrity, shader interfaces and absence of per-glyph QML objects')
print('NOT CHECKED: Real qsb compilation, Qt Quick scene rendering, live SDDM authentication, GPU FPS')
