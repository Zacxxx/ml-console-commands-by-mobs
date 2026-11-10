#!/usr/bin/env python3
"""Export the approved generated artwork; retain its title without version text."""
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'assets/nexus'


def create():
    master = OUTPUT / 'cover-master.png'
    if not master.exists():
        raise SystemExit('Approved cover-master.png is missing; do not regenerate the old title card.')
    with Image.open(master) as image:
        image = image.convert('RGB')
        for width, height in [(1600, 900), (800, 450)]:
            path = OUTPUT / f'cover-{width}x{height}.png'
            ImageOps.fit(image, (width, height), method=Image.Resampling.LANCZOS).save(path, optimize=True)
            print(path)
    header = OUTPUT / 'header-master.png'
    if header.exists():
        with Image.open(header) as image:
            path = OUTPUT / 'header-1300x372.png'
            ImageOps.fit(image.convert('RGB'), (1300, 372), method=Image.Resampling.LANCZOS).save(path, optimize=True)
            print(path)


if __name__ == '__main__':
    create()
