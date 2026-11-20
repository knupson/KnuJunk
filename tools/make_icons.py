"""Genera las siluetas propias de KnuJunk, sin dependencias externas."""
from pathlib import Path
import math
import struct

SIZE = 32
ROOT = Path(__file__).resolve().parents[1] / 'media'


def rect(x, y, left, top, right, bottom):
    return left <= x <= right and top <= y <= bottom


def line(x, y, ax, ay, bx, by, width=2):
    dx, dy = bx - ax, by - ay
    t = max(0, min(1, ((x-ax)*dx + (y-ay)*dy) / (dx*dx + dy*dy)))
    return math.hypot(x-ax-t*dx, y-ay-t*dy) <= width


def shape(kind, x, y):
    if kind == 'protected':
        ring = 5 <= math.hypot(x-16, y-12) <= 8 and y <= 14
        body = rect(x,y,6,13,26,27) and not (rect(x,y,15,19,17,24))
        return ring or body
    if kind == 'quest':
        return (rect(x,y,9,5,24,27) and not any(rect(x,y,12,h,21,h+1) for h in (11,16,21))
                or rect(x,y,5,5,10,9) or rect(x,y,23,23,28,27))
    if kind == 'auction':
        return (rect(x,y,15,5,17,26) or rect(x,y,9,26,23,28)
                or line(x,y,5,10,27,10,1) or line(x,y,6,10,3,19,0.8)
                or line(x,y,6,10,10,19,0.8) or line(x,y,25,10,21,19,0.8)
                or line(x,y,25,10,29,19,0.8)
                or (rect(x,y,2,19,11,22)) or rect(x,y,20,19,30,22))
    if kind == 'trash':
        return (rect(x,y,6,7,26,10) or rect(x,y,12,4,20,7)
                or rect(x,y,8,12,24,28) and not (rect(x,y,12,15,13,25) or rect(x,y,19,15,20,25)))
    if kind == 'useful':
        return line(x,y,6,17,13,24,2.5) or line(x,y,13,24,27,8,2.5)
    if kind == 'unruled':
        arc = 2.9 <= math.hypot(x-16, y-10.5) <= 7.1 and (y <= 10.5 or (x >= 16 and y <= 14))
        return (arc or line(x,y,11,10.5,11,11.5,2.1) or line(x,y,19.5,14,16,16.8,2.1)
                or line(x,y,16,16.8,16,18.8,2.1) or math.hypot(x-16,y-26.8) <= 2.4)
    if kind == 'coin':
        radius = math.hypot(x-16,y-16)
        return (10 <= radius <= 13 or radius <= 8) and not rect(x,y,15,11,17,21)
    return False


def generate():
    ROOT.mkdir(exist_ok=True)
    for kind in ('protected', 'quest', 'auction', 'trash', 'useful', 'unruled', 'coin', 'fondo'):
        data = bytearray()
        # Supersampling geométrico: bordes con alfa suave incluso a 14 px.
        for y in range(SIZE):
            for x in range(SIZE):
                samples = sum((math.hypot(x+(sx+.5)/4-16,y+(sy+.5)/4-16) <= 15
                               if kind == 'fondo' else shape(kind,x+(sx+.5)/4,y+(sy+.5)/4))
                              for sy in range(4) for sx in range(4))
                alpha = round(samples / 16 * (191 if kind == 'fondo' else 255))
                shade = 0 if kind == 'fondo' else 255
                data.extend((shade, shade, shade, alpha))
        header = struct.pack('<BBBHHBHHHHBB', 0,0,2,0,0,0,0,0,SIZE,SIZE,32,0x28)
        (ROOT / (kind + '.tga')).write_bytes(header + data)


if __name__ == '__main__':
    generate()
