#!/usr/bin/env python3
"""Build Google Play Console listing images from Ostrich Dash game art."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "assets" / "generated"
OUT = ROOT / "store" / "google-play"

VISTAS = [
    ("01_classic_stadium", ART / "classic_stadium_vista.png"),
    ("02_beach", ART / "beach_track_vista.png"),
    ("03_night", ART / "night_games_vista.png"),
    ("04_desert", ART / "desert_circuit_vista.png"),
    ("05_snow", ART / "snow_games_vista.png"),
    ("06_jungle", ART / "jungle_track_vista.png"),
]
RUNNER = ART / "gameplay" / "runner_classic_back.png"
ICON = ART / "ostrich_dash_icon.png"
KEY_ART = ART / "ostrich_dash_key_art.png"


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rgb = image.convert("RGB")
    rgb.save(path, format="PNG", optimize=True)


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return ImageOps.fit(image.convert("RGB"), size, method=Image.Resampling.LANCZOS)


def contain_bottom(canvas: Image.Image, sprite: Image.Image, max_h: int, y: int) -> None:
    ratio = max_h / sprite.height
    w = int(sprite.width * ratio)
    h = int(sprite.height * ratio)
    resized = sprite.resize((w, h), Image.Resampling.LANCZOS)
    x = (canvas.width - w) // 2
    canvas.paste(resized, (x, y), resized)


def portrait_phone(vista: Image.Image, runner: Image.Image, size: tuple[int, int]) -> Image.Image:
    w, h = size
    cover_bg = ImageOps.fit(vista, (w, h), method=Image.Resampling.LANCZOS).filter(
        ImageFilter.GaussianBlur(28)
    )
    canvas = cover_bg.convert("RGBA")
    plate = ImageOps.fit(vista, (w, int(h * 0.58)), method=Image.Resampling.LANCZOS).convert("RGBA")
    canvas.paste(plate, (0, int(h * 0.08)))
    contain_bottom(canvas, runner, int(h * 0.42), int(h * 0.54))
    return canvas.convert("RGB")


def main() -> None:
    icon = Image.open(ICON)
    save_png(cover(icon, (512, 512)), OUT / "icon" / "app_icon_512.png")

    key = Image.open(KEY_ART)
    save_png(cover(key, (1024, 500)), OUT / "feature-graphic" / "feature_graphic_1024x500.png")

    runner = Image.open(RUNNER).convert("RGBA")
    phone_dir = OUT / "phone"
    tab7 = OUT / "tablet-7"
    tab10 = OUT / "tablet-10"

    for index, (stem, path) in enumerate(VISTAS):
        vista = Image.open(path)
        if index < 4:
            save_png(portrait_phone(vista, runner, (1080, 1920)), phone_dir / f"{stem}_phone_9x16.png")
        if index in (0, 2):
            save_png(cover(vista, (1920, 1080)), phone_dir / f"{stem}_phone_16x9.png")
        if index < 4:
            save_png(cover(vista, (1920, 1080)), tab7 / f"{stem}_tablet7_16x9.png")
            save_png(cover(vista, (1920, 1080)), tab10 / f"{stem}_tablet10_16x9.png")

    print(f"Wrote Play listing assets under {OUT}")


if __name__ == "__main__":
    main()
