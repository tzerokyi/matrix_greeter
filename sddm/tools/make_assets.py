#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageFont, ImageDraw, ImageFilter
import numpy as np
import random
import math

HERE = Path(__file__).resolve().parents[1]
OUT = HERE / 'assets'
OUT.mkdir(exist_ok=True)
SANS = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
CJK = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'
if not Path(SANS).exists():
    SANS = '/usr/share/fonts/TTF/DejaVuSansMono.ttf'
if not Path(CJK).exists():
    CJK = '/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc'

ASCII = list('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@#$%&*+-=<>[]{}|\\/.:;!?')
KATA = list('アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン')
HALF = list('ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝ')
EXTRA = list('日月火水木金土人中大小上下天地零一二三四五六七八九十光電通信網')
POOL = ASCII + KATA + HALF + EXTRA
CHARS = (POOL * ((256 // len(POOL)) + 2))[:256]

cell_w, cell_h, n = 32, 40, 16
atlas = Image.new('RGBA', (cell_w*n, cell_h*n), (255, 255, 255, 0))
mask = Image.new('L', atlas.size, 0)
draw = ImageDraw.Draw(mask)
font_mono = ImageFont.truetype(SANS, 27)
font_cjk = ImageFont.truetype(CJK, 27) if Path(CJK).exists() else font_mono
for k,ch in enumerate(CHARS):
    col,row = k%n,k//n
    ft = font_mono if ch in ASCII else font_cjk
    bbox = draw.textbbox((0,0),ch, font=ft)
    width,height = bbox[2]-bbox[0], bbox[3]-bbox[1]
    xx = col*cell_w + (cell_w-width)/2 - bbox[0]
    yy = row*cell_h + (cell_h-height)/2 - bbox[1]
    draw.text((xx,yy),ch,font=ft,fill=255,stroke_width=0)
atlas.putalpha(mask)
atlas.save(OUT / 'glyph-atlas.png',optimize=True)

W,H=1600,900
rng=random.Random(20261017)
base=Image.new('RGB',(W,H),(1,7,4))
back=Image.new('RGBA',(W,H),(0,0,0,0))
front=Image.new('RGBA',(W,H),(0,0,0,0))

def draw_layer(surface, pitch, advance, depth):
    d = ImageDraw.Draw(surface)
    for c in range(-1, W//pitch+2):
        rs=random.Random(c*1771+int(depth*1191))
        x=c*pitch + rs.randint(-1,1)
        vel = 0.65 + rs.random() * 1.2
        nrows=H//advance+5
        ln=rs.randint(23 if depth>0.5 else 14, 52 if depth>0.5 else 31)
        head=rs.randint(-18,nrows+ln+8)
        size=rs.choice((13,14,15)) if depth>.5 else rs.choice((16,17))
        f0=ImageFont.truetype(SANS,size)
        f1=ImageFont.truetype(CJK,size) if Path(CJK).exists() else f0
        for a in range(ln):
            row=head-a
            if row<0 or row>=nrows or rs.random()<0.092:
                continue
            y=int(row*advance)
            ch=rs.choice(CHARS)
            bright=0.17+0.83*(1-a/ln)**1.3
            if depth < 0.5: bright*=0.45
            bright *= rs.uniform(0.63,1)
            if a==0:
                rgba=(208,255,224,235 if depth>.5 else 90)
            elif a<3:
                rgba=(90,255,150, int(240*bright))
            else:
                rgba=(38,240,101,int(230*bright))
            d.text((x,y),ch,font=f0 if ch in ASCII else f1,fill=rgba)

draw_layer(back, 21,24,.1)
draw_layer(front, 13,18,1)
Y,X=np.ogrid[:H,:W]
rr=np.sqrt(((X-W*.50)/(W*.29))**2+((Y-H*.52)/(H*.40))**2)
center=np.clip((rr-.35)/1.07,0,1)
center=center*center*(3-2*center)
edge=np.clip(1-np.sqrt(((X-W*.5)/(W*.75))**2+((Y-H*.5)/(H*.74))**2),0,1)
maskarr=(.17+.83*center)*(.55+.45*edge)
combined=Image.alpha_composite(back,front)
rgba=np.asarray(combined).copy()
rgba[:,:,3]=(rgba[:,:,3].astype(np.float32)*maskarr).astype('uint8')
base=Image.alpha_composite(base.convert('RGBA'),Image.fromarray(rgba,'RGBA'))
base=base.convert('RGB')
base.save(OUT/'fallback.png',optimize=True)

preview=base.convert('RGBA')
d=ImageDraw.Draw(preview)
def font(px, bold=False):
    p=SANS
    if bold:
        b=p.replace('.ttf','-Bold.ttf')
        if Path(b).exists(): p=b
    return ImageFont.truetype(p,px)
def text(x,y,value,size,color=(217,252,231),bold=False,space=0):
    ft=font(size,bold)
    if not space:
        d.text((x,y),value,font=ft,fill=color)
    else:
        xx=x
        for ch in value:
            d.text((xx,y),ch,font=ft,fill=color)
            xx+=d.textlength(ch,font=ft)+space

def hair(x1,y1,x2,y2,color,width=1):
    d.line((x1,y1,x2,y2),fill=color,width=width)

d.rectangle((72,60,81,69),fill=(116,255,166))
d.rectangle((75,63,78,66),fill=(0,33,14))
hair(181,61,181,79,(70,114,80))
text(195,55,'MATRIX // 03',11,(132,255,173),False,2)
text(98,85,'ARCH LINUX     /     SECURE ACCESS TERMINAL',10,(84,124,94))
text(1416,50,'22:14',33,(218,251,231))
text(1350,95,'SAT · 17 OCT 2026',10,(152,188,158))
hair(72,185,72,325,(38,91,52))
x,y=576,269
d.rectangle((x,y+4,x+5,y+9),fill=(135,255,176))
text(x+15,y-2,'IDENTITY VERIFICATION',11,(135,255,176),True,1)
hair(x,y+28,x+40,y+28,(118,255,160))
hair(x+52,y+28,x+448,y+28,(36,79,48))
text(x-2,y+44,'WAKE THE SYSTEM',30,(226,253,233))
text(x,y+98,'Enter your credentials to continue.',11,(149,189,162))
text(x,y+147,'01    USERNAME',10,(152,188,163),False,1)
text(x,y+170,'demo-user',22,(220,250,229))
text(x+426,y+170,'⌄',18,(139,255,176))
hair(x,y+209,x+448,y+209,(116,151,120))
text(x+335,y+218,'OTHER USER ↗',10,(151,187,160))
text(x,y+257,'02    PASSPHRASE',10,(152,188,163),False,1)
text(x,y+281,'●●●●●●●●●●',19,(224,253,231))
hair(x,y+320,x+448,y+320,(128,250,158),2)
text(x,y+350,'SYSTEM READY  /  SECURE',10,(84,126,98))
d.rectangle((x+316,y+335,x+448,y+379),fill=(9,55,30),outline=(54,165,91))
text(x+336,y+349,'SIGN IN   ↗',11,(225,255,231),True)
hair(72,817,1528,817,(33,80,50))
text(72,783,'TERMINAL  /  03                         ENCRYPTED SESSION',10,(75,113,86))
text(72,839,'SESSION  /  PLASMA (WAYLAND)',10,(145,185,153))
text(330,839,'KEYBOARD',10,(145,185,153))
text(448,839,'ON-SCREEN',10,(145,185,153))
text(1275,839,'RESTART',10,(145,185,153))
text(1390,839,'SHUT DOWN',10,(145,185,153))
preview.convert('RGB').save(HERE/'preview.png',optimize=True)
print('Wrote', OUT/'glyph-atlas.png', OUT/'fallback.png', HERE/'preview.png')
