from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
IOS_ICON_DIR = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
MACOS_ICON_DIR = ROOT / "macos/Runner/Assets.xcassets/AppIcon.appiconset"
WEB_ICON_DIR = ROOT / "web/icons"
SOURCE_DIR = ROOT / "images"


def rounded_gradient(size: int) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pixels = image.load()
    top = (110, 231, 216)
    bottom = (15, 118, 110)
    for y in range(size):
        t = y / (size - 1)
        color = tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(3)) + (255,)
        for x in range(size):
            pixels[x, y] = color

    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    radius = int(size * 0.215)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    image.putalpha(mask)
    return image


def add_dotted_path(draw: ImageDraw.ImageDraw, size: int) -> None:
    points = [
        (size * 0.19, size * 0.77),
        (size * 0.30, size * 0.66),
        (size * 0.44, size * 0.67),
        (size * 0.57, size * 0.58),
        (size * 0.64, size * 0.47),
        (size * 0.78, size * 0.31),
    ]
    width = int(size * 0.036)
    dot_gap = int(size * 0.074)
    for start, end in zip(points, points[1:]):
        distance = ((end[0] - start[0]) ** 2 + (end[1] - start[1]) ** 2) ** 0.5
        steps = max(1, int(distance // dot_gap))
        for index in range(steps + 1):
            t = index / steps
            x = start[0] + (end[0] - start[0]) * t
            y = start[1] + (end[1] - start[1]) * t
            draw.ellipse((x - width / 2, y - width / 2, x + width / 2, y + width / 2), fill=(216, 255, 249, 255))


def add_footprints(draw: ImageDraw.ImageDraw, size: int) -> None:
    dark = (11, 79, 74, 255)
    heel1 = (size * 0.30, size * 0.74)
    heel2 = (size * 0.24, size * 0.67)
    draw.ellipse((heel1[0] - size * 0.043, heel1[1] - size * 0.064, heel1[0] + size * 0.043, heel1[1] + size * 0.064), fill=dark)
    draw.ellipse((heel2[0] - size * 0.033, heel2[1] - size * 0.051, heel2[0] + size * 0.033, heel2[1] + size * 0.051), fill=dark)
    toe_sets = [
        [(0.348, 0.667, 0.014), (0.320, 0.622, 0.013), (0.288, 0.596, 0.012)],
        [(0.230, 0.616, 0.012), (0.203, 0.573, 0.011), (0.175, 0.547, 0.010)],
    ]
    for toe_set in toe_sets:
        for x, y, radius in toe_set:
            cx = size * x
            cy = size * y
            r = size * radius
            draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=dark)


def add_pin(base: Image.Image, size: int) -> None:
    pin_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pin_draw = ImageDraw.Draw(pin_layer)
    shadow_draw = ImageDraw.Draw(shadow_layer)

    pin_fill = (255, 244, 214, 255)
    pin_shadow = (8, 47, 45, 100)

    pin_bounds = (size * 0.30, size * 0.23, size * 0.70, size * 0.72)
    head_bounds = (size * 0.30, size * 0.23, size * 0.70, size * 0.61)
    tip = (size * 0.50, size * 0.72)
    shadow_offset = size * 0.012

    shadow_draw.ellipse(
        (head_bounds[0] + shadow_offset, head_bounds[1] + shadow_offset, head_bounds[2] + shadow_offset, head_bounds[3] + shadow_offset),
        fill=pin_shadow,
    )
    shadow_draw.polygon(
        [
            (size * 0.38 + shadow_offset, size * 0.54 + shadow_offset),
            (size * 0.62 + shadow_offset, size * 0.54 + shadow_offset),
            (tip[0] + shadow_offset, tip[1] + shadow_offset),
        ],
        fill=pin_shadow,
    )

    pin_draw.ellipse(head_bounds, fill=pin_fill)
    pin_draw.polygon([(size * 0.38, size * 0.54), (size * 0.62, size * 0.54), tip], fill=pin_fill)

    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=size * 0.012))
    base.alpha_composite(shadow_layer)
    base.alpha_composite(pin_layer)


def add_camera(draw: ImageDraw.ImageDraw, size: int) -> None:
    dark = (19, 78, 74, 255)
    cream = (255, 248, 230, 255)
    orange = (253, 186, 116, 255)

    draw.ellipse((size * 0.39, size * 0.31, size * 0.61, size * 0.53), fill=dark)
    draw.rounded_rectangle((size * 0.397, size * 0.357, size * 0.603, size * 0.503), radius=size * 0.033, fill=cream)
    draw.rounded_rectangle((size * 0.445, size * 0.324, size * 0.502, size * 0.357), radius=size * 0.016, fill=cream)
    draw.ellipse((size * 0.455, size * 0.389, size * 0.565, size * 0.499), fill=orange)
    draw.ellipse((size * 0.476, size * 0.410, size * 0.544, size * 0.478), fill=cream)
    draw.ellipse((size * 0.549, size * 0.379, size * 0.573, size * 0.403), fill=dark)


def render_icon(size: int = 1024) -> Image.Image:
    image = rounded_gradient(size)
    draw = ImageDraw.Draw(image)
    add_dotted_path(draw, size)
    add_footprints(draw, size)
    add_pin(image, size)
    add_camera(draw, size)
    return image


def save_png(image: Image.Image, path: Path, size: int) -> None:
    resized = image.resize((size, size), Image.Resampling.LANCZOS)
    path.parent.mkdir(parents=True, exist_ok=True)
    resized.save(path, format="PNG")


def main() -> None:
    base = render_icon(1024)
    save_png(base, SOURCE_DIR / "app_icon_1024.png", 1024)

    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for filename, size in ios_sizes.items():
        save_png(base, IOS_ICON_DIR / filename, size)

    macos_sizes = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    for filename, size in macos_sizes.items():
        save_png(base, MACOS_ICON_DIR / filename, size)

    web_sizes = {
        "Icon-192.png": 192,
        "Icon-512.png": 512,
        "Icon-maskable-192.png": 192,
        "Icon-maskable-512.png": 512,
    }
    for filename, size in web_sizes.items():
        save_png(base, WEB_ICON_DIR / filename, size)


if __name__ == "__main__":
    main()
