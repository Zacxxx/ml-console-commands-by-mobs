# Promotional artwork

The cover and header were generated with Codex's built-in image generation tool on
10 November 2026, then exported with Pillow. They are promotional fan artwork, not
gameplay screenshots or official Manor Lords artwork. No version is embedded.

## Files

- `cover-master.png`: approved cover master.
- `cover-1600x900.png`: Nexus/GitHub cover.
- `cover-800x450.png`: smaller cover export.
- `header-master.png`: approved wide master.
- `header-1300x372.png`: Nexus header export.

Run `python3 scripts/create_nexus_cover.py` to export the approved masters again.
This performs resizing/cropping only; it does not generate new artwork or require
an API key. Rejected drafts and previous artwork remain outside the public repo.

## Reference and credits

The installed Steam library hero for Manor Lords was used as a visual reference
for the countryside, medieval setting, lighting and painterly presentation. The
original reference file is not bundled here. Manor Lords is developed by Slavic
Magic and published by Hooded Horse: https://www.hoodedhorse.com/games/manor-lords
Third-party game artwork and trademarks remain their owners' property; this
repository's license grants no rights to those third-party references.

## Final prompt brief

Cover: painterly medieval promotional illustration of a manor lord operating an
oak-and-bronze computer at a desk overlooking a green village and hilltop castle.
Use the genuine Manor Lords key art as a visual reference. Show the scene over
the lord's right shoulder: he faces the screen, keyboard directly between torso
and monitor, hands naturally resting on the keys, all equipment on one flat desk.
Keep a coherent perspective and seated posture. Include ivory title text
“ML CONSOLE COMMANDS” and gold “by Mobs”, with no version. Green console text
includes `mobs.help`, `mobs.grow_trees` and `mobs.finish_constructions`.

Header: adapt the approved cover's over-the-shoulder composition to a wide banner.
Preserve the lord facing the monitor, natural hand/keyboard alignment, painterly
landscape, readable title and “by Mobs”. Keep essential title, hands and computer
inside the final 1300×372 crop. No version text or gameplay UI.

## Published placement

The corrected cover is the thumbnail and visible gallery artwork on Nexus mod 433.
The corrected wide export replaces its header. Previous gallery images are hidden,
not deleted. The original header was removed with the owner's explicit approval.
