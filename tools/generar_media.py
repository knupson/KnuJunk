"""Genera el martillo de KnuJunk: silueta blanca con borde negro (se tine en el juego).

Uso desde la raiz del repo:  python tools/generar_media.py
Salida: media/martillo.tga (32 bits, sin compresion) y tools/preview/martillo.png (muestra tenida).
"""
import pathlib
from PIL import Image, ImageDraw, ImageFilter

BASE = pathlib.Path(__file__).resolve().parent.parent
MEDIA = BASE / "media"
PREVIEW = BASE / "tools" / "preview"
N = 64  # lado final
S = 4   # sobremuestreo para bordes suaves


def silueta(lado):
    img = Image.new("L", (lado, lado), 0)
    d = ImageDraw.Draw(img)
    u = lado / 64.0
    # mango en diagonal (de abajo-izquierda a arriba-derecha)
    d.line([(14 * u, 52 * u), (40 * u, 26 * u)], fill=255, width=int(9 * u))
    # cabeza del martillo, perpendicular al mango
    cabeza = [(30 * u, 14 * u), (44 * u, 2 * u), (62 * u, 20 * u), (48 * u, 34 * u)]
    d.polygon(cabeza, fill=255)
    return img


def martillo():
    grande = N * S
    forma = silueta(grande)
    borde = forma.filter(ImageFilter.MaxFilter(int(5 * S) | 1))  # contorno de ~2-3 px al final
    rgba = Image.new("RGBA", (grande, grande), (0, 0, 0, 0))
    rgba.paste((0, 0, 0, 255), mask=borde)
    rgba.paste((255, 255, 255, 255), mask=forma)
    return rgba.resize((N, N), Image.LANCZOS)


def main():
    MEDIA.mkdir(exist_ok=True)
    PREVIEW.mkdir(parents=True, exist_ok=True)
    m = martillo()
    m.save(MEDIA / "martillo.tga")
    # muestra: verde (tu profesion), ambar, gris (no tuya) sobre fondo oscuro, tamano real 14 px y ampliado
    tintes = {"verde": (64, 217, 89), "ambar": (255, 168, 46), "gris": (190, 190, 190)}
    hoja = Image.new("RGBA", (3 * 90 + 10, 200), (30, 22, 14, 255))
    for i, (nombre, rgb) in enumerate(tintes.items()):
        tin = Image.new("RGBA", m.size, rgb + (255,))
        t = Image.composite(Image.alpha_composite(Image.new("RGBA", m.size, (0, 0, 0, 0)), Image.merge("RGBA", (*[Image.eval(m.getchannel(c), lambda v, k=k: v * k // 255) for c, k in zip("RGB", rgb)], m.getchannel("A")))), Image.new("RGBA", m.size, (0, 0, 0, 0)), m.getchannel("A"))
        hoja.alpha_composite(t.resize((80, 80), Image.LANCZOS), (10 + i * 90, 10))
        slot = Image.new("RGBA", (37, 37), (90, 70, 50, 255))
        slot.alpha_composite(t.resize((16, 16), Image.LANCZOS), (20, 1))
        hoja.alpha_composite(slot.resize((74, 74), Image.NEAREST), (13 + i * 90, 110))
    hoja.save(PREVIEW / "martillo.png")


if __name__ == "__main__":
    main()
