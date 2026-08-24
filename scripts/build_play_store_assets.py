#!/usr/bin/env python3
"""Build Google Play Console listing assets from genuine in-game captures.

The feature graphic and icon are promotional art. Every file placed in a
screenshot directory is an uncomposited frame captured from the running game.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "assets" / "generated"
OUT = ROOT / "store" / "google-play"
CAPTURES = OUT / "source-captures"

GAMEPLAY_CAPTURES = [
    ("01_classic_stadium_gameplay", CAPTURES / "biome_0_classic_stadium.png"),
    ("02_beach_track_gameplay", CAPTURES / "biome_1_beach_track.png"),
    ("03_night_games_gameplay", CAPTURES / "biome_2_night_games.png"),
    ("04_desert_circuit_gameplay", CAPTURES / "biome_3_desert_circuit.png"),
    ("05_snow_games_gameplay", CAPTURES / "biome_4_snow_games.png"),
    ("06_jungle_track_gameplay", CAPTURES / "biome_5_jungle_track.png"),
]
ICON = ART / "ostrich_dash_icon.png"
KEY_ART = ART / "ostrich_dash_key_art.png"


def save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rgb = image.convert("RGB")
    rgb.save(path, format="PNG", optimize=True)


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return ImageOps.fit(image.convert("RGB"), size, method=Image.Resampling.LANCZOS)


def validate_gameplay_capture(image: Image.Image, path: Path) -> None:
    width, height = image.size
    if width < 320 or height < 320 or width > 3840 or height > 3840:
        raise ValueError(f"{path} is outside Google Play's 320-3840 px limits: {image.size}")
    if width * 9 != height * 16:
        raise ValueError(f"{path} must be an uncropped 16:9 game capture, got {image.size}")


def clear_old_screenshots(directory: Path) -> None:
    directory.mkdir(parents=True, exist_ok=True)
    for path in directory.glob("*.png"):
        path.unlink()


def main() -> None:
    icon = Image.open(ICON)
    save_png(cover(icon, (512, 512)), OUT / "icon" / "app_icon_512.png")

    key = Image.open(KEY_ART)
    save_png(cover(key, (1024, 500)), OUT / "feature-graphic" / "feature_graphic_1024x500.png")

    phone_dir = OUT / "phone"
    tab7 = OUT / "tablet-7"
    tab10 = OUT / "tablet-10"

    for directory in (phone_dir, tab7, tab10):
        clear_old_screenshots(directory)

    for stem, path in GAMEPLAY_CAPTURES:
        if not path.exists():
            raise FileNotFoundError(
                f"Missing {path}. Run tests/art_capture.gd with --store-listing first."
            )
        with Image.open(path) as capture:
            validate_gameplay_capture(capture, path)
            # Do not crop, blur, add copy, or composite promotional artwork here.
            # Google Play screenshots must show the actual in-app experience.
            for directory, suffix in (
                (phone_dir, "phone"),
                (tab7, "tablet7"),
                (tab10, "tablet10"),
            ):
                save_png(capture, directory / f"{stem}_{suffix}_16x9.png")

    print(f"Wrote six genuine gameplay screenshots per device class under {OUT}")


if __name__ == "__main__":
    main()
