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
    # mango grueso en diagonal (de abajo-izquierda hacia el centro)
    d.line([(15 * u, 50 * u), (36 * u, 29 * u)], fill=255, width=int(11 * u))
    # cabeza ancha, perpendicular al mango
    cabeza = [(25 * u, 21 * u), (41 * u, 5 * u), (59 * u, 23 * u), (43 * u, 39 * u)]
    d.polygon(cabeza, fill=255)
    return img


def martillo():
    grande = N * S
    forma = silueta(grande)
    borde = forma.filter(ImageFilter.MaxFilter(int(5 * S) | 1))  # contorno de ~2-3 px al final
    rgba = Image.new("RGBA", (grande, grande), (0, 0, 0, 0))
    # disco oscuro de fondo (badge): el tinte del juego lo deja negro y realza el martillo
    disco = Image.new("L", (grande, grande), 0)
    ImageDraw.Draw(disco).ellipse([S, S, grande - S, grande - S], fill=215)
    rgba.paste((0, 0, 0, 255), mask=disco)
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
        slot.alpha_composite(t.resize((20, 20), Image.LANCZOS), (16, 1))
        hoja.alpha_composite(slot.resize((74, 74), Image.NEAREST), (13 + i * 90, 110))
    hoja.save(PREVIEW / "martillo.png")


if __name__ == "__main__":
    main()
