#!/usr/bin/env python3
"""Draw an original typographic title card; no game images or third-party art."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'assets/nexus'


def create():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    image = Image.new('RGB', (1600, 900), '#112820')
    draw = ImageDraw.Draw(image)
    for y in range(900):
        mix = y / 900
        draw.line((0, y, 1600, y), fill=(int(17 - 6 * mix), int(40 - 17 * mix), int(32 - 9 * mix)))
    cream, gold, muted = '#f4ecd9', '#d5b675', '#a6b8a8'
    fonts = Path('/usr/share/fonts/truetype/dejavu')

    def font(size, bold=False, mono=False):
        name = 'DejaVuSansMono.ttf' if mono else ('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf')
        return ImageFont.truetype(str(fonts / name), size)

    # Abstract forest geometry is decorative, not a purported game screenshot.
    for x, height in [(980, 270), (1080, 330), (1210, 420), (1340, 310), (1480, 440), (1565, 300)]:
        for layer in range(3):
            top = 880 - height + layer * 70
            draw.polygon([(x, top), (x - height // 4, top + 155), (x + height // 4, top + 155)], fill='#1b382c')
        draw.rectangle((x - 7, 810, x + 7, 900), fill='#1b382c')
    draw.rectangle((54, 54, 1546, 846), outline='#46604c', width=2)
    draw.rectangle((54, 54, 62, 180), fill=gold)
    draw.text((112, 105), 'MANOR LORDS  /  UE4SS COMMAND TOOLS', font=font(23), fill=gold)
    draw.text((106, 215), 'ML CONSOLE', font=font(95, True), fill=cream)
    draw.text((106, 330), 'COMMANDS', font=font(108, True), fill=cream)
    draw.text((112, 475), 'by Mobs', font=font(51), fill=gold)
    draw.line((112, 570, 840, 570), fill='#46604c', width=2)
    draw.text((112, 606), 'BUILD  /  SUPPLY  /  REGROW', font=font(24, True), fill=cream)
    draw.text((112, 654), 'Regional cards, resources & command discovery', font=font(22), fill=muted)
    draw.rounded_rectangle((1010, 246, 1487, 583), radius=18, fill='#0d1b17', outline='#52634c', width=2)
    draw.line((1010, 303, 1487, 303), fill='#344c3b', width=2)
    for x in [1040, 1060, 1080]:
        draw.ellipse((x, 269, x + 9, 278), fill=gold)
    draw.text((1037, 338), '> mobs.help', font=font(23, mono=True), fill=gold)
    draw.text((1037, 402), '> mobs.find construction', font=font(23, mono=True), fill=cream)
    draw.text((1037, 466), '> mobs.usage pile', font=font(23, mono=True), fill=cream)
    draw.text((1037, 537), 'DISCOVER  /  CHOOSE  /  RUN', font=font(17), fill=muted)
    draw.text((112, 767), '0.14.0-alpha.1', font=font(24, True), fill=gold)
    draw.text((390, 769), 'FOR GAME 0.8.117', font=font(22), fill=cream)
    draw.text((1063, 794), 'PROMOTIONAL TITLE CARD', font=font(16), fill=muted)
    image.save(OUTPUT / 'cover-1600x900.png', optimize=True)
    image.resize((800, 450), Image.Resampling.LANCZOS).save(OUTPUT / 'cover-800x450.png', optimize=True)
    print(OUTPUT / 'cover-1600x900.png')


if __name__ == '__main__':
    create()
